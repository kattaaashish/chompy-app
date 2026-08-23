import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// "I'm listening…" — real on-device speech-to-text. Ending early ("Stop") is
/// not the same as submitting ("Done talking") (design §17).
class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: ChompyDurations.mascotPulse,
  )..repeat(reverse: true);

  String _transcript = '';
  bool _available = true;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final ok = await _speech.initialize(onError: (_) {}, onStatus: (s) {
      if (mounted) setState(() => _listening = _speech.isListening);
    });
    if (!mounted) return;
    setState(() => _available = ok);
    if (ok) {
      await _speech.listen(
        onResult: (r) => setState(() => _transcript = r.recognizedWords),
        listenOptions: SpeechListenOptions(listenFor: const Duration(seconds: 30)),
      );
      if (mounted) setState(() => _listening = true);
    }
  }

  Future<void> _stop() async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  @override
  void dispose() {
    _speech.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = screenPaddingOf(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackPill(onTap: () {
              _stop();
              context.read<FoodLogState>().backToMode();
            }),
            const Spacer(),
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: const BoxDecoration(
                    color: ChompyColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: ChompyShape.shadowLg,
                  ),
                  child: const Icon(Icons.mic, size: 56, color: ChompyColors.ground),
                ),
              ),
            ),
            const SizedBox(height: ChompySpace.s6),
            Text(
              _available ? ChompyStrings.speakTitle : "I can't hear right now",
              style: t.headlineLarge,
            ),
            const SizedBox(height: ChompySpace.s2),
            Text(
              _available
                  ? (_transcript.isEmpty ? ChompyStrings.speakBody : _transcript)
                  : 'You can type your food instead.',
              style: t.bodyLarge?.copyWith(color: ChompyColors.neutral700),
            ),
            const Spacer(),
            if (_available) ...[
              PrimaryCta(
                label: ChompyStrings.speakDone,
                enabled: _transcript.trim().isNotEmpty,
                onPressed: () async {
                  await _stop();
                  if (context.mounted) {
                    context.read<FoodLogState>().submitSpeech(_transcript);
                  }
                },
              ),
              const SizedBox(height: ChompySpace.s2),
              OutlinedButton(
                onPressed: _listening ? _stop : _start,
                child: Text(_listening ? ChompyStrings.speakStop : 'Listen again'),
              ),
            ] else
              PrimaryCta(
                label: 'Type instead',
                onPressed: () => context.read<FoodLogState>().pickText(),
              ),
          ],
        ),
      ),
    );
  }
}
