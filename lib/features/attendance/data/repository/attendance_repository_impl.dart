import 'package:geolocator/geolocator.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  @override
  Future<AttendanceEntity> checkGeofence({
    required double targetLatitude,
    required double targetLongitude,
    required double radius,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Nyalakan GPS mu dulu yaa');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        throw Exception('Kamu telah menolak izin lokasi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi diblokir permanendari setting');
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    bool isInside = distance <= radius;

    return AttendanceEntity(
      distanceInMeters: distance,
      isWithinRadius: isInside,
    );
  }
}
