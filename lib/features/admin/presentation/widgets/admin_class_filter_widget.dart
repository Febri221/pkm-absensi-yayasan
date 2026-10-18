import 'package:flutter/material.dart';

class AdminClassFilterWidget extends StatelessWidget {
  final Map<String, List<String>> dataKelas;
  final String? jenjangDipilih;
  final String? kelasDipilih;
  final List<String> listKelasTersedia;
  final Function(String?) onUnitChanged;
  final Function(String?) onKelasChanged;

  const AdminClassFilterWidget({
    super.key,
    required this.dataKelas,
    required this.jenjangDipilih,
    required this.kelasDipilih,
    required this.listKelasTersedia,
    required this.onUnitChanged,
    required this.onKelasChanged,
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
          const Text("Unit Sekolah: ", style: TextStyle(fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}