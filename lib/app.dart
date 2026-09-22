import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/data/repository/attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/check_geofence_usecase.dart';
import 'package:sistem_absensi_sekolah/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/presentation/screen/attendance_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AttendanceRepository>(
          create: (context) => AttendanceRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AttendanceBloc(
              checkGeofenceUseCase: CheckGeofenceUseCase(
                context.read<AttendanceRepository>(),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AttendanceScreen(),
        ),
      ),
    );
  }
}
