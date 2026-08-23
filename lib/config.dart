// Chompy — backend connection.
//
// Values are injected at BUILD TIME via --dart-define (see config/*.json), so you
// never edit this file to switch between local dev and the hosted project. Pick an
// environment by passing its file:
//
//   Local dev:  flutter run --dart-define-from-file=config/local.json
//   Hosted:     flutter run --release --dart-define-from-file=config/remote.json
//
// A bare `flutter run` (no file) falls back to the local defaults below.
class ChompyConfig {
  /// Supabase Edge Functions base URL.
  ///   • Local (this Mac's LAN IP): `http://<mac-lan-ip>:54321/functions/v1`
  ///   • Hosted: `https://<project-ref>.supabase.co/functions/v1`
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://192.168.1.9:54321/functions/v1',
  );

  /// Supabase anon / publishable key. Sent as the `apikey` header and, before
  /// sign-in, as the `Authorization` bearer. Public by design (safe in a client).
  static const String anonKey = String.fromEnvironment(
    'ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );
}
