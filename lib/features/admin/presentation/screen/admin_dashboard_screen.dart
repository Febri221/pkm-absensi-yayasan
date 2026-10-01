import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../../../features/admin/presentation/screen/admin_login_screen.dart'; // Sesuaikan path login admin lu

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Begitu layar web dibuka, langsung suruh Cubit narik data absensi
  //   context.read<AdminDashboardCubit>().fetchAttendanceData();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Kontrol Absensi Yayasan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Tombol Logout Admin
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar & Tombol Refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Live Monitoring Rekap Kehadiran",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Refresh data tabel lewat Cubit
                    context.read<AdminDashboardCubit>().fetchAttendanceData();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Refresh Data"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Area Tabel Rekap (Dibungkus BlocBuilder)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
                  builder: (context, state) {
                    if (state is AdminDashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminDashboardError) {
                      return Center(
                        child: Text(
                          "Waduh Error: ${state.message}",
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    } else if (state is AdminDashboardLoaded) {
                      final listData = state.attendanceList;

                      if (listData.isEmpty) {
                        return const Center(
                          child: Text(
                            "Belum ada data absensi yang masuk ke sistem.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      // Tampilan Tabel Rapi Ala Desktop Web
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                            columns: const [
                              DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nomor Induk', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Unit / Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tipe Absen', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Waktu Terekam', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status Kehadiran', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(listData.length, (index) {
                              final item = listData[index];
                              final unitKelas = "${item.unitSekolah} ${item.kelas != null ? '• ' + item.kelas! : ''}";
                              final tipeAbsen = item.tipeAbsen.toUpperCase();
                              final bool isTerlambat = item.statusKehadiran == 'terlambat';
                              final bool isPulang = tipeAbsen == 'PULANG';

                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(item.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(item.nomorInduk)),
                                DataCell(Text(unitKelas)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: !isPulang ? Colors.blue.shade100 : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tipeAbsen,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: !isPulang ? Colors.blue.shade800 : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    // Format tanggal & waktu pakai intl
                                    DateFormat('dd MMM yyyy, HH:mm:ss', 'id_ID').format(item.waktuAbsen),
                                  ),
                                ),
                                DataCell(
                                  Chip(
                                    label: Text(
                                      item.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: isTerlambat ? Colors.red : Colors.green,
                                  ),
                                ),
                              ]);
                            }),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}