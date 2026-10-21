import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminClassFilterWidget extends StatelessWidget {
  final Map<String, List<String>> dataKelas;
  final String? jenjangDipilih;
  final String? kelasDipilih;
  final List<String> listKelasTersedia;
  final DateTime tanggalDipilih;
  final Function(String?) onUnitChanged;
  final Function(String?) onKelasChanged;
  final Function(DateTime) onTanggalChanged;

  const AdminClassFilterWidget({
    super.key,
    required this.dataKelas,
    required this.jenjangDipilih,
    required this.kelasDipilih,
    required this.tanggalDipilih,
    required this.listKelasTersedia,
    required this.onUnitChanged,
    required this.onKelasChanged,
    required this.onTanggalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Text(
            "Unit Sekolah: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: jenjangDipilih,
            hint: const Text('-- Pilih Unit --'),
            items: dataKelas.keys.map((unit) {
              return DropdownMenuItem(value: unit, child: Text(unit));
            }).toList(),
            onChanged: onUnitChanged,
          ),
          const SizedBox(width: 32),
          const Text("Kelas: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: kelasDipilih,
            hint: const Text('-- Pilih Kelas --'),
            underline: const SizedBox(),
            items: listKelasTersedia.map((kelas) {
              return DropdownMenuItem(value: kelas, child: Text(kelas));
            }).toList(),
            onChanged: onKelasChanged,
          ),
          const SizedBox(width: 32),
          const Text(
            "Tanggal: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.blueAccent,
            ),
            label: Text(
              DateFormat('dd MMM yyyy', 'id_ID').format(tanggalDipilih),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              // Munculkan Kalender Bawaan Flutter
              final DateTime? tanggalBaru = await showDatePicker(
                context: context,
                initialDate: tanggalDipilih,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
                locale: const Locale('id', 'ID'),
              );

              // Kalau user milih tanggal baru, kirim ke fungsi callback
              if (tanggalBaru != null && tanggalBaru != tanggalDipilih) {
                onTanggalChanged(tanggalBaru);
              }
            },
          ),
        ],
      ),
    );
  }
}
