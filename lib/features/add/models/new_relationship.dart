import 'package:equatable/equatable.dart';

class NewRelationship extends Equatable {
  final String memberId;
  final String relationshipType; // 'Father', 'Mother', 'Spouse', 'Child'

  const NewRelationship({
    required this.memberId,
    required this.relationshipType,
  });

  @override
  List<Object> get props => [memberId, relationshipType];
}
