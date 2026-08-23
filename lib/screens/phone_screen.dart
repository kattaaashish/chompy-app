import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _hint(int len) {
    if (len == 0) return ChompyStrings.phoneHintEmpty;
    if (len < 10) return ChompyStrings.phoneHintRemaining(10 - len);
    return ChompyStrings.phoneHintValid;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = context.watch<OnboardingState>();
    final pad = screenPaddingOf(context);
    final len = state.phone.length;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker(ChompyStrings.phoneStep),
            const SizedBox(height: ChompySpace.s3),
            Text(ChompyStrings.phoneTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s2),
            Text(ChompyStrings.phoneBody,
                style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
            const SizedBox(height: ChompySpace.s6),
            _PhoneField(controller: _controller),
            const SizedBox(height: ChompySpace.s2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                _hint(len),
                style: t.bodyMedium?.copyWith(
                  color: len == 10 ? ChompyColors.accentDeep : ChompyColors.neutral600,
                  fontWeight: len == 10 ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (state.sendError != null) ...[
              const SizedBox(height: ChompySpace.s4),
              ErrorBlock(
                title: "Couldn't send the code",
                body: state.sendError!,
              ),
            ],
            const Spacer(),
            PrimaryCta(
              label: ChompyStrings.phoneCta,
              enabled: state.phoneValid,
              onPressed: () => context.read<OnboardingState>().submitPhone(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: ChompyColors.surface,
        borderRadius: ChompyShape.pill,
      ),
      child: Row(
        children: [
          // Fixed +91 prefix in a sage-tinted leading segment.
          Container(
            height: 56,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              color: ChompyColors.sageTint,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(999)),
            ),
            child: Text('+91',
                style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: t.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600, letterSpacing: 1.5),
              inputFormatters: [_PhoneFormatter()],
              onChanged: (v) => context.read<OnboardingState>().setPhone(v),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                hintText: ChompyStrings.phonePlaceholder,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Strips non-digits, caps at 10, and displays them as `98765 43210`.
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue _, TextEditingValue next) {
    var digits = next.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);
    final display =
        digits.length <= 5 ? digits : '${digits.substring(0, 5)} ${digits.substring(5)}';
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}
