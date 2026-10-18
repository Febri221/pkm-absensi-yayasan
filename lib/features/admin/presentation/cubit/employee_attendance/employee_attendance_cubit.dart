import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';
import '../../../domain/usecase/get_attendance_by_role_usecase.dart';
import 'employee_attendance_state.dart';

class EmployeeAttendanceCubit extends Cubit<EmployeeAttendanceState> {
  final GetAttendanceByRoleUsecase getAttendanceByRoleUsecase;

  EmployeeAttendanceCubit({required this.getAttendanceByRoleUsecase})
      : super(EmployeeAttendanceInitial());

  Future<void> fetchEmployeesAttendance() async {
    emit(EmployeeAttendanceLoading());
    try {
      // Spesifik narik role 'karyawan'
      final listData = await getAttendanceByRoleUsecase('karyawan');
      emit(EmployeeAttendanceLoaded(listData));
    } catch (e) {
      emit(EmployeeAttendanceError(e.toString()));
    }
  }

  void toggleCheckbox(int index, bool? value) {
    final currentState = state;
    if (currentState is EmployeeAttendanceLoaded) {
      final updatedEmployees = List<AdminClassAttendanceEntity>.from(currentState.employees);
      updatedEmployees[index] = updatedEmployees[index].copyWith(
        isSelected: value ?? false,
      );
      emit(EmployeeAttendanceLoaded(updatedEmployees));
    }
  }
}