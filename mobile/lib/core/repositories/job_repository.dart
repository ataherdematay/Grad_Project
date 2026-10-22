import '../models/job_model.dart';
import '../models/offer_model.dart';
import '../models/chat_message_model.dart';

abstract class JobRepository {
  Future<List<JobRequest>> getCustomerJobs();
  Future<JobRequest?> getJobById(String id);
  Future<JobRequest> createJob(JobRequest job);
  Future<JobRequest> acceptOffer(String jobId, String offerId);
  Future<JobRequest> updateJobStatus(String jobId, JobStatus newStatus);
  Future<JobRequest> completeWork(String jobId, String pin, int rating, String review);
  
  // Pro methods
  Future<List<JobRequest>> getAvailableProJobs();
  Future<JobRequest> submitProBid(String jobId, ProOffer offer);
  
  // Chat methods
  Future<List<ChatMessage>> getChatMessages(String jobId);
  Future<ChatMessage> sendChatMessage(String jobId, String text);
}
