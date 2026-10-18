import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/attendance/domain/usecase/get_school_settings_usecase.dart';
import '../../domain/usecase/check_geofence_usecase.dart';
import '../../domain/usecase/submit_attendance_usecase.dart';
import '../../domain/usecase/get_attendance_status_usecase.dart'; // Import UseCase baru
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckGeofenceUseCase checkGeofenceUseCase;
  final SubmitAttendanceUseCase submitAttendanceUsecase;
  final GetAttendanceStatusUseCase getAttendanceStatusUseCase;
  final GetSchoolSettingsUseCase getSchoolSettingsUseCase;

  AttendanceBloc({
    required this.checkGeofenceUseCase,
    required this.submitAttendanceUsecase,
    required this.getAttendanceStatusUseCase,
    required this.getSchoolSettingsUseCase,
  }) : super(AttendanceInitial()) {
    // --- EVENT 2: SUBMIT ABSEN ---
    on<SubmitAttendanceButtonPressed>((event, emit) async {
      emit(AttendanceSubmitting());
      try {
        await submitAttendanceUsecase(tipeAbsen: event.tipeAbsen);
        emit(const AttendanceSubmitSuccess('Absen Berhasil Dicatat! 🎉'));
      } catch (e) {
        final cleanMessage = e.toString().replaceAll('Exception: ', '').trim();
        emit(AttendanceError(cleanMessage));
      }
    });

    // --- EVENT 3: LOAD STATUS 1 TOMBOL PINTAR (BERSIH & SESUAI CLEAN ARCHITECTURE) ---
    on<LoadAttendanceStatusEvent>((event, emit) async {
      emit(AttendanceLoading());
      try {
        final statusMap = await getAttendanceStatusUseCase();

        final settingsMap = await getSchoolSettingsUseCase();

        final double schoolLat = settingsMap['lat'];
        final double schoolLong = settingsMap['lng'];
        final double radius = settingsMap['radius'];

        final geoResult = await checkGeofenceUseCase(
          targetLatitude: schoolLat,
          targetLongitude: schoolLong,
          radius: radius,
        );

        emit(
          AttendanceLoaded(
            geoData: geoResult,
            sudahMasuk: statusMap['sudahMasuk'] as bool,
            sudahPulang: statusMap['sudahPulang'] as bool,
            jamPulang: statusMap['jamPulang'].toString(),
            isLibur: statusMap['isLibur'] as bool,
          ),
        );
      } catch (e, stackTrace) {
        print("--- ERROR TERTANGKAP DI BLOC ---");
        print("Pesan Error: $e");
        print("Jejak Error (StackTrace): $stackTrace");

        final cleanMessage = e.toString().replaceAll('Exception: ', '').trim();
        emit(AttendanceError(cleanMessage));
      }
    });


  }
}
