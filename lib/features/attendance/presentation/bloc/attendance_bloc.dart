import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';
import '../../domain/usecase/check_geofence_usecase.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckGeofenceUseCase checkGeofenceUseCase;

  // BLoC butuh Mandor (UseCase) buat disuruh kerja
  AttendanceBloc({required this.checkGeofenceUseCase}) : super(AttendanceInitial()) {
    
    on<CheckLocationButtonPressed>((event, emit) async {
      emit(AttendanceLoading()); // Ubah tombol jadi muter-muter (loading)
      
      try {
        
        final result = await checkGeofenceUseCase(
          targetLatitude: -6.358511, 
          targetLongitude: 106.562474, 
          radius: 40.0, 
        );
        
        emit(AttendanceLoaded(result)); // Kasih piring makanannya ke UI!
      } catch (e) {
        emit(AttendanceError("Gagal dapet lokasi: ${e.toString()}"));
      }
    });
  }
}