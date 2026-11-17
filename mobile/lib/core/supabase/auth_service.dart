import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

/// Login with email + password or Google (Supabase Auth). Not connected to the screens yet:
/// the current welcome/phone/SMS screens still follow the phone-number design (see docs/BACKEND_STATUS.md).
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentAuthUser => _client.auth.currentUser;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

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
