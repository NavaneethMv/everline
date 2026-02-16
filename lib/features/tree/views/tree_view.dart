import 'package:everline/features/tree/bloc/tree_bloc.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart' as graph;
import 'package:shadcn_ui/shadcn_ui.dart';

class TreeView extends StatelessWidget {
  const TreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TreeBloc(repository: TreeRepository())..add(LoadTree()),
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
                nodeWidth: 160,
                nodeHeight: 100,
                horizontalSpacing: 40,
                verticalSpacing: 150,
                layout: graph.WalkersTreeLayout(),
                nodeBuilder: (context, node) {
                  return _buildNodeCard(context, node);
                },
                lineColor: ShadTheme.of(context).colorScheme.border,
                lineWidth: 2.0,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNodeCard(BuildContext context, FamilyTreeNode node) {
    final theme = ShadTheme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
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
                                node.firstName.substring(0, 1).toUpperCase(),
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
                          [
                            node.address,
                            node.city,
                            node.state,
                          ].where((e) => e != null && e.isNotEmpty).join(', '),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Container(
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
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (node.dob != null)
                Text(
                  '${node.dob!.year}',
                  style: theme.textTheme.muted.copyWith(fontSize: 10),
                ),
            ],
          ),
        ),
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
}
