import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/bulk_update_attendance_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_students_by_class_stream_usecase.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';
import '../../../domain/usecase/get_classes_usecase.dart';
import 'student_attendance_state.dart';

class StudentAttendanceCubit extends Cubit<StudentAttendanceState> {
  final GetAttendanceByClassUseCase getAttendanceByClassUseCase;
  final GetClassesUsecase getClassesUsecase;
  final BulkUpdateAttendanceUsecase bulkUpdateAttendanceUsecase;

  StudentAttendanceCubit({
    required this.getAttendanceByClassUseCase,
    required this.getClassesUsecase,
    required this.bulkUpdateAttendanceUsecase,
  }) : super(StudentAttendanceInitial());

  // 1. Tarik daftar kelas untuk dropdown dinamis
  Future<void> fetchAvailableClasses() async {
    emit(StudentAttendanceLoading());
    try {
      final classesMap = await getClassesUsecase();
      emit(StudentClassesLoaded(classesMap));
    } catch (e) {
      emit(StudentAttendanceError(e.toString()));
    }
  }

  // 2. Stream data siswa berdasarkan kelas yang dipilih
  void watchStudentsByClass(
    String kelas,
    Map<String, List<String>> currentClassesMap,
  ) {
    emit(StudentAttendanceLoading());
    try {
      getAttendanceByClassUseCase(kelas).listen(
        (students) {
          emit(
            StudentAttendanceLoaded(
              students: students,
              selectedClass: kelas,
              classesMap: currentClassesMap,
            ),
          );
        },
        onError: (error) {
          emit(StudentAttendanceError(error.toString()));
        },
      );
    } catch (e) {
      emit(StudentAttendanceError(e.toString()));
    }
  }

  // 3. Toggle checkbox interaktif tabel siswa
  void toggleCheckbox(int index, bool? value) {
    final currentState = state;
    if (currentState is StudentAttendanceLoaded) {
      final updatedStudents = List<AdminClassAttendanceEntity>.from(
        currentState.students,
      );
      updatedStudents[index] = updatedStudents[index].copyWith(
        isSelected: value ?? false,
      );

      emit(
        StudentAttendanceLoaded(
          students: updatedStudents,
          selectedClass: currentState.selectedClass,
          classesMap: currentState.classesMap,
        ),
      );
    }
  }

  Future<void> saveButtonAttendance(
    String statusTarget,
    String currentKelas,
  ) async {
    final currentState = state;

    if (currentState is StudentAttendanceLoaded) {
      final List<String> selectedUserIds = currentState.students
          .where((student) => student.isSelected)
          .map((student) => student.idSiswa)
          .toList();

        if (selectedUserIds.isEmpty) {
          return;
        }
      emit(StudentAttendanceLoading());
      try {
      await bulkUpdateAttendanceUsecase(
        userIds: selectedUserIds, 
        status: statusTarget,
      );

      watchStudentsByClass(currentKelas, currentState.classesMap);
      } catch (e) {
        emit(StudentAttendanceError(e.toString()));
      }
    }
  }

  // Fungsi buat nyentang atau nge-uncheck SEMUA siswa sekaligus
  void toggleSelectAll(bool? value) {
    final currentState = state;
    if (currentState is StudentAttendanceLoaded) {
      final updatedStudents = currentState.students.map((student) {
        return student.copyWith(isSelected: value ?? false);
      }).toList();

      emit(
        StudentAttendanceLoaded(
          students: updatedStudents,
          selectedClass: currentState.selectedClass,
          classesMap: currentState.classesMap,
        ),
      );
    }
  }

  
}
