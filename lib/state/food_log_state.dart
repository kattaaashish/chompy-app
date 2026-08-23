// Food-logging state machine. Like onboarding, one `screen` is the source of
// truth; when it's `none`, Home shows. Nothing is saved until confirm (spec §3):
// add / remove / edit all happen on the in-memory item list first.

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../api/chompy_api.dart';
import '../models/food.dart';
import '../theme.dart';

enum FoodScreen {
  none, // Home
  mode,
  cancelled,
  text,
  speak,
  detecting,
  review,
  saving,
  fact,
  saved,
  failed,
}

class FoodLogState extends ChangeNotifier {
  FoodLogState({ChompyApi? api}) : _api = api ?? ChompyApi();

  final ChompyApi _api;

  /// Injected from the onboarding session via a proxy provider.
  String? accessToken;
  void updateToken(String? token) => accessToken = token;

  FoodScreen _screen = FoodScreen.none;
  FoodScreen get screen => _screen;
  void _go(FoodScreen s) {
    _screen = s;
    notifyListeners();
  }

  // ── The meal under construction ──────────────────────────────────────────
  String _entryMode = 'text'; // photo | text | speak
  String get entryMode => _entryMode;

  String _typedText = '';
  String get typedText => _typedText;
  void setTypedText(String v) {
    _typedText = v;
    notifyListeners();
  }

  List<FoodItem> _items = [];
  List<FoodItem> get items => List.unmodifiable(_items);

  String _category = 'snacks';
  String get category => _category;
  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  int _factIndex = 0;
  int get factIndex => _factIndex;
  FoodItem? get currentFactItem =>
      _items.isEmpty ? null : _items[_factIndex.clamp(0, _items.length - 1)];

  String _clientToken = '';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Home: first-run tip + logged meals ─────────────────────────────────────
  bool _tipVisible = true;
  bool get tipVisible => _tipVisible;
  void openTip() {
    _tipVisible = true;
    notifyListeners();
  }

  void dismissTip() {
    _tipVisible = false;
    notifyListeners();
  }

  final List<LoggedMeal> _mealsToday = [];
  List<LoggedMeal> get mealsToday => List.unmodifiable(_mealsToday);
  int get mealCount => _mealsToday.length;

  /// Most recent logged meal for a display category row.
  LoggedMeal? mealFor(String backendCategory) {
    for (final m in _mealsToday.reversed) {
      if (m.category == backendCategory) return m;
    }
    return null;
  }

  // ── Entering / choosing a path ─────────────────────────────────────────────
  void startFlow() {
    _items = [];
    _typedText = '';
    _factIndex = 0;
    _errorMessage = null;
    _clientToken = _newToken();
    _go(FoodScreen.mode);
  }

  void pickText() {
    _entryMode = 'text';
    _errorMessage = null;
    _go(FoodScreen.text);
  }

  void pickSpeak() {
    _entryMode = 'speak';
    _errorMessage = null;
    _go(FoodScreen.speak);
  }

  /// Photo capture was cancelled — not an error (design §15).
  void captureCancelled() {
    _entryMode = 'photo';
    _go(FoodScreen.cancelled);
  }

  void backToMode() => _go(FoodScreen.mode);

  void exitToHome() {
    _screen = FoodScreen.none;
    notifyListeners();
  }

  // ── Detection (Stage 1+2) ──────────────────────────────────────────────────
  Future<void> submitText() async {
    _entryMode = 'text';
    await _detect(() => _api.mealExtractText(accessToken!, _typedText.trim()));
  }

  Future<void> submitSpeech(String transcript) async {
    _entryMode = 'speak';
    _typedText = transcript;
    await _detect(() => _api.mealExtractText(accessToken!, transcript.trim()));
  }

  Future<void> submitPhoto(
      {required String base64Image, required String mimeType}) async {
    _entryMode = 'photo';
    await _detect(() => _api.mealExtractPhoto(accessToken!,
        base64Image: base64Image, mimeType: mimeType));
  }

  Future<void> _detect(Future<ExtractResult> Function() call) async {
    _errorMessage = null;
    _go(FoodScreen.detecting);
    try {
      final results = await Future.wait([
        call(),
        Future<void>.delayed(ChompyDurations.detectFood),
      ]);
      final res = results.first as ExtractResult;
      _items = res.items;
      _category = res.defaultCategory;
      _go(FoodScreen.review);
    } on ApiError catch (e) {
      // No dedicated "detection failed" screen: land on review empty so the
      // child can add items by hand, with a gentle note (spec §2).
      _items = [];
      _errorMessage = e.message;
      _go(FoodScreen.review);
    }
  }

  // ── Review edits (Stage 3) ─────────────────────────────────────────────────
  bool get canConfirm => _items.isNotEmpty;

  void removeItem(int index) {
    _items = [..._items]..removeAt(index);
    notifyListeners();
  }

  /// Change quantity by [delta] (min 1). Re-estimates nutrition in the
  /// background so the saved data stays correct; the numbers stay hidden.
  void changeQuantity(int index, num delta) {
    final item = _items[index];
    final next = (item.amount + delta);
    if (next < 1) return;
    _items = [..._items];
    _items[index] = item.copyWith(amount: next);
    notifyListeners();
    _reestimate(index);
  }

  /// Add a liked food by name; estimate its nutrition in the background.
  void addFood(String name) {
    _items = [..._items, FoodItem(name: name, amount: 1, unit: 'piece')];
    notifyListeners();
    _reestimate(_items.length - 1);
  }

  Future<void> _reestimate(int index) async {
    if (accessToken == null || index < 0 || index >= _items.length) return;
    final item = _items[index];
    try {
      final updated = await _api.nutritionEstimate(accessToken!,
          name: item.name, amount: item.amount, unit: item.unit);
      // The item may have moved/changed while we waited — match by identity.
      final at = _items.indexOf(item);
      if (at != -1) {
        _items = [..._items];
        _items[at] = updated;
        notifyListeners();
      }
    } on ApiError {
      // Leave the item as-is; nutrition can be blank (spec §3).
    }
  }

  // ── Confirm & save (Stage 4) ───────────────────────────────────────────────
  Future<void> confirm() async {
    if (!canConfirm || accessToken == null) return;
    _errorMessage = null;
    _go(FoodScreen.saving);
    try {
      await Future.wait([
        _api.mealLog(accessToken!,
            category: _category, items: _items, clientToken: _clientToken),
        Future<void>.delayed(ChompyDurations.saveMeal),
      ]);
      _mealsToday.add(LoggedMeal(category: _category, items: _items));
      _factIndex = 0;
      _go(FoodScreen.fact);
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _go(FoodScreen.failed);
    }
  }

  /// Retry a failed save — same clientToken, so the backend dedupes it.
  Future<void> retrySave() => confirm();

  void backToReview() => _go(FoodScreen.review);

  void nextFact() {
    if (_factIndex < _items.length - 1) {
      _factIndex++;
      notifyListeners();
    } else {
      _go(FoodScreen.saved);
    }
  }

  bool get hasMoreFacts => _factIndex < _items.length - 1;

  static String _newToken() {
    final r = Random();
    final a = r.nextInt(1 << 32).toRadixString(16);
    final b = r.nextInt(1 << 32).toRadixString(16);
    return 'chompy-$a-$b';
  }
}
