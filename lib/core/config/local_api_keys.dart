/// TEMPORARY stopgap. Do not put real keys in this file.
///
/// Keys are read at build time from `--dart-define`, for example:
///
///   flutter run \
///     --dart-define=GEMINI_API_KEY=your_key \
///     --dart-define=GROQ_API_KEY=your_key
///
/// With no keys, the online LLM calls fail and the service falls back to its
/// local offline level generator (after the request timeout), so the app still
/// builds and runs.
///
/// A key built into an app can be extracted from the APK. LLM calls are moving
/// to a backend (see docs/HANDOVER.md, task T3.6), and this file will then be
/// deleted.
class LocalApiKeys {
  LocalApiKeys._();

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
}
