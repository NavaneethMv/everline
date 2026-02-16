import 'dart:developer';

import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/tree/bloc/tree_bloc.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:everline/features/tree/views/edit_relationship_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart' as graph;
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TreeView extends StatelessWidget {
  const TreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TreeRepository(),
      child: BlocProvider(
        create: (context) =>
            TreeBloc(repository: context.read<TreeRepository>())
              ..add(LoadTree()),
        child: Scaffold(
          backgroundColor: ShadTheme.of(context).colorScheme.background,
          body: BlocBuilder<TreeBloc, TreeState>(
            builder: (context, state) {
              if (state is TreeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TreeError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      color: ShadTheme.of(context).colorScheme.destructive,
                    ),
                  ),
                );
              }
              if (state is TreeLoaded) {
                if (state.nodes.isEmpty) {
                  return const Center(
                    child: Text('No family members found. Add some!'),
                  );
                }
                return graph.TreeView<FamilyTreeNode>(
                  data: state.nodes,
                  nodeWidth: 120,
                  nodeHeight: 160,
                  horizontalSpacing: 80,
                  verticalSpacing: 220,
                  layout: graph.WalkersTreeLayout(),
                  nodeBuilder: (context, node) {
                    return _buildNodeCard(context, node, state.relationships);
                  },
                  lineColor: ShadTheme.of(context).colorScheme.border,
                  lineWidth: 2.0,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  bool _hasRelationships(
    FamilyTreeNode node,
    List<Map<String, dynamic>> relationships,
  ) {
    return relationships.any(
      (rel) => rel['member1_id'] == node.id || rel['member2_id'] == node.id,
    );
  }

  Widget _buildNodeCard(
    BuildContext context,
    FamilyTreeNode node,
    List<Map<String, dynamic>> relationships,
  ) {
    final theme = ShadTheme.of(context);
    final hasRelationships = _hasRelationships(node, relationships);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: theme.colorScheme.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: node.profileImageUrl != null
                                ? NetworkImage(node.profileImageUrl!)
                                : null,
                            child: node.profileImageUrl == null
                                ? Text(
                                    node.firstName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: theme.textTheme.large.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${node.firstName} ${node.lastName}',
                            style: theme.textTheme.h3,
                            textAlign: TextAlign.center,
                          ),
                          if (node.dob != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Born: ${node.dob!.day}/${node.dob!.month}/${node.dob!.year}',
                              style: theme.textTheme.muted,
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildDetailRow('Gender', node.gender),
                          if (node.nickname != null)
                            _buildDetailRow('Nickname', node.nickname!),
                          if (node.email != null)
                            _buildDetailRow('Email', node.email!),
                          if (node.phoneNumber != null)
                            _buildDetailRow('Phone', node.phoneNumber!),
                          if (node.occupation != null)
                            _buildDetailRow('Occupation', node.occupation!),
                          if (node.address != null ||
                              node.city != null ||
                              node.state != null)
                            _buildDetailRow(
                              'Location',
                              [node.address, node.city, node.state]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: node.profileImageUrl != null
                        ? NetworkImage(node.profileImageUrl!)
                        : null,
                    child: node.profileImageUrl == null
                        ? Text(
                            node.firstName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${node.firstName} ${node.lastName}',
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (node.dob != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${node.dob!.year}',
                      style: theme.textTheme.muted.copyWith(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 35,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                if (hasRelationships) {
                  await _showEditRelationshipSheet(context, node);
                } else {
                  // Show bottom sheet to add relationship
                  await _showAddRelationshipSheet(context, node);
                }
              },
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.background,
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Icon(
                  hasRelationships ? LucideIcons.users : LucideIcons.plus,
                  size: 16,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 100,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                try {
                  // Fetch the full member data
                  final repository = TreeRepository();
                  final memberData = await repository.fetchMemberById(node.id);

                  if (context.mounted) {
                    // Initialize the form in edit mode
                    context.read<AddCubit>().initializeEditMode(memberData);

                    // Navigate to add form
                    context.goNamed('add');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ShadToaster.of(context).show(
                      ShadToast.destructive(
                        title: const Text('Error'),
                        description: Text('Failed to load member data: $e'),
                      ),
                    );
                  }
                }
              },
              child: Container(
                height: 32,
                width: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.background,
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: -12,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _confirmDeleteNode(context, node),
              child: Container(
                height: 32,
                width: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.destructive,
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Icon(
                  LucideIcons.trash,
                  size: 16,
                  color: theme.colorScheme.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRelationshipSheet(
    BuildContext context,
    FamilyTreeNode node,
  ) async {
    final repository = TreeRepository();
    final members = await repository.fetchMembers();

    // Filter out the current node from the list
    final availableMembers = members.where((m) => m['id'] != node.id).toList();

    if (!context.mounted) return;

    final relationshipOptions = [
      {'label': 'Parent', 'icon': LucideIcons.heart, 'color': Colors.red},
      {'label': 'Child', 'icon': LucideIcons.baby, 'color': Colors.orange},
      {'label': 'Spouse', 'icon': LucideIcons.userPlus, 'color': Colors.purple},
    ];

    String? selectedMemberId;
    String? selectedRelationshipLabel;
    String? selectedRelationshipType;
    Map<String, dynamic>? selectedMember;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    'Add Relationship',
                    style: ShadTheme.of(context).textTheme.large,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'for ${node.firstName} ${node.lastName}',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: relationshipOptions.length,
                    itemBuilder: (context, index) {
                      final option = relationshipOptions[index];
                      final isSelected =
                          selectedRelationshipLabel == option['label'];

                      return _RelationshipCard(
                        label: option['label'] as String,
                        icon: option['icon'] as IconData,
                        color: option['color'] as Color,
                        isSelected: isSelected,
                        onTap: () {
                          _showMemberSelectionSheet(
                            context,
                            option['label'] as String,
                            availableMembers,
                            (memberId, _) {
                              setModalState(() {
                                selectedMemberId = memberId;
                                selectedMember = availableMembers.firstWhere(
                                  (m) => m['id'] == memberId,
                                );
                                selectedRelationshipLabel =
                                    option['label'] as String;

                                if (selectedRelationshipLabel == 'Parent') {
                                  selectedRelationshipType = 'parent';
                                } else {
                                  selectedRelationshipType =
                                      selectedRelationshipLabel?.toLowerCase();
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  if (selectedMember != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.check, color: Colors.green),
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
                                  '${selectedMember!['first_name']} ${selectedMember!['last_name']}',
                                  style: ShadTheme.of(context).textTheme.p
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'as $selectedRelationshipType',
                                  style: ShadTheme.of(
                                    context,
                                  ).textTheme.muted.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.outline(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          enabled:
                              selectedMemberId != null &&
                              selectedRelationshipType != null,
                          child: const Text('Apply'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == true &&
        selectedMemberId != null &&
        selectedRelationshipType != null) {
      try {
        await repository.addRelationship(
          member1Id: node.id,
          member2Id: selectedMemberId!,
          relationshipType: selectedRelationshipType!,
        );

        final reverseType = _getReverseRelationType(selectedRelationshipType!);
        if (reverseType != null) {
          await repository.addRelationship(
            member1Id: selectedMemberId!,
            member2Id: node.id,
            relationshipType: reverseType,
          );
        }

        if (context.mounted) {
          context.read<TreeBloc>().add(LoadTree());
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Success'),
              description: Text('Relationship added successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text('Failed to add relationship: $e'),
            ),
          );
        }
      }
    }
  }

  void _showMemberSelectionSheet(
    BuildContext parentContext,
    String relationshipLabel,
    List<Map<String, dynamic>> relatives,
    Function(String, String?) onMemberSelected,
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
            onMemberSelected(memberId, memberGender);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteNode(
    BuildContext context,
    FamilyTreeNode node,
  ) async {
    final confirm = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        constraints: BoxConstraints(maxWidth: 400),
        radius: BorderRadius.all(Radius.circular(25.0)),
        title: const Text('Delete Member'),
        description: const Text(
          'Are you sure you want to delete this member? This action cannot be undone and will remove all relationships.',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      try {
        await context.read<TreeRepository>().deleteMember(node.id);
        if (context.mounted) {
          context.read<TreeBloc>().add(LoadTree());
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Success'),
              description: Text('Member deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          log(e.toString());
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text('Failed to delete member: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditRelationshipSheet(
    BuildContext context,
    FamilyTreeNode node,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditRelationshipSheet(node: node),
    );

    if (context.mounted) {
      context.read<TreeBloc>().add(LoadTree());
    }
  }

  String? _getReverseRelationType(String type) {
    switch (type) {
      case 'parent':
        return 'child';
      case 'child':
        return 'parent';
      case 'spouse':
        return 'spouse';
      default:
        return null;
    }
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
    var filtered = widget.relatives;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final name = '${m['first_name']} ${m['last_name']}'.toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

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
