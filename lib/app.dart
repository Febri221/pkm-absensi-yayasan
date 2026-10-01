import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/data/repositories/admin_attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/repositories/admin_attendance_repository.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_admin_attendance_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/screen/admin_login_screen.dart';
import 'package:sistem_absensi_sekolah/features/attendance/data/repository/attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/check_geofence_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/get_attendance_status_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/submit_attendance_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:sistem_absensi_sekolah/features/auth/data/repository/auth_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/auth/domain/repositories/auth_repository.dart';
import 'package:sistem_absensi_sekolah/features/auth/domain/usecase/login_usecase.dart';
import 'package:sistem_absensi_sekolah/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sistem_absensi_sekolah/features/auth/presentation/screen/login_screen.dart';
import 'package:sistem_absensi_sekolah/features/history/data/repositories/history_repositories_impl.dart';
import 'package:sistem_absensi_sekolah/features/history/domain/repositories/history_repository.dart';
import 'package:sistem_absensi_sekolah/features/history/domain/usecase/get_history_usecase.dart';
import 'package:sistem_absensi_sekolah/features/history/presentation/bloc/history_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AttendanceRepository>(
          create: (context) => AttendanceRepositoryImpl(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<HistoryRepository>(
          create: (context) => HistoryRepositoriesImpl(),
        ),
        RepositoryProvider<AdminAttendanceRepository>(
          create: (context) => AdminAttendanceRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AttendanceBloc(
              getAttendanceStatusUseCase: GetAttendanceStatusUseCase(
                context.read<AttendanceRepository>(),
              ),
              checkGeofenceUseCase: CheckGeofenceUseCase(
                context.read<AttendanceRepository>(),
              ),
              submitAttendanceUsecase: SubmitAttendanceUsecase(
                context.read<AttendanceRepository>(),
              ),
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              loginUsecase: LoginUsecase(context.read<AuthRepository>()),
            ),
          ),
          BlocProvider(
            create: (context) => HistoryBloc(
              getHistoryUsecase: GetHistoryUsecase(
                context.read<HistoryRepository>(),
              ),
            ),
          ),
          // BlocProvider(
          //   create: (context) => AdminDashboardCubit(
          //     getAdminAttendanceUseCase: GetAdminAttendanceUseCase(
          //       context.read<AdminAttendanceRepository>(),
          //     ),
          //   ),
          // ),
          
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: kIsWeb ? const AdminLoginScreen() : LoginScreen(),
        ),
      ),
    );
  }
}
