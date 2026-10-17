import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/entities/admin_class_attendance_entity.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/bulk_insert_users_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_attendance_by_role_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_students_by_class_stream_usecase.dart';
import 'admin_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAttendanceByClassUseCase getAttendanceByClassUseCase;
  final GetAttendanceByRoleUsecase getAttendanceByRoleUsecase;
  final BulkInsertUsersUsecase bulkInsertUsersUsecase;

  AdminDashboardCubit({
    required this.getAttendanceByClassUseCase,
    required this.getAttendanceByRoleUsecase,
    required this.bulkInsertUsersUsecase,
  }) : super(AdminDashboardInitial());

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

  Future<void> fetchAttendanceByRole(String role) async {
    emit(AdminDashboardLoading());

    try {
      final listData = await getAttendanceByRoleUsecase(role);
      emit(
        AdminDashboardLoaded(
          students: listData,
          selectedClass: role.toUpperCase(),
        ),
      );
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> uploadCsvData(String csvString) async {
    emit(AdminDashboardLoading());
    try{
      await bulkInsertUsersUsecase(csvString);
      emit(AdminDashboardError("UPLOAD_SUCCES"));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }
}
