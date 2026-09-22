import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final double distanceInMeters;
  final bool isWithinRadius;

  const AttendanceEntity({required this.distanceInMeters, required this.isWithinRadius});

  @override
  List<Object?> get props => [distanceInMeters, isWithinRadius];
}