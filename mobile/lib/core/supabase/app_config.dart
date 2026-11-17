/// Supabase settings, passed at build time so no key is stored in the code:
///
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// If both are empty the app keeps using the mock (fake) data, exactly as before.
/// Only the public "anon" key belongs here. NEVER put the service_role key or the database password in the app.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get useSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
