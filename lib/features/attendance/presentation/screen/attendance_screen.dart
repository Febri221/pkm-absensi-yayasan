import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    context.read<AttendanceBloc>().add(LoadAttendanceStatusEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {

      context.read<AttendanceBloc>().add(LoadAttendanceStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Absensi Geofencing Sekolah'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: MultiBlocListener(
        listeners: [
          // 1. Listener GPS Mati
          BlocListener<AttendanceBloc, AttendanceState>(
            listener: (context, state) {
              print("DEBUG LISTENER NANGKEP STATE: $state");
              if (state is AttendanceError && state.message == 'GPS_DISABLED') {
                print("DEBUG: Bener nih GPS_DISABLED tertangkap listener!");
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        "GPS Belum Aktif",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        "Layanan lokasi (GPS) di perangkat HP kamu sedang mati. "
                        "Harap aktifkan GPS terlebih dahulu untuk melanjutkan absensi.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            // 1. Tutup dialog dulu
                            Navigator.pop(dialogContext);

                            // 2. Buka pengaturan GPS HP otomatis!
                            await Geolocator.openLocationSettings();
                            if (context.mounted) {
                              context.read<AttendanceBloc>().add(
                                LoadAttendanceStatusEvent(),
                              );
                            }
                          },
                          child: const Text(
                            "Buka Pengaturan GPS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              // 2. Listener Sukses Submit
              if (state is AttendanceSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh status abis absen sukses
                context.read<AttendanceBloc>().add(LoadAttendanceStatusEvent());
              } else if (state is AttendanceLoading ||
                  state is AttendanceLoaded) {
                // Perintah aman buat nutup dialog pop-up yang lagi aktif di atas layar
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
        child: Center(
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              // KONDISI: LOADING ATAU SUBMITTING
              if (state is AttendanceLoading || state is AttendanceSubmitting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Memproses data...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              // KONDISI: DATA UTAMA KEDETEK (LOADED)
              else if (state is AttendanceLoaded) {
                final distance = state.geoData.distanceInMeters.toInt();
                final inRadius = state.geoData.isWithinRadius;

                final bool sudahMasuk = state.sudahMasuk;
                final bool sudahPulang = state.sudahPulang;

                // Hitung logika sederhana di UI cuma buat nentuin Teks & Tombol (Bukan rumus berat)
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

                // Variabel Tombol Pintar
                String textTombol = "";
                VoidCallback? aksiTombol;
                Color warnaTombol = Colors.grey;

                if (!sudahMasuk) {
                  textTombol = "Kirim Absen Masuk";
                  warnaTombol = Colors.green;
                  // Kalau di dalam radius, hidup. Kalau di luar, mati (null)
                  aksiTombol = inRadius
                      ? () {
                          context.read<AttendanceBloc>().add(
                            const SubmitAttendanceButtonPressed(
                              tipeAbsen: 'masuk',
                            ),
                          );
                        }
                      : null;
                } else if (sudahMasuk && !sudahPulang) {
                  if (!isSudahWaktuPulang) {
                    textTombol =
                        "Menunggu Jam Pulang (${state.jamPulang.substring(0, 5)})";
                    warnaTombol = Colors.grey;
                    aksiTombol = null; // Mati total sebelum jam pulang
                  } else {
                    textTombol = "Kirim Absen Pulang";
                    warnaTombol = Colors.blue;
                    // Bebas radius pas jam pulang!
                    aksiTombol = () {
                      context.read<AttendanceBloc>().add(
                        const SubmitAttendanceButtonPressed(
                          tipeAbsen: 'pulang',
                        ),
                      );
                    };
                  }
                } else {
                  textTombol = "Absen Hari Ini Selesai ✅";
                  warnaTombol = Colors.grey;
                  aksiTombol = null;
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Indikator Radius GPS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: inRadius
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: inRadius
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          inRadius
                              ? "📍 Dalam Radius Sekolah"
                              : "⚠️ Di Luar Jangkauan Sekolah",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: inRadius
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Jarak lu: $distance meter dari titik sekolah",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // TOMBOL PINTAR UTAMA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: aksiTombol,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warnaTombol,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            textTombol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () {
                          context.read<AttendanceBloc>().add(
                            LoadAttendanceStatusEvent(),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Cek Ulang Status'),
                      ),
                    ],
                  ),
                );
              }
              // KONDISI: ERROR UMUM
              else if (state is AttendanceError) {
                if (state.message == 'GPS_DISABLED') {
                  return const SizedBox.shrink(); // Mengembalikan widget kosong transparan
                }
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

              // STATE INITIAL (PANGGIL DATA PERTAMA KALI)
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
