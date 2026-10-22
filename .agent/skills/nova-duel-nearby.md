# Nova: Ganit Dangal duel rules

The duel is required by the project guide and must be built with **Android Nearby Connections** (decided by the owner).

## Design
- Two phones, no internet needed. One acts as host, the other joins.
- The host generates a random seed and sends it to the other phone. Both phones build the same 10 questions from that seed with `DuelQuestionGenerator` (`lib/features/duel/duel_question_generator.dart`). Questions are never sent over the connection.
- Each phone sends a small score update when its player answers correctly.
- Keep the generator deterministic: the same seed must always give the same questions on both devices.

## Current state (as of 2026-10-22)
- The duel is mostly simulated. `DuelHostService.startHost()` is only comments, and `duel_lobby_screen.dart` fakes the connection with timers (`_mockIncomingTimer`, `Future.delayed`).
- The current code uses `flutter_blue_plus`, which only acts as a client. It is being replaced.

## Implementation rules
- Use a maintained Nearby Connections package for Flutter. Verify it is maintained and compatible with the Dart and Flutter SDK in `pubspec.yaml` before adding it, and follow its README for the Android permissions and manifest entries.
- Nearby Connections is Android-only and needs Google Play services. That is acceptable for this project. Do not try to add iOS support now.
- Remove the mock timers and simulated connection. No fake success paths.
- Remove `flutter_blue_plus` from `pubspec.yaml` once nothing uses it.
- Request runtime permissions with a clear explanation in both Marathi and English, and handle denial without crashing.
- Handle the failure cases: no peer found, connection dropped mid-duel, one player leaves.

## Testing
- Emulators cannot test this. Test on two physical Android phones.
- Add unit tests for the seed-based question generator (same seed gives the same questions).
- A task is not done until two real phones complete a duel and scores update live.
