// Chompy the mascot — an irregular terracotta blob with a bite out of it and
// two eyes. A shape, not a character (design "Judgment calls"). The bite is a
// ground-coloured notch carved from the top-right; it reacts by pulsing (scale
// 1.0 → 1.14) and, while "thinking", blinking.

import 'package:flutter/material.dart';

import '../theme.dart';

class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.size = 104,
    this.color = ChompyColors.accent,
    this.biteColor = ChompyColors.ground,
    this.pulsing = false,
    this.blinking = false,
    this.shadow = ChompyShape.shadowMd,
  });

  final double size;
  final Color color;

  /// The notch colour — match the surface behind the mascot.
  final Color biteColor;

  /// Slow breathing scale, for loading / listening states.
  final bool pulsing;

  /// Eye blink, for the "detecting" state.
  final bool blinking;

  final List<BoxShadow> shadow;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    // Create eagerly so dispose() is always safe — a lazy `late final` would
    // build a Ticker during teardown if the animation never ran.
    _pulse = AnimationController(
      vsync: this,
      duration: ChompyDurations.mascotPulse,
    );
    _blink = AnimationController(
      vsync: this,
      duration: ChompyDurations.mascotBlink,
    );
    if (widget.pulsing) _pulse.repeat(reverse: true);
    if (widget.blinking) _blink.repeat();
  }

  @override
  void didUpdateWidget(covariant Mascot old) {
    super.didUpdateWidget(old);
    if (widget.pulsing != old.pulsing) {
      widget.pulsing ? _pulse.repeat(reverse: true) : _pulse.stop();
    }
    if (widget.blinking != old.blinking) {
      widget.blinking ? _blink.repeat() : _blink.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final eye = s * 0.11;

    Widget blob = SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Body.
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: ChompyShape.blob(s),
              boxShadow: widget.shadow,
            ),
          ),
          // Bite — a rounded notch carved from the top-right.
          Positioned(
            top: -s * 0.06,
            right: -s * 0.06,
            child: Container(
              width: s * 0.42,
              height: s * 0.42,
              decoration: BoxDecoration(
                color: widget.biteColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Eyes.
          Positioned(
            top: s * 0.44,
            left: s * 0.28,
            child: _Eye(size: eye, blink: widget.blinking ? _blink : null),
          ),
          Positioned(
            top: s * 0.44,
            left: s * 0.52,
            child: _Eye(size: eye, blink: widget.blinking ? _blink : null),
          ),
        ],
      ),
    );

    if (widget.pulsing) {
      final scale = Tween<double>(begin: 1.0, end: 1.14)
          .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
      blob = ScaleTransition(scale: scale, child: blob);
    }
    return blob;
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size, this.blink});

  final double size;
  final Animation<double>? blink;

  @override
  Widget build(BuildContext context) {
    final eye = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ChompyColors.ink,
        shape: BoxShape.circle,
      ),
    );
    if (blink == null) return eye;
    // Step blink: open most of the cycle, shut briefly near the end.
    return AnimatedBuilder(
      animation: blink!,
      builder: (context, child) {
        final open = blink!.value < 0.9 ? 1.0 : 0.1;
        return Transform.scale(scaleY: open, child: child);
      },
      child: eye,
    );
  }
}
