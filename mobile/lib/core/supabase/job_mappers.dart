import '../models/chat_message_model.dart';
import '../models/job_model.dart';
import '../models/offer_model.dart';

/// Converts database rows (JSON maps from Supabase) into the app's models, and back to database values.
class JobMappers {
  // ---------- status / enum conversions ----------
  static JobStatus jobStatusFromDb(String? s) {
    switch (s) {
      case 'SCHEDULED':
        return JobStatus.scheduled;
      case 'PRO_EN_ROUTE':
        return JobStatus.proEnRoute;
      case 'IN_PROGRESS':
        return JobStatus.inProgress;
      case 'COMPLETED':
      case 'DISPUTED': // the app has no "disputed" state yet; shown as "waiting for approval"
        return JobStatus.completed;
      case 'RELEASED':
        return JobStatus.released;
      case 'CANCELLED':
        return JobStatus.cancelled;
      case 'DRAFT':
      case 'ESCROW_PENDING':
      case 'PENDING_OFFERS':
      default:
        return JobStatus.pendingOffers;
    }
  }

  static String jobStatusToDb(JobStatus s) {
    switch (s) {
      case JobStatus.pendingOffers:
        return 'PENDING_OFFERS';
      case JobStatus.scheduled:
        return 'SCHEDULED';
      case JobStatus.proEnRoute:
        return 'PRO_EN_ROUTE';
      case JobStatus.inProgress:
        return 'IN_PROGRESS';
      case JobStatus.completed:
        return 'COMPLETED';
      case JobStatus.released:
        return 'RELEASED';
      case JobStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static UrgencyLevel urgencyFromDb(String? s) {
    switch (s) {
      case 'EMERGENCY_TODAY':
        return UrgencyLevel.emergency;
      case 'FLEXIBLE':
        return UrgencyLevel.flexible;
      case 'THIS_WEEK':
      default:
        return UrgencyLevel.thisWeek;
    }
  }

  static String urgencyToDb(UrgencyLevel u) {
    switch (u) {
      case UrgencyLevel.emergency:
        return 'EMERGENCY_TODAY';
      case UrgencyLevel.thisWeek:
        return 'THIS_WEEK';
      case UrgencyLevel.flexible:
        return 'FLEXIBLE';
    }
  }

  static OfferStatus offerStatusFromDb(String? s, {required bool jobReleased}) {
    switch (s) {
      case 'ACCEPTED':
        return jobReleased ? OfferStatus.completed : OfferStatus.accepted;
      case 'REJECTED':
      case 'EXPIRED':
      case 'WITHDRAWN':
        return OfferStatus.rejected;
      case 'PENDING':
      default:
        return OfferStatus.pending;
    }
  }

  static double _num(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
  static int _int(dynamic v) => v == null ? 0 : (v as num).toInt();

  // ---------- professional card (from the view pro_public_profiles) ----------
  static ProProfile proProfile(Map<String, dynamic> r) {
    final first = (r['first_name'] ?? '') as String;
    final initial = (r['last_initial'] ?? '') as String;
    final name = '$first $initial'.trim();
    final badges = <String>[];
    if (r['identity_verified'] == true) badges.add('KİMLİK ONAYLI');
    if (r['criminal_record_verified'] == true) badges.add('SABIKA TEMİZ');
    if (r['is_verified'] == true) badges.add('USTALIK BELGELİ');
    return ProProfile(
      id: r['pro_id'] as String,
      name: name,
      businessName: (r['business_name'] ?? name) as String,
      rating: _num(r['rating_avg']),
      reviewCount: _int(r['total_reviews_count']),
      completedJobs: _int(r['completed_jobs_count']),
      badges: badges,
      avatarUrl: (r['avatar_url'] ?? '') as String,
      experienceYears: _int(r['experience_years']),
      isIdentityVerified: r['identity_verified'] == true,
      isCriminalRecordClean: r['criminal_record_verified'] == true,
    );
  }

  /// Used when the card of a professional could not be loaded.
  static ProProfile unknownPro(String proId) => ProProfile(
        id: proId,
        name: '-',
        businessName: '-',
        rating: 0,
        reviewCount: 0,
        completedJobs: 0,
        badges: const [],
        avatarUrl: '',
      );

  // ---------- offer ----------
  static ProOffer offer(Map<String, dynamic> r, ProProfile pro, {required bool jobReleased}) {
    return ProOffer(
      id: r['id'] as String,
      jobId: r['job_id'] as String,
      pro: pro,
      laborAmount: _num(r['labor_amount']),
      materialsAmount: _num(r['materials_amount']),
      totalAmount: _num(r['total_amount']),
      warrantyMonths: _int(r['warranty_months']),
      estimatedArrivalMinutes: _int(r['estimated_arrival_minutes']),
      note: (r['note'] ?? '') as String,
      status: offerStatusFromDb(r['status'] as String?, jobReleased: jobReleased),
      createdAt: DateTime.parse(r['created_at'] as String),
    );
  }

  // ---------- job ----------
  static JobRequest job(
    Map<String, dynamic> r, {
    List<ProOffer> offers = const [],
    List<String> photoUrls = const [],
    bool escrowLocked = false,
    String? addressLine,
    String? completionPin,
  }) {
    final dateLabel = (r['preferred_date_label'] ?? r['preferred_date'] ?? '') as String;
    return JobRequest(
      id: r['id'] as String,
      customerId: r['customer_id'] as String,
      categoryId: r['category_id'] as String,
      title: (r['title'] ?? '') as String,
      description: (r['description'] ?? '') as String,
      urgency: urgencyFromDb(r['urgency'] as String?),
      preferredDate: dateLabel,
      preferredTimeSlot: (r['preferred_time_slot'] ?? '') as String,
      city: (r['city'] ?? 'İstanbul') as String,
      district: (r['district'] ?? '') as String,
      neighborhood: (r['neighborhood'] ?? '') as String,
      addressLine: addressLine ?? (r['address_line_masked'] ?? '') as String,
      photoUrls: photoUrls,
      status: jobStatusFromDb(r['status'] as String?),
      offers: offers,
      selectedOfferId: r['selected_offer_id'] as String?,
      completionPin: completionPin ?? '',
      escrowLocked: escrowLocked,
      createdAt: DateTime.parse(r['created_at'] as String),
    );
  }

  // ---------- chat ----------
  static ChatMessage chat(Map<String, dynamic> r, {required String myId, required Map<String, String> names}) {
    final sender = r['sender_id'] as String;
    return ChatMessage(
      id: r['id'] as String,
      jobId: r['job_id'] as String,
      senderId: sender,
      senderName: names[sender] ?? '-',
      text: (r['message_text'] ?? '') as String,
      timestamp: DateTime.parse(r['created_at'] as String),
      isFromMe: sender == myId,
    );
  }
}
