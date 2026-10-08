import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminClassAttendanceScreen extends StatefulWidget {
  const AdminClassAttendanceScreen({super.key});

  @override
  State<AdminClassAttendanceScreen> createState() => _AdminClassAttendanceViewState();
}

class _AdminClassAttendanceViewState extends State<AdminClassAttendanceScreen> {
  // 1. Data Pilihan Jenjang & Kelas yang terstruktur
  final Map<String, List<String>> _dataJenjangDanKelas = {
    'SMP 136': ['VII A', 'VII B', 'VIII A', 'VIII B', 'IX A', 'IX B'],
    'SMK 155': ['X B', 'X DKV', 'XI IPA', 'XI IPS', 'XII TKJ 1', 'XII DKV 1'],
  };

  String? _jenjangDipilih; // Contoh: 'SMP 136' atau 'SMK 155'
  String? _kelasDipilih;  // Contoh: 'IX A'
  List<String> _listKelasTersedia = []; // List kelas yang nampil sesuai jenjang

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER JUDUL ---
            const Text(
              "Panel Presensi & Input Manual Kelas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // --- FILTER BERTINGKAT (JENJANG & KELAS) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // DROPDOWN 1: PILIH JENJANG (SMP / SMK)
                  const Text("Jenjang:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _jenjangDipilih,
                    hint: const Text('-- Pilih Jenjang --'),
                    underline: const SizedBox(),
                    items: _dataJenjangDanKelas.keys.map((String jenjang) {
                      return DropdownMenuItem<String>(
                        value: jenjang,
                        child: Text(jenjang),
                      );
                    }).toList(),
                    onChanged: (String? newJenjang) {
                      setState(() {
                        _jenjangDipilih = newJenjang;
                        _kelasDipilih = null; // Reset pilihan kelas
                        // Otomatis ubah list kelas berdasarkan jenjang yang dipilih
                        _listKelasTersedia = _dataJenjangDanKelas[newJenjang] ?? [];
                      });
                    },
                  ),
                  const SizedBox(width: 32),

                  // DROPDOWN 2: PILIH KELAS (Menyesuaikan Jenjang)
                  const Text("Kelas:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _kelasDipilih,
                    hint: const Text('-- Pilih Kelas Dulu --'),
                    underline: const SizedBox(),
                    items: _listKelasTersedia.map((String kelas) {
                      return DropdownMenuItem<String>(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                    onChanged: _jenjangDipilih == null ? null : (String? newKelas) {
                      setState(() {
                        _kelasDipilih = newKelas;
                      });
                      if (newKelas != null) {
                        // TRIGGER CUBIT BUAT TARIK DATA REAL-TIME BERDASARKAN KELAS!
                        context.read<AdminDashboardCubit>().watchStudentsByClass(newKelas);
                      }
                    },
                  ),
                  
                  const Spacer(),

                  // TOMBOL AKSI MASAL (CHECKBOX)
                  ElevatedButton.icon(
                    onPressed: _kelasDipilih == null ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur simpan masal segera diaktifkan!")),
                      );
                    },
                    icon: const Icon(Icons.check_box, size: 18),
                    label: const Text("Simpan Perubahan Massal"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TABEL DATA SISWA ---
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
                    if (state is AdminDashboardInitial) {
                      return const Center(
                        child: Text(
                          "Silakan pilih Jenjang dan Kelas terlebih dahulu di atas.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                    if (state is AdminDashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminDashboardError) {
                      return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
                    } else if (state is AdminDashboardLoaded) {
                      final students = state.students;

                      if (students.isEmpty) {
                        return const Center(
                          child: Text("Tidak ada data siswa terdaftar di kelas ini.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                            columns: const [
                              DataColumn(label: Text('Pilih', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('NISN', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Jam Masuk', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Jam Pulang', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status Kehadiran', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(students.length, (index) {
                              final student = students[index];
                              final bool isHadir = student.statusKehadiran != 'Belum Hadir';

                              // Format Jam Masuk & Pulang
                              final jamMasukText = student.waktuMasuk != null
                                  ? DateFormat('HH:mm:ss', 'id_ID').format(student.waktuMasuk!.toLocal())
                                  : '-';
                              final jamPulangText = student.waktuPulang != null
                                  ? DateFormat('HH:mm:ss', 'id_ID').format(student.waktuPulang!.toLocal())
                                  : '-';

                              return DataRow(cells: [
                                DataCell(
                                  Checkbox(
                                    value: student.isSelected,
                                    onChanged: (bool? value) {
                                      context.read<AdminDashboardCubit>().toggleCheckbox(index, value);
                                    },
                                  ),
                                ),
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(student.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(student.nomorInduk)),
                                DataCell(Text(student.kelas)),
                                DataCell(Text(jamMasukText, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))),
                                DataCell(Text(jamPulangText, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600))),
                                DataCell(
                                  Chip(
                                    label: Text(
                                      student.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: isHadir ? Colors.green : Colors.grey.shade400,
                                  ),
                                ),
                              ]);
                            }),
                          ),
                        ),
                      );
                    }
                    return const Center(child: Text("Silakan pilih kelas terlebih dahulu.", style: TextStyle(color: Colors.grey, fontSize: 16)));
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