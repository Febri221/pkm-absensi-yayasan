import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/entities/admin_class_attendance_entity.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_students_by_class_stream_usecase.dart';
import 'admin_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAttendanceByClassUseCase getAttendanceByClassUseCase;

  AdminDashboardCubit({required this.getAttendanceByClassUseCase})
    : super(AdminDashboardInitial());

  void watchStudentsByClass(String kelas) {
    emit(AdminDashboardLoading());
    try {
      // CARA PALING GAMPANG DAN AMAN DI CUBIT: Pake .listen()
      getAttendanceByClassUseCase(kelas).listen(
        (students) {
          emit(AdminDashboardLoaded(students: students, selectedClass: kelas));
        },
        onError: (error) {
          emit(AdminDashboardError(error.toString()));
        },
      );
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  void toggleCheckbox(int index, bool? value) {
    final currentState = state;
    if (currentState is AdminDashboardLoaded) {
      final updateStudents = List<AdminClassAttendanceEntity>.from(
        currentState.students,
      );
      updateStudents[index] = updateStudents[index].copyWith(
        isSelected: value ?? false,
      );

      emit(
        AdminDashboardLoaded(
          students: updateStudents,
          selectedClass: currentState.selectedClass,
        ),
      );
    }
  }
}
