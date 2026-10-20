import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../cubit/student_attendance/student_attendance_cubit.dart';
import '../../data/repositories/admin_attendance_repository_impl.dart';

class AdminClassTableWidget extends StatelessWidget {
  final List<AdminClassAttendanceEntity> students;

  const AdminClassTableWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(
        child: Text("Tidak ada data siswa terdaftar di kelas ini."),
      );
    }

    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
            columns: [
             
             
              DataColumn(
                label: Checkbox(
                  value:
                      students.isNotEmpty &&
                      students.every((s) => s.isSelected),
                  onChanged: (bool? value) {
                    // Panggil fungsi select all di cubit
                    context.read<StudentAttendanceCubit>().toggleSelectAll(
                      value,
                    );
                  },
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
                  'NISN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
              final s = students[index];
              final bool isHadir = s.statusKehadiran != 'Belum Hadir';
              final jamMasukText = s.waktuMasuk != null
                  ? DateFormat(
                      'HH:mm:ss',
                      'id_ID',
                    ).format(s.waktuMasuk!.toLocal())
                  : '-';
              final jamPulangText = s.waktuPulang != null
                  ? DateFormat(
                      'HH:mm:ss',
                      'id_ID',
                    ).format(s.waktuPulang!.toLocal())
                  : '-';

              return DataRow(
                cells: [
                 
                  DataCell(
                    Checkbox(
                      value: s.isSelected,
                      onChanged: (v) => context
                          .read<StudentAttendanceCubit>()
                          .toggleCheckbox(index, v),
                    ),
                  ),
                  DataCell(Text('${index + 1}')),
                  DataCell(
                    Text(
                      s.namaLengkap,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(s.nomorInduk)),
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
                        s.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
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
      ),
    );
  }
}
