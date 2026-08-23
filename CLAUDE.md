# Chompy — Flutter app

Mobile app that helps a 7-year-old (Dhruv) log meals and build the habit of eating
varied, balanced food, with a parent (Aashish) getting visibility later. Single
account; the child operates the device. Built to the `design_handoff_chompy_v0`
spec (24 states) and wired to the `chompy-backend` Supabase Edge Functions.

## Status

| Area | State |
| --- | --- |
| Onboarding (welcome → phone → OTP → profile → home) | ✅ built, backend-wired |
| Session resume (persist + restore across restarts) | ✅ built — `flutter_secure_storage`, 30-day inactivity window |
| Home | ✅ built; fetches the day's meals from `nutrition-day` on launch (food-group columns still dropped — see Decisions) |
| Food logging (photo / type / speak → detect → review → save → fun-fact → logged / failed) | ✅ built, backend-wired |
| Progress (today / week) | ❌ not built — it's 100% food-group based, dropped with grouping |
| Parent-facing screens (dashboard, goals, liked-foods mgmt, log editing) | ❌ out of scope per handoff ("not yet designed — don't invent") |

Analyzer clean; one widget smoke test in `test/widget_test.dart`.

## Architecture

- **State**: `provider` + `ChangeNotifier`. Two state machines, each with a
  `screen` enum as the single source of truth:
  - `state/onboarding_state.dart` (`Screen`): restoring → welcome → phone → sending →
    otp → verifying → profile → home. Holds the Supabase session (access + refresh
    tokens); persists it via `flutter_secure_storage` and runs `restoreSession()` at
    startup (the `restoring` screen) to resume — refreshing an expired access token once
    and asking `session-state` which stage to land on. 30-day inactivity window.
  - `state/food_log_state.dart` (`FoodScreen`): none(=Home) → mode → cancelled /
    text / speak → detecting → review → saving → fact → saved / failed. Gets the
    `accessToken` injected from `OnboardingState` via a `ChangeNotifierProxyProvider`.
- **Root** (`main.dart`): while onboarding ≠ home, render the onboarding screen;
  once home, render Home or the current food-logging screen. Transitions via
  `AnimatedSwitcher` keyed on the active screen.
- **API** (`api/chompy_api.dart`): thin client over the Edge Functions. Backend
  errors come back as a typed `ApiError` with a machine `code` (e.g. `code_expired`
  vs `code_invalid`) so the UI can branch and honour "wrong ≠ expired".
- **Design tokens** (`theme.dart`) and **all copy** (`strings.dart`) are copied
  verbatim from the handoff. Rule: no `Color(0xFF…)`/`TextStyle(…)` inline, no
  user-facing strings inline — everything routes through these two files.
- **Loading pattern** (`widgets/loading_view.dart`): one shared determinate bar
  (6%→96% over the nominal wait). Never a spinner — reads as "stuck" to a child.
  Loading screens hold for the design duration AND until the backend answers.
- **Mascot** (`widgets/mascot.dart`): an irregular terracotta blob with a bite +
  eyes, built from geometry (no assets). Pulses / blinks.

### File map
- `screens/` — onboarding: `welcome`, `phone`, `otp`, `profile`, `loading_screens`.
- `screens/food/` — logging flow: `mode`, `cancelled`, `type`, `speak`,
  `food_loading` (detecting + saving), `review`, `fact`, `logged`, `failed`.
- `screens/home_screen.dart` — the real Home.
- `screens/home_placeholder.dart` — **dead code** (superseded by `home_screen.dart`); safe to delete.
- `widgets/common.dart` — `PrimaryCta`, `SelectPill`, `ErrorBlock`, `SoftCard`,
  `LetterTile`, `BackPill`, `Kicker`, `GhostLink`, `screenPaddingOf`.
- `models/food.dart` — `FoodItem` (carries `foodGroup`), `Nutrient`, `LoggedMeal`, `DayLedger`.

## Backend wiring (chompy-backend Supabase Edge Functions)

Backend URL + anon key are injected at **build time** (see Running it), not edited in
`config.dart` — `ChompyConfig` reads them via `String.fromEnvironment` with local defaults.

| Flow step | Endpoint |
| --- | --- |
| Phone → send code | `POST auth-request-otp {phone}` (dev echoes `debugCode`) |
| OTP → verify | `POST auth-verify-otp {phone, code}` → `{nextStage, session}` |
| Resume stage | `POST session-state` (Bearer) → `{stage}`; token refresh via `/auth/v1/token` |
| Profile submit | `POST profile-upsert` (Bearer) → `{nextStage: home}` |
| Detect (text/speech/photo) | `POST meal-extract {mode, text|image}` → items (+ `food_group`) + nutrition + `defaultCategory` |
| Add / edit item | `POST nutrition-estimate {item, quantity}` → calories + `food_group` + nutrients |
| Confirm & save | `POST meal-log {category, items, clientToken}` (idempotent retry) |
| Day's meals | `POST nutrition-day` (Bearer) → `DayLedger` (loaded on Home launch) |
| Fun fact | `POST meal-fact {items}` → one kid-friendly fact (fact screen) |

Calories/nutrients and each item's `food_group` ride in the data model and reach the
backend but are **never shown** in the child UI (design "no numbers" rule).

## Running it

Backend must be reachable — either local (`cd ../chompy-backend && supabase start`, with
`OTP_DEBUG=true` so the OTP screen shows a dev "tap to fill" banner in debug builds; SMS is
stubbed) or the hosted project.

**Pick the environment with a build-time flag** — no editing `config.dart`:
```
flutter run --dart-define-from-file=config/local.json    # local stack (default if flag omitted)
flutter run --release --dart-define-from-file=config/remote.json   # hosted project
```
- `config/local.json` — LAN IP (currently `192.168.1.9`) + local anon key. Update the IP when
  the Wi-Fi network changes (only matters for a physical device on the local stack).
- `config/remote.json` — `https://advpsqkorrpjhbmiuimd.supabase.co/functions/v1` + publishable key.
- Both keys are public-by-design (safe to commit).
- Shell aliases exist in `~/.zshrc`: `chompy-app-local-run` and `chompy-app-release` (target the
  configured iPhone device id).

Per-target base URL (set in the config file): iOS Simulator / macOS →
`http://127.0.0.1:54321/functions/v1`; Android emulator → `http://10.0.2.2:54321/functions/v1`;
physical iPhone on the local stack → `http://<mac-lan-ip>:54321/functions/v1`.

- **Physical iPhone + local stack** uses cleartext HTTP, so `ios/Runner/Info.plist` carries the
  dev-only ATS exception (`NSAllowsLocalNetworking` + `NSLocalNetworkUsageDescription`). Not needed
  against the hosted HTTPS project. Info.plist changes need a full rebuild, not hot reload.
- **Untethered install (iPhone)**: `flutter run --release …` installs + launches; then unplug and it
  runs standalone. First run needs Xcode signing (Team + bundle id). ⚠️ On a release/profile build the
  debug "tap to fill" OTP banner is hidden (`kDebugMode`-gated) — since SMS is stubbed, use a debug
  build with server `OTP_DEBUG=true` (master code `987654`) to sign in, until real SMS is wired.
- **Camera**: real camera on device; on the simulator `image_picker` falls back to the photo library.

## Decisions (deviations from the handoff, agreed with product)

- **Food grouping dropped from the UI** (still). No group columns on Home, no per-item group
  label; the review card shows the item's **initial** as a neutral avatar tile. This also removed
  Progress and the Logged "New today" group blocks. Note: `meal-extract` now *does* return a
  `food_group` per item and the model carries + persists it (`FoodItem.foodGroup` → `meal-log`) —
  it's captured for future use but deliberately not shown to the child.
- **Gender**: two pills Boy/Girl → backend `male`/`female` ("Other" dropped, backend
  only accepts two).
- **Profile submit** gated on ALL fields (name, DOB, gender, height, weight) with a
  "what's missing" label, so a submit can't be server-rejected ("disable, don't scold").
  Design gated on name+DOB only.
- **Height/weight** converted client-side to metric; backend takes one `unitSystem`.
- **Photo & Speak are real** (image_picker + speech_to_text), not the design's
  placeholder camera.

## Known gaps / next up

- **`nutrition-day` drops `food_group`**: `ChompyApi.nutritionDay` builds `FoodItem`s without
  reading `i['food_group']`, so meals loaded from the day ledger default to `other`. Harmless today
  (the group isn't shown), but fix when the group is used — mirror `fromExtract`.
- **Rename an item** in Review isn't supported (quantity change / remove / add only).
- **Liked foods** on the Review screen are hardcoded strings — no backend fetch/sync.
- **Dev-only bits to remove before shipping**: LAN IP + local key in `config/local.json`, the
  Info.plist ATS exception, and the debug OTP banner (already `kDebugMode`-gated).

Recently closed: session resume (persisted + restored), Home now loads the day's meals from
`nutrition-day` on launch, and the meal fun-fact (`meal-fact`).
