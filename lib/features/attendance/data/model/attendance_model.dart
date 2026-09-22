class Absensi {
  final String id;
  final String tanggal;      // format: yyyy-MM-dd
  final String jam;          // format: HH:mm:ss
  final double latitude;
  final double longitude;
  final double jarakMeter;
  final String status;       // "hadir" | "telat"
  final String? fotoPath;    // path foto lokal (web: kosong)

  Absensi({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.latitude,
    required this.longitude,
    required this.jarakMeter,
    required this.status,
    this.fotoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal,
        'jam': jam,
        'latitude': latitude,
        'longitude': longitude,
        'jarakMeter': jarakMeter,
        'status': status,
        'fotoPath': fotoPath,
      };

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
        id: json['id'],
        tanggal: json['tanggal'],
        jam: json['jam'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        jarakMeter: (json['jarakMeter'] as num).toDouble(),
        status: json['status'],
        fotoPath: json['fotoPath'],
      );
}