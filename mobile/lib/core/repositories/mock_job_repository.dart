import 'dart:async';
import '../models/job_model.dart';
import '../models/offer_model.dart';
import '../models/chat_message_model.dart';
import 'job_repository.dart';

class MockJobRepository implements JobRepository {
  static final ProProfile proAhmet = ProProfile(
    id: 'pro-201',
    name: 'Ahmet Yılmaz',
    businessName: 'Mavi Hat Su Tesisatı',
    rating: 4.9,
    reviewCount: 248,
    completedJobs: 248,
    badges: const ['KİMLİK ONAYLI', 'SABIKA TEMİZ', '12 AY GARANTİ'],
    avatarUrl:
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200',
    experienceYears: 14,
  );

  static final ProProfile proMehmet = ProProfile(
    id: 'pro-202',
    name: 'Mehmet Kaya',
    businessName: 'Kadıköy Tesisat Pro',
    rating: 4.8,
    reviewCount: 185,
    completedJobs: 185,
    badges: const ['KİMLİK ONAYLI', 'USTALIK BELGELİ'],
    avatarUrl:
        'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=200',
    experienceYears: 9,
  );

  static final ProProfile proSerkan = ProProfile(
    id: 'pro-203',
    name: 'Serkan Demir',
    businessName: 'Usta Adam Sıhhi Tesisat',
    rating: 4.7,
    reviewCount: 94,
    completedJobs: 94,
    badges: const ['KİMLİK ONAYLI'],
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    experienceYears: 6,
  );

  List<JobRequest> _jobs = [];
  Map<String, List<ChatMessage>> _messages = {};

  MockJobRepository() {
    _initSampleData();
  }

  void _initSampleData() {
    final now = DateTime.now();

    final flagshipOffers = [
      ProOffer(
        id: 'off-01',
        jobId: 'job-84920',
        pro: proAhmet,
        laborAmount: 1800,
        materialsAmount: 650,
        totalAmount: 2450,
        warrantyMonths: 12,
        estimatedArrivalMinutes: 45,
        note:
            'ECA marka pirinç batarya ve çelik örgülü fleks hortum kullanılacaktır. 12 ay koşulsuz sızdırmazlık garantilidir.',
        createdAt: now.subtract(const Duration(minutes: 18)),
      ),
      ProOffer(
        id: 'off-02',
        jobId: 'job-84920',
        pro: proMehmet,
        laborAmount: 1600,
        materialsAmount: 600,
        totalAmount: 2200,
        warrantyMonths: 6,
        estimatedArrivalMinutes: 60,
        note:
            'Artema uyumlu batarya montajı ve boru sızdırmazlık testi yapılır.',
        createdAt: now.subtract(const Duration(minutes: 34)),
      ),
      ProOffer(
        id: 'off-03',
        jobId: 'job-84920',
        pro: proSerkan,
        laborAmount: 2000,
        materialsAmount: 800,
        totalAmount: 2800,
        warrantyMonths: 12,
        estimatedArrivalMinutes: 30,
        note: 'Hemen bugün gelebilirim. Tüm malzemeler orijinal garantilidir.',
        createdAt: now.subtract(const Duration(minutes: 52)),
      ),
    ];

    _jobs = [
      JobRequest(
        id: 'job-84920',
        customerId: 'u-101',
        categoryId: 'plumbing',
        title: 'Banyo Bataryası Değişimi & Su Kaçağı Tamiri',
        description:
            'Lavabo altı fleks borusunda damlama var ve batarya kireçlenmeden ötürü sıkıştı. Yeni batarya montajı ve kaçak tespiti gerekiyor.',
        urgency: UrgencyLevel.thisWeek,
        preferredDate: '25 Ekim Cuma',
        preferredTimeSlot: '14:00 - 17:00',
        city: 'İstanbul',
        district: 'Kadıköy',
        neighborhood: 'Caferağa Mah.',
        addressLine: 'Moda Cad. No:42 Daire:5',
        photoUrls: const [
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
        ],
        status: JobStatus.pendingOffers,
        offers: flagshipOffers,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      JobRequest(
        id: 'job-10293',
        customerId: 'u-101',
        categoryId: 'electrical',
        title: 'Salon Avize Montajı ve 3 Adet Priz Değişimi',
        description:
            'Yeni taşındığımız evin salonuna 1 adet sarkıt avize takılacak ve mutfaktaki gevşek prizler Schneider prizle değişecek.',
        urgency: UrgencyLevel.flexible,
        preferredDate: '27 Ekim Pazar',
        preferredTimeSlot: '10:00 - 13:00',
        city: 'İstanbul',
        district: 'Kadıköy',
        neighborhood: 'Fenerbahçe Mah.',
        addressLine: 'Kalamış Fener Cad. No:18',
        photoUrls: const [],
        status: JobStatus.released,
        offers: const [],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    _messages = {
      'job-84920': [
        ChatMessage(
          id: 'msg-01',
          jobId: 'job-84920',
          senderId: 'pro-201',
          senderName: 'Ahmet Usta',
          text:
              'Merhaba Ata Bey, teklifimi ilettim. ECA marka döküm batarya ve 12 ay garanti belgesiyle geleceğim.',
          timestamp: now.subtract(const Duration(minutes: 15)),
          isFromMe: false,
        ),
        ChatMessage(
          id: 'msg-02',
          jobId: 'job-84920',
          senderId: 'u-101',
          senderName: 'Ata',
          text:
              'Merhaba Ahmet Usta, ECA olması çok iyi olur. Randevu saati olan 14:00\'te evdeyim.',
          timestamp: now.subtract(const Duration(minutes: 10)),
          isFromMe: true,
        ),
        ChatMessage(
          id: 'msg-03',
          jobId: 'job-84920',
          senderId: 'pro-201',
          senderName: 'Ahmet Usta',
          text:
              'Anlaştık, takım çantası ve parçalarla 14:00\'te kapınızda olacağım.',
          timestamp: now.subtract(const Duration(minutes: 8)),
          isFromMe: false,
        ),
      ]
    };
  }

  @override
  Future<List<JobRequest>> getCustomerJobs() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_jobs);
  }

  @override
  Future<JobRequest?> getJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _jobs.where((j) => j.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<JobRequest> createJob(JobRequest job) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newJob = job.copyWith(
      id: 'job-${DateTime.now().millisecondsSinceEpoch % 100000}',
      createdAt: DateTime.now(),
      status: JobStatus.pendingOffers,
    );
    _jobs.insert(0, newJob);
    return newJob;
  }

  @override
  Future<JobRequest> acceptOffer(String jobId, String offerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final current = _jobs[index];
      final updatedOffers = current.offers.map((o) {
        if (o.id == offerId) {
          return o.copyWith(status: OfferStatus.accepted);
        }
        return o.copyWith(status: OfferStatus.rejected);
      }).toList();

      final updatedJob = current.copyWith(
        status: JobStatus.scheduled,
        selectedOfferId: offerId,
        escrowLocked: true,
        offers: updatedOffers,
      );
      _jobs[index] = updatedJob;
      return updatedJob;
    }
    throw Exception('İş ilanı bulunamadı: $jobId');
  }

  @override
  Future<JobRequest> updateJobStatus(String jobId, JobStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(status: newStatus);
      _jobs[index] = updated;
      return updated;
    }
    throw Exception('İş ilanı bulunamadı: $jobId');
  }

  @override
  Future<JobRequest> completeWork(
      String jobId, String pin, int rating, String review) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final current = _jobs[index];
      if (current.completionPin != pin) {
        throw Exception('Geçersiz güvenlik PIN kodu! Lütfen kontrol ediniz.');
      }
      final updated = current.copyWith(
        status: JobStatus.released,
      );
      _jobs[index] = updated;
      return updated;
    }
    throw Exception('İş ilanı bulunamadı: $jobId');
  }

  @override
  Future<List<JobRequest>> getAvailableProJobs() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _jobs.where((j) => j.status == JobStatus.pendingOffers).toList();
  }

  @override
  Future<JobRequest> submitProBid(String jobId, ProOffer offer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final current = _jobs[index];
      final updatedOffers = List<ProOffer>.from(current.offers)..add(offer);
      final updated = current.copyWith(offers: updatedOffers);
      _jobs[index] = updated;
      return updated;
    }
    throw Exception('İş ilanı bulunamadı: $jobId');
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_messages[jobId] ?? []);
  }

  @override
  Future<ChatMessage> sendChatMessage(String jobId, String text) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final msg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      senderId: 'u-101',
      senderName: 'Ata',
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );
    _messages.putIfAbsent(jobId, () => []).add(msg);
    return msg;
  }
}
