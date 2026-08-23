// Chompy — backend connection.
//
// Points at the local Supabase stack by default (`supabase start`). The anon key
// below is the well-known local development key printed by `supabase status` and
// is safe to commit — it only works against a local stack, never production.
//
// To target the hosted project later, swap [backendBaseUrl] for
// https://<project-ref>.supabase.co/functions/v1 and [anonKey] for the project's
// real anon key (and move the key out of source control).
class ChompyConfig {
  /// Supabase Edge Functions base URL.
  ///
  /// Current value targets local Supabase over this Mac's LAN IP, so a physical
  /// iPhone on the same Wi-Fi can reach it. Requires the iOS cleartext-HTTP
  /// exception in Info.plist (NSAllowsLocalNetworking).
  ///
  /// Other setups:
  ///   • iOS simulator / macOS desktop: `http://127.0.0.1:54321/functions/v1`
  ///   • Android emulator:              `http://10.0.2.2:54321/functions/v1`
  ///   • Physical device (this Mac):    `http://<mac-lan-ip>:54321/functions/v1`
  /// The LAN IP changes with the network — update it if Wi-Fi changes.
  static const String backendBaseUrl = 'http://192.168.1.9:54321/functions/v1';

  /// Local Supabase anon key (from `supabase status`). Sent as both the
  /// `apikey` header and, before sign-in, the `Authorization` bearer.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
}
