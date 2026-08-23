import 'package:flutter/material.dart';

import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/loading_view.dart';

/// "Chompy is looking…" — fallibility announced before results (design §18).
class DetectingScreen extends StatelessWidget {
  const DetectingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: LoadingView(
        title: ChompyStrings.detectingTitle,
        body: ChompyStrings.detectingBody,
        duration: ChompyDurations.detectFood,
        blinking: true,
      ),
    );
  }
}

/// "Saving your meal…" (design §21).
class SavingScreen extends StatelessWidget {
  const SavingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: LoadingView(
        title: ChompyStrings.savingTitle,
        body: ChompyStrings.savingBody,
        duration: ChompyDurations.saveMeal,
      ),
    );
  }
}
