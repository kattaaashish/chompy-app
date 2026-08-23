import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

/// Placeholder landing. The full Home screen (food groups, meals, "Log a meal")
/// is a later slice — for now, onboarding terminates here so the flow completes.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final name = context.select<OnboardingState, String>((s) => s.name);
    final pad = ChompySpace.screenH(MediaQuery.sizeOf(context).width);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Mascot(size: 104),
              const SizedBox(height: ChompySpace.s6),
              Text(ChompyStrings.greeting(name), style: t.displayMedium),
              const SizedBox(height: ChompySpace.s2),
              Text(
                "You're all set. Home comes next.",
                style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
