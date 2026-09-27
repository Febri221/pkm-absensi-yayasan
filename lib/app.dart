import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/data/repository/attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/check_geofence_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/submit_attendance_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/presentation/screen/attendance_screen.dart';
import 'package:sistem_absensi_sekolah/features/auth/data/repository/auth_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/auth/domain/repositories/auth_repository.dart';
import 'package:sistem_absensi_sekolah/features/auth/domain/usecase/login_usecase.dart';
import 'package:sistem_absensi_sekolah/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sistem_absensi_sekolah/features/auth/presentation/screen/login_screen.dart';

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
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        ),
      ),
    );
  }
}
