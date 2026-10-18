import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/teacher_attendance/teacher_attendance_cubit.dart';
import '../cubit/teacher_attendance/teacher_attendance_state.dart';
import '../../data/repositories/admin_class_repository_impl.dart';
import '../../domain/usecase/get_attendance_by_role_usecase.dart';
import '../widgets/admin_guru_table_widget.dart';

class AdminGuruAttendanceScreen extends StatelessWidget {
  const AdminGuruAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Sediakan TeacherAttendanceCubit dan langsung tembak fetch data guru
      create: (context) => TeacherAttendanceCubit(
        getAttendanceByRoleUsecase: GetAttendanceByRoleUsecase(
          AdminClassRepositoryImpl(),
        ),
      )..fetchTeachersAttendance(),
      child: const _AdminGuruAttendanceView(),
    );
  }
}

class _AdminGuruAttendanceView extends StatelessWidget {
  const _AdminGuruAttendanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER JUDUL ---
            const Text(
              "Panel Presensi Dewan Guru",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Daftar kehadiran seluruh dewan guru Yayasan Pendidikan",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // --- KONTEN UTAMA (TABEL GURU) ---
            Expanded(
              child:
                  BlocBuilder<TeacherAttendanceCubit, TeacherAttendanceState>(
                    builder: (context, state) {
                      if (state is TeacherAttendanceInitial ||
                          state is TeacherAttendanceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is TeacherAttendanceError) {
                        return Center(
                          child: Text(
                            "Error: ${state.message}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (state is TeacherAttendanceLoaded) {
                        return AdminGuruTableWidget(teachers: state.teachers);
                      }

                      return const SizedBox();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
