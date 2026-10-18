import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/admin_class_attendance_entity.dart';
import '../cubit/employee_attendance/employee_attendance_cubit.dart';

class AdminKaryawanTableWidget extends StatelessWidget {
  final List<AdminClassAttendanceEntity> employees;

  const AdminKaryawanTableWidget({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada data karyawan terdaftar.",
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
              DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('NIP / ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Unit / Bagian', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Jam Masuk', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Jam Pulang', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(employees.length, (index) {
              final employee = employees[index];
              final bool isHadir = employee.statusKehadiran != 'Belum Hadir';

              final jamMasukText = employee.waktuMasuk != null
                  ? DateFormat('HH:mm:ss', 'id_ID').format(employee.waktuMasuk!.toLocal())
                  : '-';
              final jamPulangText = employee.waktuPulang != null
                  ? DateFormat('HH:mm:ss', 'id_ID').format(employee.waktuPulang!.toLocal())
                  : '-';

              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: employee.isSelected,
                      onChanged: (bool? value) {
                        context.read<EmployeeAttendanceCubit>().toggleCheckbox(index, value);
                      },
                    ),
                  ),
                  DataCell(Text('${index + 1}')),
                  DataCell(
                    Text(
                      employee.namaLengkap,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(employee.nomorInduk)),
                  DataCell(Text(employee.kelas.isNotEmpty ? employee.kelas : 'Pusat')),
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
                        employee.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
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