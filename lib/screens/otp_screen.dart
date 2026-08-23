import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = context.watch<OnboardingState>();
    final pad = screenPaddingOf(context);

    // Keep the hidden field in sync when the code is cleared after an error.
    if (_controller.text != state.otp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = TextEditingValue(
          text: state.otp,
          selection: TextSelection.collapsed(offset: state.otp.length),
        );
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker(ChompyStrings.otpStep),
            const SizedBox(height: ChompySpace.s3),
            Text(ChompyStrings.otpTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s2),
            Text(ChompyStrings.otpBody(state.phoneFormatted),
                style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700)),
            const SizedBox(height: ChompySpace.s6),
            _OtpCells(
              value: state.otp,
              controller: _controller,
              focus: _focus,
              onChanged: (v) => context.read<OnboardingState>().setOtp(v),
            ),
            if (state.debugOtpCode != null) ...[
              const SizedBox(height: ChompySpace.s3),
              _DebugCodeBanner(code: state.debugOtpCode!),
            ],
            if (state.otpError != OtpError.none) ...[
              const SizedBox(height: ChompySpace.s4),
              ErrorBlock(
                title: state.otpError == OtpError.expired
                    ? ChompyStrings.otpExpiredTitle
                    : ChompyStrings.otpWrongTitle,
                body: state.otpError == OtpError.expired
                    ? ChompyStrings.otpExpiredBody
                    : ChompyStrings.otpWrongBody,
                link: ChompyStrings.otpChangeNumber,
                onLinkTap: () => context.read<OnboardingState>().changePhoneNumber(),
              ),
            ],
            const SizedBox(height: ChompySpace.s8),
            PrimaryCta(
              label: ChompyStrings.otpCta,
              enabled: state.otpValid,
              onPressed: () => context.read<OnboardingState>().submitOtp(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the stubbed-SMS code and fills it on tap. Only rendered when the
/// backend echoes a `debugCode` (OTP_DEBUG=true server-side) — in production
/// the field is simply absent from the response, so this never appears.
class _DebugCodeBanner extends StatelessWidget {
  const _DebugCodeBanner({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: ChompyColors.sageTintStrong,
      borderRadius: ChompyShape.pill,
      child: InkWell(
        borderRadius: ChompyShape.pill,
        onTap: () => context.read<OnboardingState>().setOtp(code),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.bug_report_outlined,
                  size: 18, color: ChompyColors.sageDeep),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dev code: $code  ·  tap to fill',
                  style: t.bodyMedium?.copyWith(
                      color: ChompyColors.sageDeep, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpCells extends StatelessWidget {
  const _OtpCells({
    required this.value,
    required this.controller,
    required this.focus,
    required this.onChanged,
  });

  final String value;
  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: focus.requestFocus,
      child: Stack(
        children: [
          Row(
            children: List.generate(6, (i) {
              final filled = i < value.length;
              final isNext = i == value.length;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 5 ? 0 : ChompySpace.s2),
                  child: Container(
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ChompyColors.surface,
                      borderRadius: ChompyShape.pill,
                      border: isNext
                          ? Border.all(color: ChompyColors.accent, width: 2)
                          : null,
                    ),
                    child: Text(
                      filled ? value[i] : '',
                      style: t.titleLarge?.copyWith(fontSize: 24),
                    ),
                  ),
                ),
              );
            }),
          ),
          // Transparent full-size field that actually owns input.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
