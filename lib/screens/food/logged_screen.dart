import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Logged — confirmation shows the consequence, not just "saved" (design §23).
/// Food-group "New today" blocks were dropped; we list the foods just added.
class LoggedScreen extends StatelessWidget {
  const LoggedScreen({super.key});

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
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: ChompyColors.sage,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 38, color: ChompyColors.ground),
            ),
            const SizedBox(height: ChompySpace.s4),
            Text(ChompyStrings.savedTitle, style: t.displayMedium),
            const SizedBox(height: ChompySpace.s2),
            Text(
              ChompyStrings.savedBody(food.category, food.items.length),
              style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700),
            ),
            const SizedBox(height: ChompySpace.s6),
            Text(ChompyStrings.savedNewToday, style: t.labelSmall),
            const SizedBox(height: ChompySpace.s2),
            Wrap(
              spacing: ChompySpace.s2,
              runSpacing: ChompySpace.s2,
              children: [
                for (final item in food.items)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: ChompyColors.sageTint,
                      borderRadius: ChompyShape.pill,
                    ),
                    child: Text(item.name,
                        style: t.bodyMedium
                            ?.copyWith(color: ChompyColors.sageDeep)),
                  ),
              ],
            ),
            const Spacer(),
            PrimaryCta(
              label: ChompyStrings.savedCta,
              onPressed: () => context.read<FoodLogState>().exitToHome(),
            ),
          ],
        ),
      ),
    );
  }
}
