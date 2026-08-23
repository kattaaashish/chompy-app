# Chompy — Flutter app

Mobile app that helps a 7-year-old (Dhruv) log meals and build the habit of eating
varied, balanced food, with a parent (Aashish) getting visibility later. Single
account; the child operates the device. Built to the `design_handoff_chompy_v0`
spec (24 states) and wired to the `chompy-backend` Supabase Edge Functions.

## Status

| Area | State |
| --- | --- |
| Onboarding (welcome → phone → OTP → profile → home) | ✅ built, backend-wired |
| Home | ✅ built (food-group columns intentionally dropped — see Decisions) |
| Food logging (photo / type / speak → detect → review → save → fun-fact → logged / failed) | ✅ built, backend-wired |
| Progress (today / week) | ❌ not built — it's 100% food-group based, dropped with grouping |
| Parent-facing screens (dashboard, goals, liked-foods mgmt, log editing) | ❌ out of scope per handoff ("not yet designed — don't invent") |

Analyzer clean; one widget smoke test in `test/widget_test.dart`.

## Architecture

- **State**: `provider` + `ChangeNotifier`. Two state machines, each with a
  `screen` enum as the single source of truth:
  - `state/onboarding_state.dart` (`Screen`): welcome → phone → sending → otp →
    verifying → profile → home. Holds the Supabase session `accessToken`.
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
- `models/food.dart` — `FoodItem`, `Nutrient`, `LoggedMeal`.

## Backend wiring (chompy-backend Supabase Edge Functions)

Config in `config.dart` (`backendBaseUrl` + local dev `anonKey`).

| Flow step | Endpoint |
| --- | --- |
| Phone → send code | `POST auth-request-otp {phone}` (dev echoes `debugCode`) |
| OTP → verify | `POST auth-verify-otp {phone, code}` → `{nextStage, session}` |
| Profile submit | `POST profile-upsert` (Bearer) → `{nextStage: home}` |
| Detect (text/speech/photo) | `POST meal-extract {mode, text|image}` → items + nutrition + `defaultCategory` |
| Add / edit item | `POST nutrition-estimate {item, quantity}` |
| Confirm & save | `POST meal-log {category, items, clientToken}` (idempotent retry) |

Calories/nutrients ride in the data model and reach the backend but are **never
shown** in the child UI (design "no numbers" rule).

## Running it

Backend must be up: `cd ../chompy-backend && supabase start` (functions run with
`OTP_DEBUG=true`, so the OTP screen shows a dev "tap to fill" banner in debug builds;
SMS is stubbed — no real text is sent).

- **iOS Simulator / macOS**: set `backendBaseUrl` to `http://127.0.0.1:54321/functions/v1`.
- **Android emulator**: `http://10.0.2.2:54321/functions/v1`.
- **Physical iPhone (talking to this Mac's local stack)**: set `backendBaseUrl` to
  `http://<mac-lan-ip>:54321/functions/v1` (currently `192.168.1.9`). Phone + Mac on
  the same Wi-Fi. `ios/Runner/Info.plist` carries the required dev-only ATS exception
  (`NSAllowsLocalNetworking`) + `NSLocalNetworkUsageDescription`. Update the IP when
  the network changes. Info.plist changes need a full rebuild, not hot reload.
- **Camera**: real camera on device; on the simulator `image_picker` falls back to
  the photo library (no camera hardware).

## Decisions (deviations from the handoff, agreed with product)

- **Food grouping dropped** from the UI. No group columns on Home, no per-item group
  label; the review card shows the item's **initial** as a neutral avatar tile. This
  also removed Progress and the Logged "New today" group blocks. To bring it back
  cleanly, extend `meal-extract` to return a `food_group` per item.
- **Gender**: two pills Boy/Girl → backend `male`/`female` ("Other" dropped, backend
  only accepts two).
- **Profile submit** gated on ALL fields (name, DOB, gender, height, weight) with a
  "what's missing" label, so a submit can't be server-rejected ("disable, don't scold").
  Design gated on name+DOB only.
- **Height/weight** converted client-side to metric; backend takes one `unitSystem`.
- **Photo & Speak are real** (image_picker + speech_to_text), not the design's
  placeholder camera.

## Known gaps / next up

- **Session resume**: session isn't persisted; a restart returns to Welcome. Backend
  has `session-state` to drive resume — not wired.
- **Home "Meals today"** reflects only meals logged in the current session; it doesn't
  fetch the day's meals from the backend on launch.
- **Rename an item** in Review isn't supported (quantity change / remove / add only).
- **Dev-only bits to remove before shipping**: local `anonKey` + LAN IP in `config.dart`,
  the Info.plist ATS exception, and the debug OTP banner (already `kDebugMode`-gated).
