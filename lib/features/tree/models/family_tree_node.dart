import 'package:flutter_tree_graph/flutter_tree_graph.dart';

class FamilyTreeNode extends TreeNodeData {
  @override
  final String id;

  final String memberIdString; // User readable ID or UUID
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime? dob;
  final String gender;

  final String? nickname;
  final String? email;
  final String? phoneNumber;
  final String? occupation;
  final String? address;
  final String? city;
  final String? state;
  final DateTime? createdAt;

  final List<String> _parentIds;
  final String? _partnerId;

  FamilyTreeNode({
    required this.id,
    required this.memberIdString,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.dob,
    required this.gender,
    this.nickname,
    this.email,
    this.phoneNumber,
    this.occupation,
    this.address,
    this.city,
    this.state,
    this.createdAt,
    List<String> parentIds = const [],
    String? partnerId,
  }) : _parentIds = parentIds,
       _partnerId = partnerId;

  @override
  List<String> get parentIds => _parentIds;

  @override
  String? get partnerId => _partnerId;

  factory FamilyTreeNode.fromJson(
    Map<String, dynamic> json, {
    List<String>? parentIds,
    String? partnerId,
  }) {
    return FamilyTreeNode(
      id: json['id'] as String,
      memberIdString: json['member_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      dob: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'] ?? 'unknown',
      nickname: json['nickname'],
      occupation: json['occupation'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      parentIds: parentIds ?? [],
      partnerId: partnerId,
    );
  }
}
