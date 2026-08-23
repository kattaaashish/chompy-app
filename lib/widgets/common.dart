// Shared chrome shared across the onboarding screens. Everything here obeys the
// design's hard rules: no outlined boxes (soft fills only), one primary action
// per screen, back/cancel as a 44px circular pill top-left, status always paired
// with a word (never colour alone).

import 'package:flutter/material.dart';

import '../theme.dart';

/// Fluid horizontal screen padding (15–24px with width).
double screenPaddingOf(BuildContext context) =>
    ChompySpace.screenH(MediaQuery.sizeOf(context).width);

/// Uppercase, letter-spaced eyebrow label.
class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Text(
      text.toUpperCase(),
      style: color == null ? style : style?.copyWith(color: color),
    );
  }
}

/// The single primary action: full-width terracotta pill, left-aligned label.
/// Disabled state carries a "what's missing" label rather than an error later.
class PrimaryCta extends StatelessWidget {
  const PrimaryCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: (enabled && !busy) ? onPressed : null,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(ChompyColors.ground),
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft-fill, borderless text link (e.g. "Change phone number →").
class GhostLink extends StatelessWidget {
  const GhostLink(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: ChompyColors.accentDeep,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerLeft,
        minimumSize: const Size(0, 44),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: ChompyColors.accentDeep, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// A selectable pill (gender choice, unit toggle). Selected → terracotta.
class SelectPill extends StatelessWidget {
  const SelectPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ChompyColors.accent : ChompyColors.surface,
      borderRadius: ChompyShape.pill,
      child: InkWell(
        borderRadius: ChompyShape.pill,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected ? ChompyColors.ground : ChompyColors.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

/// The onboarding error block: tinted fill, 6px terracotta left edge, a title
/// and body, and an optional ghost recovery link inside it.
class ErrorBlock extends StatelessWidget {
  const ErrorBlock({
    super.key,
    required this.title,
    required this.body,
    this.link,
    this.onLinkTap,
  });

  final String title;
  final String body;
  final String? link;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: ChompyColors.accentTint,
        borderRadius: ChompyShape.cardRadius,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
            decoration: const BoxDecoration(
              color: ChompyColors.accent,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(26)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: t.titleMedium?.copyWith(color: ChompyColors.accentDeep)),
                  const SizedBox(height: ChompySpace.s1),
                  Text(body,
                      style:
                          t.bodyMedium?.copyWith(color: ChompyColors.accentDeeper)),
                  if (link != null && onLinkTap != null)
                    GhostLink(link!, onTap: onLinkTap!),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// A soft-fill rounded card (radius 26, small shadow). No borders anywhere in
/// this app — containers are fills, not outlined rectangles.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = ChompyColors.card,
    this.shadow = ChompyShape.shadowSm,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final List<BoxShadow> shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: ChompyShape.cardRadius,
        boxShadow: shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: ChompyShape.cardRadius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// A round letter/glyph tile (the neutral avatar on review item cards).
class LetterTile extends StatelessWidget {
  const LetterTile(this.letter, {super.key, this.size = 44});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: ChompyColors.surface,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
      ),
    );
  }
}

/// The 44px circular back pill, top-left.
class BackPill extends StatelessWidget {
  const BackPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChompyColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, size: 20, color: ChompyColors.ink),
        ),
      ),
    );
  }
}
