import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/loading_view.dart';

/// Stage 1 wait — "Sending your code…", echoes the number back.
class SendingScreen extends StatelessWidget {
  const SendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.select<OnboardingState, String>((s) => s.phoneFormatted);
    return SafeArea(
      child: LoadingView(
        title: ChompyStrings.sendingTitle,
        body: ChompyStrings.sendingBody(phone),
        duration: ChompyDurations.sendOtp,
      ),
    );
  }
}

/// Stage 2 wait — "Checking your code…".
class VerifyingScreen extends StatelessWidget {
  const VerifyingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: LoadingView(
        title: ChompyStrings.verifyingTitle,
        body: ChompyStrings.verifyingBody,
        duration: ChompyDurations.verifyOtp,
      ),
    );
  }
}
