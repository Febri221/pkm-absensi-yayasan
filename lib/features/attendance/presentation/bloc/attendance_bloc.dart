import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/check_geofence_usecase.dart';
import '../../domain/usecase/submit_attendance_usecase.dart';
import '../../domain/usecase/get_attendance_status_usecase.dart'; // Import UseCase baru
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckGeofenceUseCase checkGeofenceUseCase;
  final SubmitAttendanceUsecase submitAttendanceUsecase;
  final GetAttendanceStatusUseCase getAttendanceStatusUseCase; // Cukup UseCase saja!

  AttendanceBloc({
    required this.checkGeofenceUseCase,
    required this.submitAttendanceUsecase,
    required this.getAttendanceStatusUseCase, // Masukin ke constructor
  }) : super(AttendanceInitial()) {
    
 

    // --- EVENT 2: SUBMIT ABSEN ---
    on<SubmitAttendanceButtonPressed>((event, emit) async {
      emit(AttendanceSubmitting());
      try {
        await submitAttendanceUsecase(
          latitude: event.latitude,
          longitude: event.longitude,
          statusKehadiran: 'tepat_waktu',
          tipeAbsen: event.tipeAbsen,
        );
        emit(const AttendanceSubmitSuccess('Absen Berhasil Dicatat! 🎉'));
      } catch (e) {
        emit(AttendanceError(e.toString()));
      }
    });

    // --- EVENT 3: LOAD STATUS 1 TOMBOL PINTAR (BERSIH & SESUAI CLEAN ARCHITECTURE) ---
    on<LoadAttendanceStatusEvent>((event, emit) async {
      emit(AttendanceLoading());
      try {
        // 1. Panggil UseCase buat dapetin status database (sudah masuk/pulang, jam pulang)
        final statusMap = await getAttendanceStatusUseCase();
        

        final geoResult = await checkGeofenceUseCase(
          targetLatitude: -6.358511,
          targetLongitude: 106.562474,
          radius: 70.0,
        );

        // 3. Kirim semua datanya secara rapi ke UI lewat AttendanceLoaded yang udah di-upgrade
        emit(AttendanceLoaded(
          geoData: geoResult,
          sudahMasuk: statusMap['sudahMasuk'],
          sudahPulang: statusMap['sudahPulang'],
          jamPulang: statusMap['jamPulang'],
        ));
      } catch (e) {
        emit(AttendanceError(e.toString()));
      }
    });
  }
}