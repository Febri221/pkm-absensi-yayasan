import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/data/repository/attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/check_geofence_usecase.dart';
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AttendanceBloc(
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
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        ),
      ),
    );
  }
}
