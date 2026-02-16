import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RelationshipsStep extends StatefulWidget {
  const RelationshipsStep({super.key});

  @override
  State<RelationshipsStep> createState() => _RelationshipsStepState();
}

class _RelationshipsStepState extends State<RelationshipsStep> {
  final List<Map<String, dynamic>> _relationshipOptions = [
    {'label': 'Parent', 'icon': LucideIcons.heart, 'color': Colors.red},
    {'label': 'Child', 'icon': LucideIcons.baby, 'color': Colors.orange},
    {'label': 'Spouse', 'icon': LucideIcons.userPlus, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCubit, AddMemberState>(
      builder: (context, state) {
        final addedRelationships = state.relationships;
        final relatives = state.potentialRelatives;
        final currentRelationship = addedRelationships.firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _relationshipOptions.length,
                  itemBuilder: (context, index) {
                    final option = _relationshipOptions[index];

                    bool isSelected = false;
                    if (currentRelationship != null) {
                      final type = currentRelationship.relationshipType;

                      if (option['label'] == 'Parent' &&
                          (type == 'Father' || type == 'Mother')) {
                        isSelected = true;
                      } else if (type == option['label']) {
                        isSelected = true;
                      }
                    }

                    return _RelationshipCard(
                      label: option['label'],
                      icon: option['icon'],
                      color: option['color'],
                      isSelected: isSelected,
                      onTap: () {
                        _showMemberSelectionSheet(
                          context,
                          option['label'],
                          relatives,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            if (currentRelationship != null)
              Builder(
                builder: (context) {
                  final member = relatives.firstWhere(
                    (r) => r['id'] == currentRelationship.memberId,
                    orElse: () => {
                      'first_name': 'Unknown',
                      'last_name': 'Member',
                    },
                  );
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create connection with',
                                style: ShadTheme.of(
                                  context,
                                ).textTheme.muted.copyWith(fontSize: 12),
                              ),
                              Text(
                                '${member['first_name']} ${member['last_name']}',
                                style: ShadTheme.of(context).textTheme.p
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showMemberSelectionSheet(
    BuildContext parentContext,
    String relationshipLabel,
    List<Map<String, dynamic>> relatives,
  ) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MemberSelectionSheet(
          relationshipLabel: relationshipLabel,
          relatives: relatives,
          onMemberSelected: (memberId, memberGender) {
            String type = relationshipLabel;
            if (relationshipLabel == 'Parent') {
              if (memberGender == 'Male') {
                type = 'Father';
              } else if (memberGender == 'Female') {
                type = 'Mother';
              } else {
                type = 'Father'; // Default or handle unknown
              }
            }
            // Use setSingleRelationship to ensure only one relationship matches
            parentContext.read<AddCubit>().setSingleRelationship(
              memberId,
              type,
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _RelationshipCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RelationshipCard({
    required this.label,
    required this.icon,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ShadTheme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ShadTheme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: ShadTheme.of(context).textTheme.muted.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSelectionSheet extends StatefulWidget {
  final String relationshipLabel;
  final List<Map<String, dynamic>> relatives;
  final Function(String, String?) onMemberSelected;

  const _MemberSelectionSheet({
    required this.relationshipLabel,
    required this.relatives,
    required this.onMemberSelected,
  });

  @override
  State<_MemberSelectionSheet> createState() => _MemberSelectionSheetState();
}

class _MemberSelectionSheetState extends State<_MemberSelectionSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.relatives.where((m) {
      if (_searchQuery.isEmpty) return true;
      final name = '${m['first_name']} ${m['last_name']}'.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select ${widget.relationshipLabel}',
            style: ShadTheme.of(context).textTheme.large,
          ),
          const SizedBox(height: 16),
          ShadInput(
            placeholder: const Text('Search members...'),
            leading: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(LucideIcons.search, size: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No members found',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          backgroundImage: member['profile_image_url'] != null
                              ? NetworkImage(member['profile_image_url'])
                              : null,
                          child: member['profile_image_url'] == null
                              ? Text(
                                  member['first_name'][0],
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          '${member['first_name']} ${member['last_name']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Born: ${member['date_of_birth']?.toString().split(' ')[0] ?? 'Unknown'}',
                        ),
                        onTap: () {
                          widget.onMemberSelected(
                            member['id'],
                            member['gender'],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
