import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SelectRoleEvent extends AuthEvent {
  final UserRole role;
  const SelectRoleEvent(this.role);
  @override
  List<Object?> get props => [role];
}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  const SendOtpEvent(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String otpCode;
  const VerifyOtpEvent(this.otpCode);
  @override
  List<Object?> get props => [otpCode];
}

class SwitchRoleEvent extends AuthEvent {
  const SwitchRoleEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// STATES
enum AuthStatus { unauthenticated, otpSent, authenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole selectedRole;
  final UserModel? user;
  final String? phoneNumber;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.selectedRole = UserRole.customer,
    this.user,
    this.phoneNumber,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isCustomer => selectedRole == UserRole.customer;
  bool get isPro => selectedRole == UserRole.pro;

  AuthState copyWith({
    AuthStatus? status,
    UserRole? selectedRole,
    UserModel? user,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedRole,
        user,
        phoneNumber,
        isLoading,
        errorMessage,
      ];
}

// BLOC IMPLEMENTATION
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<SelectRoleEvent>((event, emit) {
      emit(state.copyWith(selectedRole: event.role));
    });

    on<SendOtpEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await Future.delayed(const Duration(milliseconds: 400));
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.otpSent,
        phoneNumber: event.phoneNumber,
      ));
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await Future.delayed(const Duration(milliseconds: 500));

      final isCustomer = state.selectedRole == UserRole.customer;
      final user = UserModel(
        id: isCustomer ? 'u-101' : 'pro-201',
        firstName: isCustomer ? 'Ata' : 'Ahmet',
        lastName: isCustomer ? 'Atay' : 'Yılmaz',
        phoneNumber: state.phoneNumber ?? '+90 532 123 45 67',
        email: isCustomer ? 'ata@bitadilat.com' : 'ahmet@maviphat.com',
        role: state.selectedRole,
        avatarUrl: isCustomer
            ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'
            : 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200',
      );

      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
      ));
    });

    on<SwitchRoleEvent>((event, emit) {
      final newRole = state.selectedRole == UserRole.customer
          ? UserRole.pro
          : UserRole.customer;
      
      final updatedUser = state.user?.copyWith(
        role: newRole,
        firstName: newRole == UserRole.customer ? 'Ata' : 'Ahmet',
        lastName: newRole == UserRole.customer ? 'Atay' : 'Yılmaz',
      );

      emit(state.copyWith(
        selectedRole: newRole,
        user: updatedUser,
      ));
    });

    on<LogoutEvent>((event, emit) {
      emit(const AuthState());
    });
  }
}
