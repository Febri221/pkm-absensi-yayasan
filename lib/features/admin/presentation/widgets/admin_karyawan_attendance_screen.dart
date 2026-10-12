import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminKaryawanAttendanceScreen extends StatefulWidget {
  const AdminKaryawanAttendanceScreen({super.key});

  @override
  State<AdminKaryawanAttendanceScreen> createState() =>
      _AdminClassAttendanceViewState();
}

class _AdminClassAttendanceViewState extends State<AdminKaryawanAttendanceScreen> {

  @override
  void initState() {
    super.initState();
    // Ganti 'guru' atau 'karyawan' sesuai file ini buat siapa
    context.read<AdminDashboardCubit>().fetchAttendanceByRole('karyawan'); 
  }

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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AdminDashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminDashboardError) {
                      return Center(
                        child: Text(
                          "Error: ${state.message}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is AdminDashboardLoaded) {
                      final students = state.students;

                      if (students.isEmpty) {
                        return const Center(
                          child: Text(
                            "Tidak ada data siswa terdaftar di kelas ini.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blue.shade50,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Pilih',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'No',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nama Lengkap',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'NIP/ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Unit',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ), // Ganti Kelas jadi Unit
                              DataColumn(
                                label: Text(
                                  'Jam Masuk',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Jam Pulang',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: List.generate(students.length, (index) {
                              final student = students[index];
                              final bool isHadir =
                                  student.statusKehadiran != 'Belum Hadir';

                              // Format Jam Masuk & Pulang
                              final jamMasukText = student.waktuMasuk != null
                                  ? DateFormat(
                                      'HH:mm:ss',
                                      'id_ID',
                                    ).format(student.waktuMasuk!.toLocal())
                                  : '-';
                              final jamPulangText = student.waktuPulang != null
                                  ? DateFormat(
                                      'HH:mm:ss',
                                      'id_ID',
                                    ).format(student.waktuPulang!.toLocal())
                                  : '-';

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: student.isSelected,
                                      onChanged: (bool? value) {
                                        context
                                            .read<AdminDashboardCubit>()
                                            .toggleCheckbox(index, value);
                                      },
                                    ),
                                  ),
                                  DataCell(Text('${index + 1}')),
                                  DataCell(
                                    Text(
                                      student.namaLengkap,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(student.nomorInduk)),
                                  DataCell(Text(student.kelas)),
                                  DataCell(
                                    Text(
                                      jamMasukText,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      jamPulangText,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        student.statusKehadiran
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: isHadir
                                          ? Colors.green
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Text(
                        "Silakan pilih kelas terlebih dahulu.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
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
