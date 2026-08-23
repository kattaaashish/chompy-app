import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food.dart';
import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Review & edit — the screen Dhruv actually confirms on (design §19). Numbers
/// (calories/nutrients) are deliberately absent; quantities are real-world units.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final food = context.watch<FoodLogState>();
    final pad = screenPaddingOf(context);
    final empty = food.items.isEmpty;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding:
                  EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s4),
              children: [
                BackPill(onTap: () => context.read<FoodLogState>().backToMode()),
                const SizedBox(height: ChompySpace.s4),
                Text(empty ? ChompyStrings.reviewTitleEmpty : ChompyStrings.reviewTitle,
                    style: t.headlineLarge),
                const SizedBox(height: ChompySpace.s2),
                Text(empty ? ChompyStrings.reviewBodyEmpty : ChompyStrings.reviewBody,
                    style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
                const SizedBox(height: ChompySpace.s6),

                // When was it? — 2×2 category pills.
                Text(ChompyStrings.reviewWhen, style: t.headlineMedium),
                const SizedBox(height: ChompySpace.s3),
                _CategoryGrid(selected: food.category),
                const SizedBox(height: ChompySpace.s6),

                if (empty)
                  _EmptyCard()
                else ...[
                  Text(ChompyStrings.reviewFound, style: t.headlineMedium),
                  const SizedBox(height: ChompySpace.s3),
                  for (var i = 0; i < food.items.length; i++) ...[
                    _ItemCard(index: i, item: food.items[i]),
                    const SizedBox(height: ChompySpace.s3),
                  ],
                ],

                const SizedBox(height: ChompySpace.s2),
                Text(ChompyStrings.reviewAddMissed, style: t.labelSmall),
                const SizedBox(height: ChompySpace.s2),
                Wrap(
                  spacing: ChompySpace.s2,
                  runSpacing: ChompySpace.s2,
                  children: [
                    for (final liked in ChompyStrings.likedFoods)
                      _AddChip(label: liked),
                  ],
                ),
              ],
            ),
          ),

          // Sticky confirm.
          Padding(
            padding: EdgeInsets.fromLTRB(pad, ChompySpace.s2, pad, ChompySpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryCta(
                  label: empty ? ChompyStrings.reviewCtaEmpty : ChompyStrings.reviewCta,
                  enabled: !empty,
                  onPressed: () => context.read<FoodLogState>().confirm(),
                ),
                const SizedBox(height: ChompySpace.s2),
                Text(
                  empty ? ChompyStrings.reviewHelperEmpty : ChompyStrings.reviewHelper,
                  style: t.bodySmall?.copyWith(color: ChompyColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected});
  final String selected;

  @override
  Widget build(BuildContext context) {
    // Two rows of two. Display label → lowercase backend key.
    Widget cell(String label) {
      final key = label.toLowerCase();
      return Expanded(
        child: SelectPill(
          label: label,
          selected: selected == key,
          onTap: () => context.read<FoodLogState>().setCategory(key),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          cell(ChompyStrings.categories[0]),
          const SizedBox(width: ChompySpace.s2),
          cell(ChompyStrings.categories[1]),
        ]),
        const SizedBox(height: ChompySpace.s2),
        Row(children: [
          cell(ChompyStrings.categories[2]),
          const SizedBox(width: ChompySpace.s2),
          cell(ChompyStrings.categories[3]),
        ]),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.index, required this.item});
  final int index;
  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              LetterTile(item.initial),
              const SizedBox(width: ChompySpace.s3),
              Expanded(
                child: Text(item.name,
                    style: t.titleMedium, overflow: TextOverflow.ellipsis),
              ),
              _RoundIconButton(
                icon: Icons.close,
                onTap: () => context.read<FoodLogState>().removeItem(index),
              ),
            ],
          ),
          const SizedBox(height: ChompySpace.s3),
          _QuantityStepper(index: index, item: item),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.index, required this.item});
  final int index;
  final FoodItem item;

  String get _amountLabel {
    final a = item.amount;
    final amountStr = a == a.roundToDouble() ? a.toInt().toString() : a.toString();
    return '$amountStr ${item.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: () => context.read<FoodLogState>().changeQuantity(index, -1),
        ),
        Expanded(
          child: Center(
            child: Text(_amountLabel,
                style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: () => context.read<FoodLogState>().changeQuantity(index, 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
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
          width: 46,
          height: 46,
          child: Icon(icon, size: 22, color: ChompyColors.ink),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
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
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: ChompyColors.neutral700),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ChompyStrings.emptyDetectTitle, style: t.titleMedium),
          const SizedBox(height: ChompySpace.s2),
          Text(ChompyStrings.emptyDetectBody,
              style: t.bodyMedium?.copyWith(color: ChompyColors.neutral700)),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChompyColors.surface,
      borderRadius: ChompyShape.pill,
      child: InkWell(
        borderRadius: ChompyShape.pill,
        onTap: () => context.read<FoodLogState>().addFood(label),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('+ $label',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
