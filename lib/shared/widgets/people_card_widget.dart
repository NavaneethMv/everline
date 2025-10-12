import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeopleCardWidget extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const PeopleCardWidget({
    super.key,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          ShadAvatar(avatarUrl, placeholder: Text('CN')),
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
