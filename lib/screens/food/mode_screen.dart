import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../state/food_log_state.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// "Pick a way" — three first-class paths (design §13). Photo uses the OS camera
/// on a device and falls back to the photo library on the simulator.
class ModeScreen extends StatelessWidget {
  const ModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = screenPaddingOf(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, ChompySpace.s4, pad, ChompySpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackPill(onTap: () => context.read<FoodLogState>().exitToHome()),
            const SizedBox(height: ChompySpace.s4),
            Text(ChompyStrings.modeTitle, style: t.headlineLarge),
            const SizedBox(height: ChompySpace.s6),
            _ModeCard(
              glyph: Icons.photo_camera_outlined,
              title: ChompyStrings.modePhoto,
              hint: ChompyStrings.modePhotoHint,
              onTap: () => _takePhoto(context),
            ),
            const SizedBox(height: ChompySpace.s3),
            _ModeCard(
              glyph: Icons.edit_outlined,
              title: ChompyStrings.modeType,
              hint: ChompyStrings.modeTypeHint,
              onTap: () => context.read<FoodLogState>().pickText(),
            ),
            const SizedBox(height: ChompySpace.s3),
            _ModeCard(
              glyph: Icons.mic_none_outlined,
              title: ChompyStrings.modeSpeak,
              hint: ChompyStrings.modeSpeakHint,
              onTap: () => context.read<FoodLogState>().pickSpeak(),
            ),
            const SizedBox(height: ChompySpace.s4),
            Text(ChompyStrings.modeFooter,
                style: t.bodySmall?.copyWith(color: ChompyColors.neutral700)),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final fs = context.read<FoodLogState>();
    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 85, maxWidth: 1600);
    } catch (_) {
      // No camera (e.g. simulator) — fall back to the photo library.
      try {
        file = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
      } catch (_) {
        file = null;
      }
    }
    if (file == null) {
      fs.captureCancelled();
      return;
    }
    final bytes = await file.readAsBytes();
    fs.submitPhoto(
      base64Image: base64Encode(bytes),
      mimeType: _mimeFor(file.path),
    );
  }

  String _mimeFor(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.glyph,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData glyph;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ChompyColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(glyph, color: ChompyColors.ground, size: 26),
          ),
          const SizedBox(width: ChompySpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(hint,
                    style:
                        t.bodyMedium?.copyWith(color: ChompyColors.neutral700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
