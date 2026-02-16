import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditRelationshipSheet extends StatefulWidget {
  final FamilyTreeNode node;

  const EditRelationshipSheet({super.key, required this.node});

  @override
  State<EditRelationshipSheet> createState() => _EditRelationshipSheetState();
}

class _EditRelationshipSheetState extends State<EditRelationshipSheet> {
  final TreeRepository _repository = TreeRepository();
  List<Map<String, dynamic>> _relationships = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRelationships();
  }

  Future<void> _loadRelationships() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allRelationships = await _repository.fetchRelationships();
      final members = await _repository.fetchMembers();

      // Filter relationships where this node is member1 or member2
      final nodeRelationships = allRelationships.where((rel) {
        return rel['member1_id'] == widget.node.id ||
            rel['member2_id'] == widget.node.id;
      }).toList();

      // Enrich with member details
      final enriched = nodeRelationships.map((rel) {
        final isNodeMember1 = rel['member1_id'] == widget.node.id;
        final otherMemberId = isNodeMember1
            ? rel['member2_id']
            : rel['member1_id'];

        final otherMember = members.firstWhere(
          (m) => m['id'] == otherMemberId,
          orElse: () => {
            'first_name': 'Unknown',
            'last_name': 'Member',
            'gender': null,
          },
        );

        return {
          'member1_id': rel['member1_id'],
          'member2_id': rel['member2_id'],
          'relationship_type': rel['relationship_type'],
          'other_member_id': otherMemberId,
          'other_member_name':
              '${otherMember['first_name']} ${otherMember['last_name']}',
          'other_member_gender': otherMember['gender'],
          'is_node_member1': isNodeMember1,
        };
      }).toList();

      // Remove duplicates - keep only unique pairs
      final uniqueRelationships = <Map<String, dynamic>>[];
      final seenPairs = <String>{};

      for (final rel in enriched) {
        final member1 = rel['member1_id'];
        final member2 = rel['member2_id'];
        // Create a consistent key regardless of order
        final pairKey = member1.compareTo(member2) < 0
            ? '$member1-$member2'
            : '$member2-$member1';

        if (!seenPairs.contains(pairKey)) {
          seenPairs.add(pairKey);
          uniqueRelationships.add(rel);
        }
      }

      if (mounted) {
        setState(() {
          _relationships = uniqueRelationships;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRelationship(Map<String, dynamic> relationship) async {
    final confirm = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        constraints: const BoxConstraints(maxWidth: 400),
        radius: BorderRadius.circular(25),
        removeBorderRadiusWhenTiny: false,
        title: const Text('Delete Relationship'),
        description: Text(
          'Are you sure you want to delete the relationship with ${relationship['other_member_name']}?',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ShadButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete both directional relationships
        await _repository.deleteRelationship(
          member1Id: relationship['member1_id'],
          member2Id: relationship['member2_id'],
        );
        // Also delete the reverse direction
        await _repository.deleteRelationship(
          member1Id: relationship['member2_id'],
          member2Id: relationship['member1_id'],
        );
        await _loadRelationships();
        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Success'),
              description: Text('Relationship deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text('Failed to delete relationship: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Relationships', style: theme.textTheme.h4),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ShadThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: theme.colorScheme.destructive),
            const SizedBox(height: 16),
            Text('Error loading relationships', style: theme.textTheme.large),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShadButton(
              child: const Text('Retry'),
              onPressed: _loadRelationships,
            ),
          ],
        ),
      );
    }
    if (_relationships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 48,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text('No relationships found', style: theme.textTheme.large),
            const SizedBox(height: 8),
            Text(
              'This member has no relationships yet',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _relationships.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final relationship = _relationships[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relationship['other_member_name'],
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relationship['relationship_type'],
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.trash,
                  color: theme.colorScheme.destructive,
                ),
                onPressed: () => _deleteRelationship(relationship),
              ),
            ],
          ),
        );
      },
    );
  }
}
