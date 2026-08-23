// Chompy — thin client over the account-flow Edge Functions.
//
// Maps each onboarding stage to its function and turns the backend's structured
// error envelope ({ error: { code, message, fieldErrors, retryable } }) into a
// typed [ApiError] the UI can branch on — the design needs to tell "wrong code"
// from "expired code", and "disable, don't scold" wants field-level errors.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/food.dart';

/// A structured backend error. [code] is the machine-readable branch key
/// (e.g. `code_expired` vs `code_invalid`); [fieldErrors] carries per-field
/// validation failures without discarding entered data.
class ApiError implements Exception {
  ApiError({
    required this.code,
    required this.message,
    this.retryable = false,
    this.fieldErrors = const {},
  });

  final String code;
  final String message;
  final bool retryable;
  final Map<String, String> fieldErrors;

  /// Raised when the request never reached the backend (offline, timeout).
  factory ApiError.network() => ApiError(
        code: 'network',
        message: 'Could not reach Chompy. Check your connection.',
        retryable: true,
      );

  @override
  String toString() => 'ApiError($code): $message';
}

/// Result of a successful OTP verification.
class VerifyResult {
  VerifyResult({required this.nextStage, required this.session});

  /// `profile` (new user) or `home` (returning user).
  final String nextStage;

  /// The Supabase session — carries `access_token` / `refresh_token`.
  final Map<String, dynamic> session;

  String get accessToken => session['access_token'] as String;
}

class ChompyApi {
  ChompyApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _fn(String name) => Uri.parse('${ChompyConfig.backendBaseUrl}/$name');

  /// POST a JSON body. [bearer] overrides the anon key for authenticated calls.
  Future<Map<String, dynamic>> _post(
    String fn,
    Map<String, dynamic> body, {
    String? bearer,
  }) async {
    late http.Response res;
    try {
      res = await _client
          .post(
            _fn(fn),
            headers: {
              'Content-Type': 'application/json',
              'apikey': ChompyConfig.anonKey,
              'Authorization': 'Bearer ${bearer ?? ChompyConfig.anonKey}',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiError.network();
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiError(
        code: 'server_error',
        message: 'Something went wrong. Please try again.',
        retryable: true,
      );
    }

    if (json['error'] != null) {
      final err = json['error'] as Map<String, dynamic>;
      throw ApiError(
        code: (err['code'] ?? 'server_error') as String,
        message: (err['message'] ?? 'Something went wrong.') as String,
        retryable: (err['retryable'] ?? false) as bool,
        fieldErrors: (err['fieldErrors'] as Map?)?.map(
              (k, v) => MapEntry(k as String, v as String),
            ) ??
            const {},
      );
    }
    return json;
  }

  /// Stage 1 — request a code for [phone] (10 digits). Returns the backend's
  /// `debugCode` when the server runs with OTP_DEBUG (local dev only); null
  /// otherwise. Used purely to make the stubbed-SMS flow testable.
  Future<String?> requestOtp(String phone) async {
    final json = await _post('auth-request-otp', {'phone': phone});
    return json['debugCode'] as String?;
  }

  /// Stage 2 — verify [code] for [phone]. Throws [ApiError] with code
  /// `code_expired` or `code_invalid` on the two distinct failure paths.
  Future<VerifyResult> verifyOtp(String phone, String code) async {
    final json = await _post('auth-verify-otp', {'phone': phone, 'code': code});
    return VerifyResult(
      nextStage: json['nextStage'] as String,
      session: json['session'] as Map<String, dynamic>,
    );
  }

  /// Stage 3 — save the profile. Values are already converted to metric.
  /// Returns non-blocking warnings (e.g. implausible height/weight).
  Future<Map<String, String>> upsertProfile({
    required String accessToken,
    required String name,
    required String dateOfBirth, // 'YYYY-MM-DD'
    required String gender, // 'male' | 'female'
    required double heightCm,
    required double weightKg,
  }) async {
    final json = await _post(
      'profile-upsert',
      {
        'name': name,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'unitSystem': 'metric',
        'height': heightCm,
        'weight': weightKg,
      },
      bearer: accessToken,
    );
    return (json['warnings'] as Map?)?.map(
          (k, v) => MapEntry(k as String, v as String),
        ) ??
        const {};
  }

  // ── Food logging ─────────────────────────────────────────────────────────

  /// Extract items from typed text (also used as the stand-in for speech).
  /// Returns the review items and a time-of-day default category.
  Future<ExtractResult> mealExtractText(String accessToken, String text) async {
    final json = await _post('meal-extract', {'mode': 'text', 'text': text},
        bearer: accessToken);
    return ExtractResult.fromJson(json);
  }

  /// Extract items from a plate photo (base64, no data-URL prefix needed).
  Future<ExtractResult> mealExtractPhoto(
    String accessToken, {
    required String base64Image,
    required String mimeType,
  }) async {
    final json = await _post(
      'meal-extract',
      {'mode': 'photo', 'image': base64Image, 'mimeType': mimeType},
      bearer: accessToken,
    );
    return ExtractResult.fromJson(json);
  }

  /// Re-estimate nutrition for a single item (on add or quantity/name edit).
  Future<FoodItem> nutritionEstimate(
    String accessToken, {
    required String name,
    required num amount,
    required String unit,
  }) async {
    final json = await _post(
      'nutrition-estimate',
      {
        'item': name,
        'quantity': {'amount': amount, 'unit': unit},
      },
      bearer: accessToken,
    );
    return FoodItem(
      name: name,
      amount: amount,
      unit: unit,
      calories: json['calories'] as num?,
      foodGroup: (json['food_group'] ?? 'other') as String,
      nutrients: ((json['nutrients'] as List?) ?? const [])
          .map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
          .toList(),
      estimationFailed: (json['estimationFailed'] ?? false) as bool,
    );
  }

  /// One kid-friendly fun fact for the logged meal's items. The backend never
  /// fails this — any LLM trouble comes back as a generic fact.
  Future<String> mealFact(
    String accessToken, {
    required List<FoodItem> items,
  }) async {
    final json = await _post(
      'meal-fact',
      {
        'items': items.map((i) => '${i.name} ${i.amount} ${i.unit}'.trim()).toList(),
      },
      bearer: accessToken,
    );
    return (json['fact'] ?? '') as String;
  }

  /// Confirm & save the meal. [clientToken] makes a retried save idempotent.
  Future<void> mealLog(
    String accessToken, {
    required String category,
    required List<FoodItem> items,
    required String clientToken,
  }) async {
    await _post(
      'meal-log',
      {
        'category': category,
        'items': items.map((i) => i.toLogJson()).toList(),
        'clientToken': clientToken,
      },
      bearer: accessToken,
    );
  }
}

/// meal-extract response: the review items + a defaulted meal category.
class ExtractResult {
  ExtractResult({required this.items, required this.defaultCategory});

  final List<FoodItem> items;
  final String defaultCategory;

  factory ExtractResult.fromJson(Map<String, dynamic> json) => ExtractResult(
        items: ((json['items'] as List?) ?? const [])
            .map((i) => FoodItem.fromExtract(i as Map<String, dynamic>))
            .toList(),
        defaultCategory: (json['defaultCategory'] ?? 'snacks') as String,
      );
}
