import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/get_attendance_by_role_usecase.dart';
import 'teacher_attendance_state.dart';
import '../../../domain/entities/admin_class_attendance_entity.dart';

class TeacherAttendanceCubit extends Cubit<TeacherAttendanceState> {
  final GetAttendanceByRoleUsecase getAttendanceByRoleUsecase;

  TeacherAttendanceCubit({required this.getAttendanceByRoleUsecase}) 
      : super(TeacherAttendanceInitial());

  Future<void> fetchTeachersAttendance() async {
    emit(TeacherAttendanceLoading());
    try {
      // Langsung tembak role 'guru' tanpa tercampur data lain
      final listData = await getAttendanceByRoleUsecase('guru');
      emit(TeacherAttendanceLoaded(listData));
    } catch (e) {
      emit(TeacherAttendanceError(e.toString()));
    }
  }

  // Fitur checkbox khusus tabel guru
  void toggleCheckbox(int index, bool? value) {
    final currentState = state;
    if (currentState is TeacherAttendanceLoaded) {
      final updatedTeachers = List<AdminClassAttendanceEntity>.from(currentState.teachers);
      updatedTeachers[index] = updatedTeachers[index].copyWith(
        isSelected: value ?? false,
      );
      emit(TeacherAttendanceLoaded(updatedTeachers));
    }
  }
}