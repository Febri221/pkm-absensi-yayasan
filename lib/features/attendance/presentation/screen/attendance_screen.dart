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
          child: // Di dalam body Scaffold (ganti bagian BlocBuilder lu pake ini):
          BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              // 1. STATE LOADING / SUBMITTING
              if (state is AttendanceLoading || state is AttendanceSubmitting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Memuat data absensi..."),
                    ],
                  ),
                );
              }
              // 2. STATE LOADED (KITA PAKE AttendanceLoaded YANG UDAH DI-UPGRADE)
              else if (state is AttendanceLoaded) {
                // Data GPS
                final distance = state.geoData.distanceInMeters.toInt();
                final inRadius = state.geoData.isWithinRadius;

                // Data Database (1 Tombol Pintar)
                final bool sudahMasuk = state.sudahMasuk;
                final bool sudahPulang = state.sudahPulang;

                // Ambil jam sekarang vs jam pulang dari database (misal "14:10:00")
                final now = DateTime.now();
                final timeParts = state.jamPulang.split(':');
                final jamPulangSekolah = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                );
                bool isSudahWaktuPulang = now.isAfter(jamPulangSekolah);

                // --- LOGIKA MUTASI 1 TOMBOL PINTAR ---
                String textTombol = "";
                VoidCallback? aksiTombol;
                bool isTombolAktif = false;
                Color warnaTombol = Colors.grey;

                if (!sudahMasuk) {
                  // KONDISI A: BELUM ABSEN MASUK -> Wajib di dalam radius 50m!
                  textTombol = "Kirim Absen Masuk";
                  isTombolAktif = inRadius; // Hidup kalau di dalam radius
                  warnaTombol = Colors.green;
                  aksiTombol = isTombolAktif
                      ? () {
                          context.read<AttendanceBloc>().add(
                            SubmitAttendanceButtonPressed(
                              latitude:
                                  -6.358511, // Nanti ambil dari posisi GPS aktual
                              longitude: 106.562474,
                              tipeAbsen: 'masuk',
                            ),
                          );
                        }
                      : null; // Mati kalau di luar radius
                } else if (sudahMasuk && !sudahPulang) {
                  // KONDISI B: SUDAH MASUK, TAPI BELUM PULANG -> Cek jam pulang
                  if (!isSudahWaktuPulang) {
                    textTombol =
                        "Menunggu Jam Pulang (${state.jamPulang.substring(0, 5)})";
                    isTombolAktif = false; // Mati total sebelum waktunya!
                    warnaTombol = Colors.grey;
                    aksiTombol = null;
                  } else {
                    // SUDAH JAM PULANG! Bebas radius (bisa dipencet dari rumah/mana aja)
                    textTombol = "Kirim Absen Pulang";
                    isTombolAktif = true; // Hidup!
                    warnaTombol = Colors.blue;
                    aksiTombol = () {
                      context.read<AttendanceBloc>().add(
                        SubmitAttendanceButtonPressed(
                          latitude: -6.358511,
                          longitude: 106.562474,
                          tipeAbsen: 'pulang',
                        ),
                      );
                    };
                  }
                } else {
                  // KONDISI C: SELESAI SEMUA (Masuk & Pulang beres)
                  textTombol = "Absen Hari Ini Selesai ✅";
                  isTombolAktif = false;
                  warnaTombol = Colors.grey;
                  aksiTombol = null;
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Radius GPS
                      Text(
                        inRadius
                            ? "📍 Dalam Radius Sekolah"
                            : "⚠️ Di Luar Jangkauan Sekolah",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: inRadius ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Jarak lu: $distance meter dari titik sekolah"),
                      const SizedBox(height: 40),

                      // SI 1 TOMBOL PINTAR UTAMA
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: aksiTombol,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warnaTombol,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            textTombol,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () {
                          // Refresh status database & GPS
                          context.read<AttendanceBloc>().add(
                            LoadAttendanceStatusEvent(),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Cek Ulang Status'),
                      ),
                    ],
                  ),
                );
              }
              // 3. STATE ERROR
              else if (state is AttendanceError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.read<AttendanceBloc>().add(
                            LoadAttendanceStatusEvent(),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 4. STATE INITIAL (Pas pertama kali buka, langsung tembak event load status)
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AttendanceBloc>().add(
                      LoadAttendanceStatusEvent(),
                    );
                  },
                  child: const Text('Muat Halaman Absensi'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
