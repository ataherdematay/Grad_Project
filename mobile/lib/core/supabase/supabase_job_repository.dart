import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message_model.dart';
import '../models/job_model.dart';
import '../models/offer_model.dart';
import '../repositories/job_repository.dart';
import 'job_mappers.dart';

/// Real data from Supabase. Same interface as MockJobRepository, so screens and the JobBloc do not change.
///
/// Reading = normal table queries (the database only returns rows this user may see).
/// Writing important things = database functions (fn_*), because they apply the rules (one accepted offer,
/// payment pool, PIN...) in one transaction. See database/06_App_and_API_Mapping.md.
class SupabaseJobRepository implements JobRepository {
  SupabaseJobRepository(this._client);

  final SupabaseClient _client;

  // The exact address and the PIN are hidden columns, so SELECT * is NOT allowed: list the columns.
  static const String _jobColumns =
      'id, customer_id, category_id, title, description, urgency, preferred_date, preferred_date_label, '
      'preferred_time_slot, city, district, neighborhood, address_line_masked, status, selected_offer_id, created_at';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw AuthException('Not logged in');
    return id;
  }

  // ---------- helpers ----------
  Future<List<JobRequest>> _hydrate(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return <JobRequest>[];
    final ids = rows.map((r) => r['id'] as String).toList();

    final offerRows = await _client.from('offers').select().inFilter('job_id', ids).order('created_at');
    final proIds = offerRows.map((o) => o['pro_id'] as String).toSet().toList();
    final proRows = proIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _client.from('pro_public_profiles').select().inFilter('pro_id', proIds);
    final pros = {for (final p in proRows) p['pro_id'] as String: JobMappers.proProfile(p)};

    final payRows = await _client.from('payments').select('job_id, status').inFilter('job_id', ids);
    final locked = {for (final p in payRows) p['job_id'] as String: p['status'] == 'LOCKED'};

    final photoRows = await _client.from('job_photos').select('job_id, file_url, position').inFilter('job_id', ids).order('position');
    final photoLinks = await _signedPhotoLinks(photoRows.map((p) => p['file_url'] as String).toList());

    return rows.map((r) {
      final id = r['id'] as String;
      final released = r['status'] == 'RELEASED';
      final offers = offerRows
          .where((o) => o['job_id'] == id)
          .map((o) => JobMappers.offer(o, pros[o['pro_id']] ?? JobMappers.unknownPro(o['pro_id'] as String), jobReleased: released))
          .toList();
      final photos = photoRows
          .where((p) => p['job_id'] == id)
          .map((p) => photoLinks[p['file_url'] as String] ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
      return JobMappers.job(r, offers: offers, photoUrls: photos, escrowLocked: locked[id] ?? false);
    }).toList();
  }

  // Job photos live in the private bucket "job-photos": the app gets temporary links (valid 1 hour).
  Future<Map<String, String>> _signedPhotoLinks(List<String> paths) async {
    final links = <String, String>{};
    final plain = paths.where((p) => !p.startsWith('http')).toList();
    for (final p in paths) {
      if (p.startsWith('http')) links[p] = p;
    }
    if (plain.isEmpty) return links;
    final signed = await _client.storage.from('job-photos').createSignedUrls(plain, 3600);
    for (final s in signed) {
      links[s.path] = s.signedUrl;
    }
    return links;
  }

  // ---------- customer ----------
  @override
  Future<List<JobRequest>> getCustomerJobs() async {
    final rows = await _client.from('job_requests').select(_jobColumns).eq('customer_id', _uid).order('created_at', ascending: false);
    return _hydrate(rows);
  }

  @override
  Future<JobRequest?> getJobById(String id) async {
    final rows = await _client.from('job_requests').select(_jobColumns).eq('id', id).limit(1);
    if (rows.isEmpty) return null;
    final job = (await _hydrate(rows)).first;

    // exact address: the owner always, the professional only after the appointment is confirmed (decided by the database)
    final address = await _client.rpc('fn_get_job_address', params: {'p_job_id': id});
    String? pin;
    if (job.customerId == _client.auth.currentUser?.id) {
      final p = await _client.rpc('fn_my_job_pin', params: {'p_job_id': id});
      pin = p as String?;
    }
    return job.copyWith(addressLine: (address as String?) ?? job.addressLine, completionPin: pin ?? '');
  }

  @override
  Future<JobRequest> createJob(JobRequest job) async {
    final inserted = await _client
        .from('job_requests')
        .insert({
          'customer_id': _uid,
          'category_id': job.categoryId,
          'title': job.title,
          'description': job.description,
          'urgency': JobMappers.urgencyToDb(job.urgency),
          'preferred_date_label': job.preferredDate,
          'preferred_time_slot': job.preferredTimeSlot,
          'city': job.city,
          'district': job.district,
          'neighborhood': job.neighborhood,
          'address_line_masked': '${job.neighborhood} Mah.',
          'address_full_encrypted': job.addressLine,
          'status': 'PENDING_OFFERS',
        })
        .select(_jobColumns)
        .single();
    // TODO(photos): upload files to the storage bucket "job-photos" under "<user id>/<file>" and insert rows into job_photos.
    return (await _hydrate([inserted])).first.copyWith(addressLine: job.addressLine);
  }

  @override
  Future<JobRequest> acceptOffer(String jobId, String offerId) async {
    // TODO(payment): the payment provider is not chosen yet. When it is, run the card payment (3D Secure) first and
    // pass the provider's reference and the card's last 4 digits here. These are placeholders until then.
    await _client.rpc('fn_accept_offer', params: {
      'p_job_id': jobId,
      'p_offer_id': offerId,
      'p_provider_ref': 'PLACEHOLDER-${DateTime.now().millisecondsSinceEpoch}',
      'p_card_last4': '0000',
    });
    return _mustGet(jobId);
  }

  @override
  Future<JobRequest> updateJobStatus(String jobId, JobStatus newStatus) async {
    await _client.rpc('fn_set_job_progress', params: {
      'p_job_id': jobId,
      'p_to': JobMappers.jobStatusToDb(newStatus),
    });
    return _mustGet(jobId);
  }

  @override
  Future<JobRequest> completeWork(String jobId, String pin, int rating, String review) async {
    await _client.rpc('fn_complete_work', params: {
      'p_job_id': jobId,
      'p_pin': pin,
      'p_rating': rating,
      'p_review': review,
    });
    return _mustGet(jobId);
  }

  // ---------- professional ----------
  @override
  Future<List<JobRequest>> getAvailableProJobs() async {
    // the database only returns open requests that match this professional's category and districts
    final rows = await _client.from('job_requests').select(_jobColumns).eq('status', 'PENDING_OFFERS').order('created_at', ascending: false);
    return _hydrate(rows);
  }

  @override
  Future<JobRequest> submitProBid(String jobId, ProOffer offer) async {
    await _client.rpc('fn_submit_offer', params: {
      'p_job_id': jobId,
      'p_items': [
        {'kind': 'LABOR', 'description': 'Labor', 'quantity': 1, 'unit_price': offer.laborAmount},
        if (offer.materialsAmount > 0) {'kind': 'MATERIAL', 'description': 'Materials', 'quantity': 1, 'unit_price': offer.materialsAmount},
      ],
      'p_warranty': offer.warrantyMonths,
      'p_arrival_min': offer.estimatedArrivalMinutes,
      'p_note': offer.note,
    });
    return _mustGet(jobId);
  }

  // ---------- chat ----------
  @override
  Future<List<ChatMessage>> getChatMessages(String jobId) async {
    final rows = await _client.from('chat_messages').select().eq('job_id', jobId).order('created_at');
    return _withNames(rows);
  }

  @override
  Future<ChatMessage> sendChatMessage(String jobId, String text) async {
    final row = await _client
        .from('chat_messages')
        .insert({'job_id': jobId, 'sender_id': _uid, 'message_text': text})
        .select()
        .single();
    return (await _withNames([row])).first;
  }

  Future<List<ChatMessage>> _withNames(List<Map<String, dynamic>> rows) async {
    final senderIds = rows.map((r) => r['sender_id'] as String).toSet().toList();
    final names = <String, String>{};
    if (senderIds.isNotEmpty) {
      // allowed by the database for the two people of the same job
      final users = await _client.from('users').select('id, first_name').inFilter('id', senderIds);
      for (final u in users) {
        names[u['id'] as String] = u['first_name'] as String;
      }
    }
    return rows.map((r) => JobMappers.chat(r, myId: _uid, names: names)).toList();
  }

  Future<JobRequest> _mustGet(String id) async {
    final job = await getJobById(id);
    if (job == null) throw Exception('Job not found: $id');
    return job;
  }
}
