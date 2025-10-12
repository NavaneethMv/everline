import 'package:everline/features/tree/models/family_member.dart';
import 'package:flutter/material.dart';

class TreeView extends StatefulWidget {
  const TreeView({super.key});

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final TransformationController _transformationController =
      TransformationController();

  // Sample family members - Replace with your Supabase data
  List<FamilyMember> familyMembers = [
    FamilyMember(
      id: '1',
      name: 'John Doe',
      relation: 'Self',
      position: const Offset(200, 300),
    ),
    FamilyMember(
      id: '2',
      name: 'Jane Doe',
      relation: 'Wife',
      position: const Offset(400, 300),
    ),
    FamilyMember(
      id: '3',
      name: 'Mike Doe',
      relation: 'Father',
      position: const Offset(200, 100),
    ),
    FamilyMember(
      id: '4',
      name: 'Sarah Doe',
      relation: 'Mother',
      position: const Offset(400, 100),
    ),
  ];

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _addMember() {
    // Add new member at center of current view
    setState(() {
      familyMembers.add(
        FamilyMember(
          id: DateTime.now().toString(),
          name: 'New Member',
          relation: 'Relation',
          position: const Offset(300, 200),
        ),
      );
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main interactive viewer with grid and family members
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(5000),
          minScale: 0.1,
          maxScale: 4.0,
          child: SizedBox(
            width: 10000,
            height: 10000,
            child: CustomPaint(
              painter: GridPainter(),
              child: Stack(
                children: [
                  // Draw connection lines
                  CustomPaint(
                    painter: ConnectionPainter(familyMembers),
                    size: const Size(10000, 10000),
                  ),
                  // Draw family members
                  ...familyMembers.map((member) {
                    return Positioned(
                      left: member.position.dx,
                      top: member.position.dy,
                      child: Draggable(
                        feedback: FamilyMemberCard(
                          member: member,
                          isDragging: true,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: FamilyMemberCard(member: member),
                        ),
                        onDragEnd: (details) {
                          setState(() {
                            member.position = details.offset;
                          });
                        },
                        child: FamilyMemberCard(member: member),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        // Floating controls
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'reset',
                onPressed: _resetZoom,
                mini: true,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'add',
                onPressed: _addMember,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Grid Background Painter (scales infinitely)
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Extend grid beyond visible area for zooming out
    const extension = 5000.0;
    final extendedWidth = size.width + extension * 2;
    final extendedHeight = size.height + extension * 2;

    // Vertical lines
    for (double x = -extension; x < extendedWidth; x += gridSize) {
      canvas.drawLine(Offset(x, -extension), Offset(x, extendedHeight), paint);
    }

    // Horizontal lines
    for (double y = -extension; y < extendedHeight; y += gridSize) {
      canvas.drawLine(Offset(-extension, y), Offset(extendedWidth, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Connection Lines Painter (for relationships)
class ConnectionPainter extends CustomPainter {
  final List<FamilyMember> members;

  ConnectionPainter(this.members);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Example: Draw line from first to second member
    // You can customize this based on relationships
    if (members.length > 1) {
      for (int i = 0; i < members.length - 1; i++) {
        final start = Offset(
          members[i].position.dx + 60,
          members[i].position.dy + 40,
        );
        final end = Offset(
          members[i + 1].position.dx + 60,
          members[i + 1].position.dy + 40,
        );
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Family Member Card Widget
class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final bool isDragging;

  const FamilyMemberCard({
    super.key,
    required this.member,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isDragging ? 8 : 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: member.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        member.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      member.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.relation,
                style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
