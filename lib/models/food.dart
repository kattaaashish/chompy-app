// Food-logging data model. Every item carries calories + a nutrient breakdown
// (spec §6) — these ride along in the data model and reach the backend, but are
// never shown in Dhruv's UI (design "no numbers" rule).

class Nutrient {
  const Nutrient({required this.type, required this.value, required this.unit});

  final String type;
  final num value;
  final String unit;

  factory Nutrient.fromJson(Map<String, dynamic> j) => Nutrient(
        type: (j['nutrient_type'] ?? '') as String,
        value: (j['value'] ?? 0) as num,
        unit: (j['unit'] ?? '') as String,
      );

  Map<String, dynamic> toJson() =>
      {'nutrient_type': type, 'value': value, 'unit': unit};
}

class FoodItem {
  FoodItem({
    required this.name,
    required this.amount,
    required this.unit,
    this.calories,
    this.foodGroup = 'other',
    this.nutrients = const [],
    this.estimationFailed = false,
  });

  final String name;
  final num amount;
  final String unit;
  final num? calories;

  /// Food group the backend classified this item into (grains_cereals,
  /// pulses_legumes, milk_dairy, vegetables, fruits, nuts_seeds, egg_meat_fish,
  /// fats_oils, other). Rides along in the data model — not shown in the child UI
  /// — and is sent back on save so it persists (dimension-2 assessment).
  final String foodGroup;

  final List<Nutrient> nutrients;
  final bool estimationFailed;

  /// First letter of the item, for the neutral avatar tile (food grouping was
  /// dropped, so the tile is decorative, not a group signal).
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  factory FoodItem.fromExtract(Map<String, dynamic> j) {
    final q = (j['quantity'] as Map?) ?? const {};
    return FoodItem(
      name: (j['item'] ?? '') as String,
      amount: (q['amount'] ?? 1) as num,
      unit: (q['unit'] ?? 'serving') as String,
      calories: j['calories'] as num?,
      foodGroup: (j['food_group'] ?? 'other') as String,
      nutrients: ((j['nutrients'] as List?) ?? const [])
          .map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
          .toList(),
      estimationFailed: (j['estimationFailed'] ?? false) as bool,
    );
  }

  FoodItem copyWith({
    String? name,
    num? amount,
    String? unit,
    num? calories,
    String? foodGroup,
    List<Nutrient>? nutrients,
    bool? estimationFailed,
  }) =>
      FoodItem(
        name: name ?? this.name,
        amount: amount ?? this.amount,
        unit: unit ?? this.unit,
        calories: calories ?? this.calories,
        foodGroup: foodGroup ?? this.foodGroup,
        nutrients: nutrients ?? this.nutrients,
        estimationFailed: estimationFailed ?? this.estimationFailed,
      );

  /// Shape meal-log expects for each item ({name, quantity:{amount,unit}, ...}).
  Map<String, dynamic> toLogJson() => {
        'name': name,
        'quantity': {'amount': amount, 'unit': unit},
        'calories': calories,
        'food_group': foodGroup,
        'nutrients': nutrients.map((n) => n.toJson()).toList(),
      };
}

/// A meal after it's been saved — used to populate Home's "Meals today".
class LoggedMeal {
  LoggedMeal({required this.category, required this.items});

  /// Backend category, lowercase: breakfast | lunch | dinner | snacks.
  final String category;
  final List<FoodItem> items;

  String get summary => items.map((i) => i.name).join(', ');
}

/// A day's ledger as returned by `nutrition-day`.
class DayLedger {
  DayLedger({required this.date, required this.meals});

  /// IST day key, 'YYYY-MM-DD'.
  final String date;
  final List<LoggedMeal> meals;
}
