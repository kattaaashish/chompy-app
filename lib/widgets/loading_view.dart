// The one loading pattern, learned once (design "Behaviour rules"). A pulsing
// mascot, a title, a reassuring line, and a determinate bar that fills 6% → 96%
// over the nominal wait. Never a spinner — a spinner reads as "stuck" to a child.

import 'package:flutter/material.dart';

import '../theme.dart';
import 'mascot.dart';

class ChompyProgressBar extends StatefulWidget {
  const ChompyProgressBar({super.key, required this.duration});

  final Duration duration;

  @override
  State<ChompyProgressBar> createState() => _ChompyProgressBarState();
}

class _ChompyProgressBarState extends State<ChompyProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: ChompyShape.pill,
      child: SizedBox(
        height: 12,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Linear fill, held just short of full while the wait resolves.
            final t = 0.06 + (_c.value * 0.90);
            return LinearProgressIndicator(
              value: t,
              backgroundColor: ChompyColors.neutral300,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(ChompyColors.accent),
            );
          },
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    required this.title,
    required this.body,
    required this.duration,
    this.blinking = false,
  });

  final String title;
  final String body;
  final Duration duration;
  final bool blinking;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = ChompySpace.screenH(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Mascot(size: 104, pulsing: true, blinking: blinking),
          const SizedBox(height: ChompySpace.s6),
          Text(title, style: t.headlineLarge),
          const SizedBox(height: ChompySpace.s2),
          Text(body, style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
          const SizedBox(height: ChompySpace.s6),
          ChompyProgressBar(duration: duration),
        ],
      ),
    );
  }
}
