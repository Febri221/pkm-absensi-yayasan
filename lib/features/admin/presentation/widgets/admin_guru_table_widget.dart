import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../cubit/teacher_attendance/teacher_attendance_cubit.dart';

class AdminGuruTableWidget extends StatelessWidget {
  final List<AdminClassAttendanceEntity> teachers;

  const AdminGuruTableWidget({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada data guru terdaftar.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
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
            columns: const [
              DataColumn(label: Text('Pilih', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Nama Lengkap & Gelar', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('NIP / ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Unit Sekolah', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Jam Masuk', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Jam Pulang', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(teachers.length, (index) {
              final teacher = teachers[index];
              final bool isHadir = teacher.statusKehadiran != 'Belum Hadir';

              final jamMasukText = teacher.waktuMasuk != null
                  ? DateFormat('HH:mm:ss', 'id_ID').format(teacher.waktuMasuk!.toLocal())
                  : '-';
              final jamPulangText = teacher.waktuPulang != null
                  ? DateFormat('HH:mm:ss', 'id_ID').format(teacher.waktuPulang!.toLocal())
                  : '-';

              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: teacher.isSelected,
                      onChanged: (bool? value) {
                        context.read<TeacherAttendanceCubit>().toggleCheckbox(index, value);
                      },
                    ),
                  ),
                  DataCell(Text('${index + 1}')),
                  DataCell(
                    Text(
                      teacher.namaLengkap,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(teacher.nomorInduk)),
                  DataCell(Text(teacher.kelas.isNotEmpty ? teacher.kelas : 'Yayasan')),
                  DataCell(
                    Text(
                      jamMasukText,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      jamPulangText,
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Chip(
                      label: Text(
                        teacher.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isHadir ? Colors.green : Colors.grey.shade400,
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