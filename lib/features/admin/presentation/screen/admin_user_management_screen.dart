import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      // 1. Panggil langsung FilePicker.pickFiles() tanpa .platform
      final List<PlatformFile>? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.isNotEmpty) {
        final file = result.first;
        
        // 2. DI VERSI 13, AMBIL BYTES PAKAI FUNGSI ASINKRON:
        // (Karena properti .bytes sudah tidak ada di PlatformFile v13)
        Uint8List? fileBytes = await file.readAsBytes();

        if (fileBytes != null) {
          String csvContent = String.fromCharCodes(fileBytes);

          if (!context.mounted) return;
          context.read<AdminDashboardCubit>().uploadCsvData(csvContent);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File CSV berhasil dipilih dan diproses! 🎉"),
              backgroundColor: Colors.green,
            ),
          );
        } 
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error pilih file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manajemen Data Pengguna (Master Data)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
        listener: (context, state) {
          if (state is AdminUploadSuccess) {
            if (state.message == 'UPLOAD_SUCCESS') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil di-upload dan didaftarkan! 🎉"), backgroundColor: Colors.green),
              );
              // Kembalikan ke state awal
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          }
        },
        builder: (context, state) {
          return Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload_file, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 24),
                  const Text(
                    "Upload Data Siswa & Guru (.csv)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Pastikan file berformat CSV dengan urutan kolom:\n[NISN/NIP], [Nama Lengkap], [Role], [Unit Sekolah], [Tingkat], [Kelas]",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  if (state is AdminDashboardLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickAndUploadFile(context),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Pilih File CSV & Upload', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}