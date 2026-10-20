import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_attendance/employee_attendance_cubit.dart';
import '../cubit/employee_attendance/employee_attendance_state.dart';
import '../../data/repositories/admin_attendance_repository_impl.dart';
import '../../domain/usecase/get_attendance_by_role_usecase.dart';
import '../widgets/admin_karyawan_table_widget.dart';

class AdminKaryawanAttendanceScreen extends StatelessWidget {
  const AdminKaryawanAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Sediakan EmployeeAttendanceCubit khusus karyawan
      create: (context) => EmployeeAttendanceCubit(
        getAttendanceByRoleUsecase: GetAttendanceByRoleUsecase(
          AdminAttendanceRepositoryImpl(),
        ),
      )..fetchEmployeesAttendance(),
      child: const _AdminKaryawanAttendanceView(),
    );
  }
}

class _AdminKaryawanAttendanceView extends StatelessWidget {
  const _AdminKaryawanAttendanceView();

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
              "Panel Presensi Karyawan & Staf",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Daftar kehadiran seluruh staf dan karyawan Yayasan Pendidikan",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // --- KONTEN UTAMA (TABEL KARYAWAN) ---
            Expanded(
              child: BlocBuilder<EmployeeAttendanceCubit, EmployeeAttendanceState>(
                builder: (context, state) {
                  if (state is EmployeeAttendanceInitial || state is EmployeeAttendanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } 
                  if (state is EmployeeAttendanceError) {
                    return Center(
                      child: Text(
                        "Error: ${state.message}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } 
                  if (state is EmployeeAttendanceLoaded) {
                    return AdminKaryawanTableWidget(employees: state.employees);
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