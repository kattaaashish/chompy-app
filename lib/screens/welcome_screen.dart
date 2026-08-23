import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final pad = screenPaddingOf(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s8, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Mascot(size: 104),
            const SizedBox(height: ChompySpace.s6),
            Text(
              ChompyStrings.welcomeTitle,
              style: t.displayLarge?.copyWith(fontSize: fluid(width, 30, 44)),
            ),
            const SizedBox(height: ChompySpace.s3),
            Text(
              ChompyStrings.welcomeBody,
              style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700),
            ),
            const Spacer(),
            PrimaryCta(
              label: ChompyStrings.welcomeCta,
              onPressed: () => context.read<OnboardingState>().goToPhone(),
            ),
          ],
        ),
      ),
    );
  }
}
