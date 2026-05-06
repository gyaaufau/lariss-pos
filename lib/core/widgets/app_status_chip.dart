import 'package:flutter/material.dart';

enum AppStatusChipTone { success, warning, danger, neutral }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({required this.label, required this.tone, super.key});

  final String label;
  final AppStatusChipTone tone;

  factory AppStatusChip.active({Key? key}) {
    return AppStatusChip(
      key: key,
      label: 'Aktif',
      tone: AppStatusChipTone.success,
    );
  }

  factory AppStatusChip.inactive({Key? key}) {
    return AppStatusChip(
      key: key,
      label: 'Nonaktif',
      tone: AppStatusChipTone.neutral,
    );
  }

  factory AppStatusChip.safe({Key? key}) {
    return AppStatusChip(
      key: key,
      label: 'Stok aman',
      tone: AppStatusChipTone.success,
    );
  }

  factory AppStatusChip.lowStock({Key? key}) {
    return AppStatusChip(
      key: key,
      label: 'Stok menipis',
      tone: AppStatusChipTone.warning,
    );
  }

  factory AppStatusChip.outOfStock({Key? key}) {
    return AppStatusChip(
      key: key,
      label: 'Stok habis',
      tone: AppStatusChipTone.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) palette = _paletteForTone();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _paletteForTone() {
    switch (tone) {
      case AppStatusChipTone.success:
        return (
          background: const Color(0xFFDCFCE7),
          foreground: const Color(0xFF166534),
        );
      case AppStatusChipTone.warning:
        return (
          background: const Color(0xFFFFFBEB),
          foreground: const Color(0xFFB45309),
        );
      case AppStatusChipTone.danger:
        return (
          background: const Color(0xFFFEE2E2),
          foreground: const Color(0xFFB91C1C),
        );
      case AppStatusChipTone.neutral:
        return (
          background: const Color(0xFFE2E8F0),
          foreground: const Color(0xFF475569),
        );
    }
  }
}
