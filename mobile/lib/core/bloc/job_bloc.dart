import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/job_model.dart';
import '../models/offer_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/job_repository.dart';

// EVENTS
abstract class JobEvent extends Equatable {
  const JobEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomerJobsEvent extends JobEvent {
  const LoadCustomerJobsEvent();
}

class LoadJobDetailEvent extends JobEvent {
  final String jobId;
  const LoadJobDetailEvent(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class CreateJobEvent extends JobEvent {
  final JobRequest job;
  const CreateJobEvent(this.job);
  @override
  List<Object?> get props => [job];
}

class AcceptOfferEvent extends JobEvent {
  final String jobId;
  final String offerId;
  const AcceptOfferEvent({required this.jobId, required this.offerId});
  @override
  List<Object?> get props => [jobId, offerId];
}

class UpdateJobStatusEvent extends JobEvent {
  final String jobId;
  final JobStatus status;
  const UpdateJobStatusEvent({required this.jobId, required this.status});
  @override
  List<Object?> get props => [jobId, status];
}

class CompleteWorkEvent extends JobEvent {
  final String jobId;
  final String pin;
  final int rating;
  final String review;
  const CompleteWorkEvent({
    required this.jobId,
    required this.pin,
    required this.rating,
    required this.review,
  });
  @override
  List<Object?> get props => [jobId, pin, rating, review];
}

class LoadChatMessagesEvent extends JobEvent {
  final String jobId;
  const LoadChatMessagesEvent(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class SendChatMessageEvent extends JobEvent {
  final String jobId;
  final String text;
  const SendChatMessageEvent({required this.jobId, required this.text});
  @override
  List<Object?> get props => [jobId, text];
}

class LoadProJobsEvent extends JobEvent {
  const LoadProJobsEvent();
}

class SubmitProBidEvent extends JobEvent {
  final String jobId;
  final ProOffer offer;
  const SubmitProBidEvent({required this.jobId, required this.offer});
  @override
  List<Object?> get props => [jobId, offer];
}

// STATES
class JobState extends Equatable {
  final List<JobRequest> customerJobs;
  final List<JobRequest> availableProJobs;
  final JobRequest? currentJob;
  final List<ChatMessage> chatMessages;
  final bool isLoading;
  final String? errorMessage;
  final bool operationSuccess;

  const JobState({
    this.customerJobs = const [],
    this.availableProJobs = const [],
    this.currentJob,
    this.chatMessages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.operationSuccess = false,
  });

  JobRequest? get activeJob {
    try {
      return customerJobs.firstWhere(
        (j) => j.status != JobStatus.released && j.status != JobStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  JobState copyWith({
    List<JobRequest>? customerJobs,
    List<JobRequest>? availableProJobs,
    JobRequest? currentJob,
    List<ChatMessage>? chatMessages,
    bool? isLoading,
    String? errorMessage,
    bool? operationSuccess,
  }) {
    return JobState(
      customerJobs: customerJobs ?? this.customerJobs,
      availableProJobs: availableProJobs ?? this.availableProJobs,
      currentJob: currentJob ?? this.currentJob,
      chatMessages: chatMessages ?? this.chatMessages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      operationSuccess: operationSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
        customerJobs,
        availableProJobs,
        currentJob,
        chatMessages,
        isLoading,
        errorMessage,
        operationSuccess,
      ];
}

// BLOC IMPLEMENTATION
class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository repository;

  JobBloc({required this.repository}) : super(const JobState()) {
    on<LoadCustomerJobsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final jobs = await repository.getCustomerJobs();
        emit(state.copyWith(
          isLoading: false,
          customerJobs: jobs,
          currentJob: jobs.isNotEmpty ? jobs.first : null,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<LoadJobDetailEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final job = await repository.getJobById(event.jobId);
        emit(state.copyWith(isLoading: false, currentJob: job));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<CreateJobEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null, operationSuccess: false));
      try {
        final created = await repository.createJob(event.job);
        final updatedJobs = [created, ...state.customerJobs];
        emit(state.copyWith(
          isLoading: false,
          customerJobs: updatedJobs,
          currentJob: created,
          operationSuccess: true,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<AcceptOfferEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null, operationSuccess: false));
      try {
        final updated = await repository.acceptOffer(event.jobId, event.offerId);
        final updatedList = state.customerJobs.map((j) => j.id == updated.id ? updated : j).toList();
        emit(state.copyWith(
          isLoading: false,
          currentJob: updated,
          customerJobs: updatedList,
          operationSuccess: true,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<UpdateJobStatusEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final updated = await repository.updateJobStatus(event.jobId, event.status);
        final updatedList = state.customerJobs.map((j) => j.id == updated.id ? updated : j).toList();
        emit(state.copyWith(
          isLoading: false,
          currentJob: updated,
          customerJobs: updatedList,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<CompleteWorkEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null, operationSuccess: false));
      try {
        final updated = await repository.completeWork(
          event.jobId,
          event.pin,
          event.rating,
          event.review,
        );
        final updatedList = state.customerJobs.map((j) => j.id == updated.id ? updated : j).toList();
        emit(state.copyWith(
          isLoading: false,
          currentJob: updated,
          customerJobs: updatedList,
          operationSuccess: true,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<LoadChatMessagesEvent>((event, emit) async {
      try {
        final messages = await repository.getChatMessages(event.jobId);
        emit(state.copyWith(chatMessages: messages));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    });

    on<SendChatMessageEvent>((event, emit) async {
      try {
        final msg = await repository.sendChatMessage(event.jobId, event.text);
        final updatedList = [...state.chatMessages, msg];
        emit(state.copyWith(chatMessages: updatedList));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    });

    on<LoadProJobsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final available = await repository.getAvailableProJobs();
        emit(state.copyWith(isLoading: false, availableProJobs: available));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });

    on<SubmitProBidEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, operationSuccess: false));
      try {
        final updated = await repository.submitProBid(event.jobId, event.offer);
        emit(state.copyWith(
          isLoading: false,
          currentJob: updated,
          operationSuccess: true,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });
  }
}
