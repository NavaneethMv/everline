import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: ShadTheme.of(context).textTheme.small.copyWith(
          color: ShadTheme.of(context).colorScheme.mutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
