import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_admin_attendance_usecase.dart';
import 'admin_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAdminAttendanceUseCase getAdminAttendanceUseCase;

  AdminDashboardCubit({required this.getAdminAttendanceUseCase})
      : super(AdminDashboardInitial());

  Future<void> fetchAttendanceData() async {
  emit(AdminDashboardLoading());
  try {
    final listData = await getAdminAttendanceUseCase();
    print("CUBIT BERHASIL DAPET DATA: ${listData.length} item"); // <-- TAMBAHIN INI
    emit(AdminDashboardLoaded(listData));
  } catch (e) {
    print("CUBIT ERROR: $e"); // <-- TAMBAHIN INI
    emit(AdminDashboardError(e.toString()));
  }
}
}