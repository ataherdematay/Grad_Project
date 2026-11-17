import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

/// Login with phone number + SMS code (the chosen login), through Supabase Auth.
/// Email/password and Google are kept as optional extras (not used by the current screens).
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentAuthUser => _client.auth.currentUser;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  /// Turns "0532 123 45 67", "+90 532 123 45 67" or "5321234567" into "+905321234567".
  static String normalizePhone(String input) {
    var d = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('90') && d.length == 12) return '+$d';
    if (d.startsWith('0') && d.length == 11) d = d.substring(1);
    return '+90$d';
  }

  /// Step 1: sends the 6-digit SMS code. The same call creates the account on first login.
  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: normalizePhone(phone));
  }

  /// Step 2: checks the code and logs the user in. The database trigger has already created the profile row.
  Future<void> verifyOtp(String phone, String code) async {
    await _client.auth.verifyOTP(phone: normalizePhone(phone), token: code, type: OtpType.sms);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String language = 'tr',
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      // the database trigger reads these values and creates the profile row
      data: {'first_name': firstName, 'last_name': lastName, 'preferred_lang': language, 'kvkk_accepted': 'true'},
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// [redirectTo] is the app link (deep link) Supabase returns to after Google login.
  Future<void> signInWithGoogle({String? redirectTo}) async {
    await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirectTo);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// The profile row of the logged-in user, as the app's UserModel.
  Future<UserModel?> currentProfile() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;
    final r = await _client.from('users').select().eq('id', id).maybeSingle();
    if (r == null) return null;
    return UserModel(
      id: r['id'] as String,
      firstName: (r['first_name'] ?? '') as String,
      lastName: (r['last_name'] ?? '') as String,
      phoneNumber: (r['phone_number'] ?? '') as String,
      email: (r['email'] ?? '') as String,
      role: r['role'] == 'PRO' ? UserRole.pro : UserRole.customer,
      avatarUrl: (r['avatar_url'] ?? '') as String,
      isVerified: r['status'] == 'ACTIVE',
    );
  }
}
