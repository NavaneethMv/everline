import 'dart:ui';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  Offset position;
  final String? imageUrl;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.position,
    this.imageUrl,
  });
}
