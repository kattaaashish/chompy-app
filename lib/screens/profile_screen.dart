import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = context.watch<OnboardingState>();
    final pad = screenPaddingOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker(ChompyStrings.profileStep),
            const SizedBox(height: ChompySpace.s3),
            Text(ChompyStrings.profileTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s6),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: ChompyStrings.labelName,
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        style: t.bodyLarge,
                        onChanged: (v) =>
                            context.read<OnboardingState>().name = v,
                        decoration: const InputDecoration(hintText: 'Dhruv'),
                      ),
                    ),
                    const SizedBox(height: ChompySpace.s4),
                    _Field(
                      label: ChompyStrings.labelDob,
                      child: _DobField(dob: state.dob),
                    ),
                    const SizedBox(height: ChompySpace.s4),
                    _Field(
                      label: ChompyStrings.labelGender,
                      child: Row(
                        children: [
                          for (final g in const ['Boy', 'Girl']) ...[
                            SelectPill(
                              label: g,
                              selected: state.gender == g,
                              onTap: () =>
                                  context.read<OnboardingState>().gender = g,
                            ),
                            if (g == 'Boy') const SizedBox(width: ChompySpace.s2),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: ChompySpace.s4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Field(
                            label: ChompyStrings.labelHeight,
                            child: _MeasureField(
                              value: state.heightValue,
                              unit: state.heightUnit,
                              units: const ['cm', 'in'],
                              onChanged: (v) => context
                                  .read<OnboardingState>()
                                  .heightValue = v,
                              onToggle: () => context
                                  .read<OnboardingState>()
                                  .toggleHeightUnit(),
                            ),
                          ),
                        ),
                        const SizedBox(width: ChompySpace.s3),
                        Expanded(
                          child: _Field(
                            label: ChompyStrings.labelWeight,
                            child: _MeasureField(
                              value: state.weightValue,
                              unit: state.weightUnit,
                              units: const ['kg', 'lb'],
                              onChanged: (v) => context
                                  .read<OnboardingState>()
                                  .weightValue = v,
                              onToggle: () => context
                                  .read<OnboardingState>()
                                  .toggleWeightUnit(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ChompySpace.s4),
                    Text(ChompyStrings.profileHelper,
                        style:
                            t.bodySmall?.copyWith(color: ChompyColors.neutral700)),
                    if (state.profileError != null) ...[
                      const SizedBox(height: ChompySpace.s4),
                      ErrorBlock(
                        title: "That didn't save",
                        body: state.profileError!,
                      ),
                    ],
                    const SizedBox(height: ChompySpace.s4),
                  ],
                ),
              ),
            ),
            // Sticky submit.
            PrimaryCta(
              label: state.profileCtaLabel,
              enabled: state.profileComplete,
              busy: state.profileSubmitting,
              onPressed: () => context.read<OnboardingState>().submitProfile(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small label above a soft-fill input (no floating labels, no outlines).
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6),
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: ChompyColors.neutral700)),
        ),
        child,
      ],
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.dob});

  final DateTime? dob;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: ChompyColors.surface,
      borderRadius: ChompyShape.pill,
      child: InkWell(
        borderRadius: ChompyShape.pill,
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            // Constrain to the supported 5–12 age band.
            firstDate: DateTime(now.year - OnboardingState.maxAge, now.month, now.day),
            lastDate: DateTime(now.year - OnboardingState.minAge, now.month, now.day),
            initialDate: DateTime(now.year - 8, now.month, now.day),
          );
          if (picked != null && context.mounted) {
            context.read<OnboardingState>().dob = picked;
          }
        },
        child: Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            dob == null ? 'Choose a date' : DateFormat('d MMMM y').format(dob!),
            style: t.bodyLarge?.copyWith(
              color: dob == null ? ChompyColors.neutral600 : ChompyColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Numeric pill field with an in-place sage unit toggle.
class _MeasureField extends StatelessWidget {
  const _MeasureField({
    required this.value,
    required this.unit,
    required this.units,
    required this.onChanged,
    required this.onToggle,
  });

  final double? value;
  final String unit;
  final List<String> units;
  final ValueChanged<double?> onChanged;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: ChompyColors.surface,
        borderRadius: ChompyShape.pill,
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (v) => onChanged(double.tryParse(v)),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                hintText: '—',
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          // Sage in-place unit toggle.
          Material(
            color: ChompyColors.sage,
            borderRadius: ChompyShape.pill,
            child: InkWell(
              borderRadius: ChompyShape.pill,
              onTap: onToggle,
              child: Container(
                height: 40,
                constraints: const BoxConstraints(minWidth: 46),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(unit,
                        style: t.bodyMedium?.copyWith(
                            color: ChompyColors.ground,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 3),
                    const Icon(Icons.swap_horiz,
                        size: 15, color: ChompyColors.ground),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
