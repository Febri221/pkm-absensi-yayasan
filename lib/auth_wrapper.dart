import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/admin/presentation/screen/admin_login_screen.dart'; 
import 'features/auth/presentation/screen/login_screen.dart';
import 'package:sistem_absensi_sekolah/navigation/presentation/screen/main_navigation_screen.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/screen/admin_main_layout_screen.dart';
import 'package:sistem_absensi_sekolah/features/admin/data/repositories/admin_attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/bulk_insert_users_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_attendance_by_role_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_classes_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_students_by_class_stream_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/cubit/admin_cubit.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Mendengarkan perubahan status autentikasi dari Supabase secara real-time
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Kalau masih loading/mengecek koneksi token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Ambil data sesi user yang aktif saat ini
        final session = snapshot.data?.session;

        if (session != null) {

          if (kIsWeb) {
            return BlocProvider(
              create: (context) => AdminDashboardCubit(
                getClassesUsecase: GetClassesUsecase(
                  AdminAttendanceRepositoryImpl(),
                ),
                bulkInsertUsersUsecase: BulkInsertUsersUsecase(
                  AdminAttendanceRepositoryImpl(),
                ),
                getAttendanceByRoleUsecase: GetAttendanceByRoleUsecase(
                  AdminAttendanceRepositoryImpl(),
                ),
                getAttendanceByClassUseCase: GetAttendanceByClassUseCase(
                  AdminAttendanceRepositoryImpl(),
                ),
              )..fetchAvailableClass(), // Opsional: langsung tarik data kelas pas dibuka
              child: const AdminMainLayoutScreen(),
            );
          } else {
            // Jika di Android/Mobile, arahkan ke Home Absensi Siswa/Guru
            return const MainNavigationScreen();
          }
        } else {
          // ==========================================
          // KONDISI: USER BELUM LOGIN (Sesi Kosong)
          // ==========================================
          if (kIsWeb) {
            return const AdminLoginScreen();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}
