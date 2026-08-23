import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Capture cancelled — deliberately NOT an error (design §15).
class CancelledScreen extends StatelessWidget {
  const CancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = screenPaddingOf(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackPill(onTap: () => context.read<FoodLogState>().backToMode()),
            const Spacer(),
            Text(ChompyStrings.cancelledTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s2),
            Text(ChompyStrings.cancelledBody,
                style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
            const Spacer(),
            PrimaryCta(
              label: ChompyStrings.cancelledRetry,
              onPressed: () => context.read<FoodLogState>().backToMode(),
            ),
            const SizedBox(height: ChompySpace.s2),
            OutlinedButton(
              onPressed: () => context.read<FoodLogState>().backToMode(),
              child: Text(ChompyStrings.cancelledOther),
            ),
          ],
        ),
      ),
    );
  }
}
