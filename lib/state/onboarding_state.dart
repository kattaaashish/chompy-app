// Chompy — onboarding state. `screen` is the single source of truth; every
// transition in the account flow (welcome → phone → sending → otp → verifying →
// profile → home) runs through here, so the widgets stay dumb.
//
// Loading screens hold for their nominal design duration AND until the backend
// answers, whichever is longer — the determinate bar reads as a real wait, never
// a flash. `disable, don't scold`: submit gates are computed here and the UI
// only enables when the backend can't reject.

import 'package:flutter/foundation.dart';

import '../api/chompy_api.dart';
import '../strings.dart';
import '../theme.dart';

enum Screen { welcome, phone, sending, otp, verifying, profile, home }

/// The two OTP failure paths must never share a message (design + spec §3).
enum OtpError { none, wrong, expired }

class OnboardingState extends ChangeNotifier {
  OnboardingState({ChompyApi? api}) : _api = api ?? ChompyApi();

  final ChompyApi _api;

  Screen _screen = Screen.welcome;
  Screen get screen => _screen;

  void _go(Screen s) {
    _screen = s;
    notifyListeners();
  }

  /// Welcome → phone.
  void goToPhone() => _go(Screen.phone);

  // ── Phone ──────────────────────────────────────────────────────────────
  String _phone = '';
  String get phone => _phone;

  /// Non-digits stripped, capped at 10 (design §2).
  void setPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    _phone = digits.length > 10 ? digits.substring(0, 10) : digits;
    _sendError = null;
    notifyListeners();
  }

  bool get phoneValid => _phone.length == 10;

  /// Displayed as `98765 43210`.
  String get phoneFormatted =>
      _phone.length <= 5 ? _phone : '${_phone.substring(0, 5)} ${_phone.substring(5)}';

  String? _sendError;
  String? get sendError => _sendError;

  Future<void> submitPhone() async {
    if (!phoneValid) return;
    _sendError = null;
    _go(Screen.sending);
    try {
      final results = await Future.wait([
        _api.requestOtp(_phone),
        Future<void>.delayed(ChompyDurations.sendOtp),
      ]);
      _debugOtpCode = results.first as String?;
      _otp = '';
      _otpError = OtpError.none;
      _go(Screen.otp);
    } on ApiError catch (e) {
      // Send failure is retryable — return to phone with the reason (spec §2).
      _sendError = e.message;
      _go(Screen.phone);
    }
  }

  // ── OTP ────────────────────────────────────────────────────────────────
  String _otp = '';
  String get otp => _otp;

  OtpError _otpError = OtpError.none;
  OtpError get otpError => _otpError;

  /// Debug-only: the code echoed by the backend so the stubbed-SMS flow is
  /// testable. Surfaced on the OTP screen in debug builds only.
  String? _debugOtpCode;
  String? get debugOtpCode => _debugOtpCode;

  void setOtp(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    _otp = digits.length > 6 ? digits.substring(0, 6) : digits;
    notifyListeners();
  }

  bool get otpValid => _otp.length == 6;

  /// There is no resend in v0 — recovery from any OTP error is re-entering the
  /// number, so this clears the code and returns to phone entry (design §5/6).
  void changePhoneNumber() {
    _otp = '';
    _otpError = OtpError.none;
    // A fresh PhoneScreen starts with an empty field; clear the stored number
    // so state and UI agree and the user re-enters it (the only recovery).
    _phone = '';
    _sendError = null;
    _go(Screen.phone);
  }

  Future<void> submitOtp() async {
    if (!otpValid) return;
    _go(Screen.verifying);
    try {
      final results = await Future.wait([
        _api.verifyOtp(_phone, _otp),
        Future<void>.delayed(ChompyDurations.verifyOtp),
      ]);
      final verify = results.first as VerifyResult;
      _accessToken = verify.accessToken;
      _otpError = OtpError.none;
      // Returning user → home; new registration → profile.
      _go(verify.nextStage == 'home' ? Screen.home : Screen.profile);
    } on ApiError catch (e) {
      _otpError = e.code == 'code_expired' ? OtpError.expired : OtpError.wrong;
      _otp = '';
      _go(Screen.otp);
    }
  }

  // ── Session ──────────────────────────────────────────────────────────────
  String? _accessToken;
  String? get accessToken => _accessToken;

  // ── Profile ──────────────────────────────────────────────────────────────
  String _name = '';
  String get name => _name;
  set name(String v) {
    _name = v;
    _profileError = null;
    notifyListeners();
  }

  DateTime? _dob;
  DateTime? get dob => _dob;
  set dob(DateTime? v) {
    _dob = v;
    _profileError = null;
    notifyListeners();
  }

  /// 'Boy' | 'Girl' (design). Mapped to the backend's male/female on submit.
  String? _gender;
  String? get gender => _gender;
  set gender(String? v) {
    _gender = v;
    _profileError = null;
    notifyListeners();
  }

  // Height / weight carry a value and an in-place unit toggle (design §8).
  double? _heightValue;
  double? get heightValue => _heightValue;
  set heightValue(double? v) {
    _heightValue = v;
    _profileError = null;
    notifyListeners();
  }

  String _heightUnit = 'cm'; // 'cm' | 'in'
  String get heightUnit => _heightUnit;
  void toggleHeightUnit() {
    _heightUnit = _heightUnit == 'cm' ? 'in' : 'cm';
    notifyListeners();
  }

  double? _weightValue;
  double? get weightValue => _weightValue;
  set weightValue(double? v) {
    _weightValue = v;
    _profileError = null;
    notifyListeners();
  }

  String _weightUnit = 'kg'; // 'kg' | 'lb'
  String get weightUnit => _weightUnit;
  void toggleWeightUnit() {
    _weightUnit = _weightUnit == 'kg' ? 'lb' : 'kg';
    notifyListeners();
  }

  /// Supported age band is 5–12 (backend validation). Enforced client-side so
  /// a valid-looking submit can never be rejected for age.
  static const int minAge = 5;
  static const int maxAge = 12;

  bool get _dobValid {
    final d = _dob;
    if (d == null) return false;
    final now = DateTime.now();
    if (d.isAfter(now)) return false;
    var age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) age--;
    return age >= minAge && age <= maxAge;
  }

  bool get _nameValid => _name.trim().isNotEmpty;
  bool get _genderValid => _gender == 'Boy' || _gender == 'Girl';
  bool get _heightValid => (_heightValue ?? 0) > 0;
  bool get _weightValid => (_weightValue ?? 0) > 0;

  /// Backend needs every field, so we gate on all of them (per product call:
  /// "require all fields"). No submit can round-trip to a rejection.
  bool get profileComplete =>
      _nameValid && _dobValid && _genderValid && _heightValid && _weightValid;

  /// "Disable, don't scold": the submit label names exactly what's still
  /// missing, rather than letting a submit fail. Design ships two canonical
  /// labels; because we gate on every field, we name whichever are absent.
  String get profileCtaLabel {
    if (profileComplete) return ChompyStrings.profileCtaReady;
    final missing = <String>[
      if (!_nameValid) 'name',
      if (!_dobValid) 'birthday',
      if (!_genderValid) 'gender',
      if (!_heightValid) 'height',
      if (!_weightValid) 'weight',
    ];
    // The two default-field case matches the design's verbatim copy.
    if (missing.length == 2 && missing[0] == 'name' && missing[1] == 'birthday') {
      return ChompyStrings.profileCtaIncomplete;
    }
    return 'Add ${_naturalJoin(missing)}';
  }

  static String _naturalJoin(List<String> items) {
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items[0]} and ${items[1]}';
    final head = items.sublist(0, items.length - 1).join(', ');
    return '$head and ${items.last}';
  }

  bool _profileSubmitting = false;
  bool get profileSubmitting => _profileSubmitting;

  String? _profileError;
  String? get profileError => _profileError;

  double get _heightCm =>
      _heightUnit == 'cm' ? _heightValue! : _heightValue! * 2.54;
  double get _weightKg =>
      _weightUnit == 'kg' ? _weightValue! : _weightValue! * 0.45359237;

  Future<void> submitProfile() async {
    if (!profileComplete || _profileSubmitting || _accessToken == null) return;
    _profileSubmitting = true;
    _profileError = null;
    notifyListeners();
    try {
      final dob = _dob!;
      final dobStr = '${dob.year.toString().padLeft(4, '0')}-'
          '${dob.month.toString().padLeft(2, '0')}-'
          '${dob.day.toString().padLeft(2, '0')}';
      await _api.upsertProfile(
        accessToken: _accessToken!,
        name: _name.trim(),
        dateOfBirth: dobStr,
        gender: _gender == 'Boy' ? 'male' : 'female',
        heightCm: double.parse(_heightCm.toStringAsFixed(1)),
        weightKg: double.parse(_weightKg.toStringAsFixed(1)),
      );
      _profileSubmitting = false;
      _go(Screen.home);
    } on ApiError catch (e) {
      _profileSubmitting = false;
      _profileError = e.message;
      notifyListeners();
    }
  }
}
