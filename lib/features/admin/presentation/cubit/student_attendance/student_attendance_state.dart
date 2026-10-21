import 'package:equatable/equatable.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';

sealed class StudentAttendanceState extends Equatable {
  const StudentAttendanceState();

  @override
  List<Object?> get props => [];
}

class StudentAttendanceInitial extends StudentAttendanceState {}

class StudentAttendanceLoading extends StudentAttendanceState {}

// State khusus ketika daftar pilihan kelas (dropdown) berhasil ditarik
class StudentClassesLoaded extends StudentAttendanceState {
  final Map<String, List<String>> classesMap;
  const StudentClassesLoaded(this.classesMap);

  @override
  List<Object> get props => [classesMap];
}

// State ketika data siswa dalam satu kelas berhasil ditampilkan & di-stream
class StudentAttendanceLoaded extends StudentAttendanceState {
  final List<AdminClassAttendanceEntity> students;
  final String selectedClass;
  final Map<String, List<String>> classesMap; 
  final DateTime tanggalDipilih;

  const StudentAttendanceLoaded({
    required this.students,
    required this.selectedClass,
    required this.classesMap,
    required this.tanggalDipilih,
  });

  @override
  List<Object> get props => [students, selectedClass, classesMap, tanggalDipilih];
}

class StudentAttendanceError extends StudentAttendanceState {
  final String message;
  const StudentAttendanceError(this.message);

  @override
  List<Object> get props => [message];
}