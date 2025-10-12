import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final genders = {'male': 'Male', 'female': 'Female'};

class SelectGenderWidget extends StatelessWidget {
  final void Function(String?) onChanged;
  const SelectGenderWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: ShadSelect<String>(
        placeholder: const Text('Select gender'),
        options: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
            child: Text(
              'Gender',
              style: theme.textTheme.muted.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.popoverForeground,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          ...genders.entries.map(
            (e) => ShadOption(value: e.key, child: Text(e.value)),
          ),
        ],
        selectedOptionBuilder: (context, value) => Text(genders[value]!),
        onChanged: onChanged,
      ),
    );
  }
}
