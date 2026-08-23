import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// "Type your food" — a multiline field plus tappable liked-food chips that
/// append to it (design §16). The primary action is disabled while empty.
class TypeScreen extends StatefulWidget {
  const TypeScreen({super.key});

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<FoodLogState>().typedText;
    _controller.addListener(
      () => context.read<FoodLogState>().setTypedText(_controller.text),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendFood(String food) {
    final current = _controller.text.trimRight();
    _controller.text = current.isEmpty ? food : '$current, $food';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = screenPaddingOf(context);
    final hasText = context.select<FoodLogState, bool>(
        (s) => s.typedText.trim().isNotEmpty);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackPill(onTap: () => context.read<FoodLogState>().backToMode()),
            const SizedBox(height: ChompySpace.s4),
            Text(ChompyStrings.typeTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s4),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      style: t.bodyLarge,
                      decoration: InputDecoration(
                        hintText: ChompyStrings.typePlaceholder,
                        // Softer than a pill for multiline — rounded, no border.
                        border: const OutlineInputBorder(
                          borderRadius: ChompyShape.cardRadius,
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: ChompySpace.s4),
                    Text(ChompyStrings.likedFoodsLabel,
                        style: t.labelSmall),
                    const SizedBox(height: ChompySpace.s2),
                    Wrap(
                      spacing: ChompySpace.s2,
                      runSpacing: ChompySpace.s2,
                      children: [
                        for (final food in ChompyStrings.likedFoods)
                          _AddChip(label: food, onTap: () => _appendFood(food)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PrimaryCta(
              label: ChompyStrings.typeCta,
              enabled: hasText,
              onPressed: () => context.read<FoodLogState>().submitText(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChompyColors.surface,
      borderRadius: ChompyShape.pill,
      child: InkWell(
        borderRadius: ChompyShape.pill,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
