import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Save failed — never a dead end, never a stack trace. The meal is itemised
/// here as proof that nothing was lost (design §24).
class FailedScreen extends StatelessWidget {
  const FailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final food = context.watch<FoodLogState>();
    final pad = screenPaddingOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s6, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ChompySpace.s4),
            // Terracotta "!" ring — colour + glyph together.
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ChompyColors.accent, width: 4),
              ),
              child: const Icon(Icons.priority_high,
                  size: 34, color: ChompyColors.accent),
            ),
            const SizedBox(height: ChompySpace.s4),
            Text(ChompyStrings.failedTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s2),
            Text(ChompyStrings.failedBody,
                style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
            const SizedBox(height: ChompySpace.s4),
            // The meal, still here.
            Expanded(
              child: SingleChildScrollView(
                child: SoftCard(
                  child: Column(
                    children: [
                      for (final item in food.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              LetterTile(item.initial, size: 36),
                              const SizedBox(width: ChompySpace.s3),
                              Expanded(
                                  child: Text(item.name, style: t.titleMedium)),
                              Text(
                                '${_amount(item.amount)} ${item.unit}',
                                style: t.bodyMedium
                                    ?.copyWith(color: ChompyColors.neutral700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: ChompySpace.s3),
            PrimaryCta(
              label: ChompyStrings.failedRetry,
              onPressed: () => context.read<FoodLogState>().retrySave(),
            ),
            const SizedBox(height: ChompySpace.s2),
            OutlinedButton(
              onPressed: () => context.read<FoodLogState>().backToReview(),
              child: Text(ChompyStrings.failedBack),
            ),
          ],
        ),
      ),
    );
  }

  String _amount(num a) =>
      a == a.roundToDouble() ? a.toInt().toString() : a.toString();
}
