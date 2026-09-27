import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Geofencing Sekolah')),
      
      // Multi BlocConsumer atau tambahan Listener buat nangkep Pop-up Sukses / Error Submit
      body: MultiBlocListener(
        listeners: [
          // 1. LISTENER BUAT GPS MATI (KODE 'GPS_DISABLED')
          BlocListener<AttendanceBloc, AttendanceState>(
            listener: (context, state) {
              if (state is AttendanceError && state.message == 'GPS_DISABLED') {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.location_off, color: Colors.red),
                          SizedBox(width: 10),
                          Text("GPS Belum Aktif"),
                        ],
                      ),
                      content: const Text(
                        "Layanan lokasi (GPS) di perangkat HP kamu sedang mati. "
                        "Harap aktifkan GPS terlebih dahulu untuk melanjutkan absensi.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            await Geolocator.openLocationSettings();
                          },
                          child: const Text("Buka Pengaturan GPS"),
                        ),
                      ],
                    );
                  },
                );
              }
              
              // 2. LISTENER BUAT NOTIFIKASI SUKSES SUBMIT ABSEN
              if (state is AttendanceSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
        
        child: Center(
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              
              // TAMPILAN SAAT NARIK GPS / LAGI SUBMIT DATA
              if (state is AttendanceLoading || state is AttendanceSubmitting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Memproses data kehadiran..."),
                  ],
                );
              } 
              
              // TAMPILAN UTAMA PAS LOKASI KEDETEK
              else if (state is AttendanceLoaded) {
                final distance = state.data.distanceInMeters.toInt();
                final inRadius = state.data.isWithinRadius;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inRadius ? "BISA ABSEN!" : "KEJAUHAN BOS!",
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: inRadius ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Jarak lu: $distance meter dari titik sekolah"),
                    const SizedBox(height: 30),
                    
                    // TOMBOL KIRIM ABSEN UTAMA
                    ElevatedButton(
                      // Kalau inRadius TRUE -> Tombol aktif dan bisa diklik buat Nembak Supabase!
                      // Kalau FALSE -> Nilainya NULL (Mati total/disabled)
                      onPressed: inRadius 
                        ? () {
                            // Panggil BLoC Event Submit Absen
                            // (Koordinat bisa diambil dari posisi real-time atau dikirim dari entity)
                            context.read<AttendanceBloc>().add(
                              const SubmitAttendanceButtonPressed(
                                latitude: -6.358511,  // Nanti disesuaikan posisi aktual
                                longitude: 106.562474,
                                tipeAbsen: 'masuk',  // Atur jadi 'masuk' atau 'pulang'
                              ),
                            );
                          } 
                        : null, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inRadius ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Kirim Absen Masuk', 
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Tombol refresh/cek ulang lokasi
                        context.read<AttendanceBloc>().add(CheckLocationButtonPressed());
                      },
                      child: const Text('Cek Ulang Lokasi'),
                    )
                  ],
                );
              } 
              
              // TAMPILAN KALAU ADA ERROR UMUM
              else if (state is AttendanceError && state.message != 'GPS_DISABLED') {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<AttendanceBloc>().add(CheckLocationButtonPressed()),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                );
              }

              // STATE INITIAL (TAMPILAN AWAL SEBELUM APA-APA DIKLIK)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Silakan tekan tombol di bawah untuk mulai absen"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AttendanceBloc>().add(CheckLocationButtonPressed());
                    },
                    child: const Text('Cek Lokasi Absen'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}