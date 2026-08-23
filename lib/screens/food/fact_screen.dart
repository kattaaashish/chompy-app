import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';

/// Fun fact — the reward, and the only full-terracotta screen (design §22). One
/// fact per item, never a number.
class FactScreen extends StatelessWidget {
  const FactScreen({super.key});

  String _factFor(String name) {
    for (final entry in ChompyStrings.facts.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return ChompyStrings.factFallback;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final food = context.watch<FoodLogState>();
    final item = food.currentFactItem;
    if (item == null) return const SizedBox.shrink();
    final pad = screenPaddingOf(context);

    return Container(
      color: ChompyColors.accent,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, ChompySpace.s6, pad, ChompySpace.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ChompyStrings.factKicker.toUpperCase(),
                  style: t.labelSmall?.copyWith(color: ChompyColors.accentTint)),
              const Spacer(),
              // Cream mascot on the terracotta field; the notch shows the field.
              const Mascot(
                size: 96,
                color: ChompyColors.groundCream,
                biteColor: ChompyColors.accent,
                shadow: [],
              ),
              const SizedBox(height: ChompySpace.s4),
              Text(
                item.name,
                style: t.displayLarge?.copyWith(color: ChompyColors.ground),
              ),
              const SizedBox(height: ChompySpace.s3),
              Text(
                _factFor(item.name),
                style: t.bodyLarge?.copyWith(color: ChompyColors.ground, height: 1.5),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => context.read<FoodLogState>().nextFact(),
                child: Text(food.hasMoreFacts
                    ? ChompyStrings.factNext
                    : ChompyStrings.factFinish),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
