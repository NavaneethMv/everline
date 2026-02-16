import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeopleCardWidget extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;

  const PeopleCardWidget({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          ShadAvatar(
            avatarUrl?.isNotEmpty == true ? avatarUrl! : LucideIcons.user,
            placeholder: const Icon(LucideIcons.user),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                role,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
