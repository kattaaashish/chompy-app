import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/food.dart';
import '../state/food_log_state.dart';
import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

/// Home (food-group columns dropped per product call). Header greeting + status,
/// the one primary "Log a meal" action, the help affordances, and today's meals.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Display row → backend category key.
  static const _rows = [
    ('Breakfast', 'breakfast'),
    ('Lunch', 'lunch'),
    ('Snack', 'snacks'),
    ('Dinner', 'dinner'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final name = context.select<OnboardingState, String>((s) => s.name);
    final food = context.watch<FoodLogState>();
    final pad = screenPaddingOf(context);
    final dateKicker = DateFormat('EEE, d MMM').format(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s8),
        children: [
          // Header.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker(dateKicker),
                    const SizedBox(height: ChompySpace.s2),
                    Text(ChompyStrings.greeting(name), style: t.headlineLarge),
                    const SizedBox(height: ChompySpace.s1),
                    Text(
                      ChompyStrings.homeStatus(food.mealCount),
                      style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ChompySpace.s3),
              const Mascot(size: 56, shadow: ChompyShape.shadowSm),
            ],
          ),
          const SizedBox(height: ChompySpace.s6),

          // Primary action.
          _LogMealCard(onTap: () => context.read<FoodLogState>().startFlow()),
          const SizedBox(height: ChompySpace.s3),

          // Secondary row: progress + help.
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress is coming soon.')),
                  ),
                  child: Text(ChompyStrings.homeProgress),
                ),
              ),
              const SizedBox(width: ChompySpace.s2),
              _HelpPill(onTap: () => context.read<FoodLogState>().openTip()),
            ],
          ),

          if (food.tipVisible) ...[
            const SizedBox(height: ChompySpace.s4),
            _TipCard(onDismiss: () => context.read<FoodLogState>().dismissTip()),
          ],

          const SizedBox(height: ChompySpace.s6),
          Text(ChompyStrings.homeMeals, style: t.headlineMedium),
          const SizedBox(height: ChompySpace.s3),
          for (final (label, key) in _rows)
            _MealRow(label: label, meal: food.mealFor(key)),
        ],
      ),
    );
  }
}

class _LogMealCard extends StatelessWidget {
  const _LogMealCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: ChompyColors.accent,
      borderRadius: ChompyShape.cardRadius,
      child: InkWell(
        borderRadius: ChompyShape.cardRadius,
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: ChompyShape.cardRadius,
            boxShadow: ChompyShape.shadowMd,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          child: Row(
            children: [
              Text('+',
                  style: t.displayMedium?.copyWith(
                      color: ChompyColors.ground, fontSize: 36, height: 1)),
              const SizedBox(width: ChompySpace.s3),
              Text(ChompyStrings.homeCta,
                  style: t.titleLarge?.copyWith(
                      color: ChompyColors.ground, fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpPill extends StatelessWidget {
  const _HelpPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChompyColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: Text('?',
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      color: ChompyColors.sageTint,
      shadow: const [],
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(ChompyStrings.tipLabel, color: ChompyColors.sageDeep),
          const SizedBox(height: ChompySpace.s1),
          Text(ChompyStrings.tipBody,
              style: t.bodyMedium?.copyWith(color: ChompyColors.sageDeep)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(foregroundColor: ChompyColors.sageDeep),
              child: Text(ChompyStrings.tipDismiss),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.label, required this.meal});
  final String label;
  final LoggedMeal? meal;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final logged = meal != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: ChompySpace.s3),
      child: Row(
        children: [
          // Status: colour + glyph together, never colour alone.
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: logged ? ChompyColors.sage : ChompyColors.neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              logged ? Icons.check : Icons.remove,
              size: 20,
              color: logged ? ChompyColors.ground : ChompyColors.neutral600,
            ),
          ),
          const SizedBox(width: ChompySpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.titleMedium),
                Text(
                  logged ? meal!.summary : ChompyStrings.mealEmpty,
                  style: t.bodyMedium?.copyWith(
                    color:
                        logged ? ChompyColors.neutral700 : ChompyColors.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
