import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/bulk_update_attendance_usecase.dart';
import '../cubit/student_attendance/student_attendance_cubit.dart';
import '../cubit/student_attendance/student_attendance_state.dart';
import '../../data/repositories/admin_attendance_repository_impl.dart';
import '../../../admin/domain/usecase/get_students_by_class_stream_usecase.dart';
import '../../domain/usecase/get_classes_usecase.dart';
import '../widgets/admin_class_filter_widget.dart';
import '../widgets/admin_class_table_widget.dart';

class AdminClassAttendanceScreen extends StatelessWidget {
  const AdminClassAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentAttendanceCubit(
        bulkUpdateAttendanceUsecase: BulkUpdateAttendanceUsecase(
          AdminAttendanceRepositoryImpl(),
        ),
        getAttendanceByClassUseCase: GetAttendanceByClassUseCase(
          AdminAttendanceRepositoryImpl(),
        ),
        getClassesUsecase: GetClassesUsecase(AdminAttendanceRepositoryImpl()),
      )..fetchAvailableClasses(),
      child: const _AdminClassAttendanceView(),
    );
  }
}

class _AdminClassAttendanceView extends StatefulWidget {
  const _AdminClassAttendanceView();

  @override
  State<_AdminClassAttendanceView> createState() =>
      _AdminClassAttendanceViewState();
}

class _AdminClassAttendanceViewState extends State<_AdminClassAttendanceView> {
  String? _jenjangDipilih;
  String? _kelasDipilih;
  List<String> _listKelasTersedia = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Panel Presensi & Input Manual Kelas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. PANGGIL WIDGET FILTER
            BlocBuilder<StudentAttendanceCubit, StudentAttendanceState>(
              builder: (context, state) {
                Map<String, List<String>> dataKelas = {};
                if (state is StudentClassesLoaded) dataKelas = state.classesMap;
                if (state is StudentAttendanceLoaded)
                  dataKelas = state.classesMap;

                return AdminClassFilterWidget(
                  dataKelas: dataKelas,
                  jenjangDipilih: _jenjangDipilih,
                  kelasDipilih: _kelasDipilih,
                  listKelasTersedia: _listKelasTersedia,
                  onUnitChanged: (newUnit) {
                    setState(() {
                      _jenjangDipilih = newUnit;
                      _kelasDipilih = null;
                      _listKelasTersedia = dataKelas[newUnit!] ?? [];
                    });
                  },
                  onKelasChanged: (newKelas) {
                    setState(() {
                      _kelasDipilih = newKelas;
                    });
                    if (newKelas != null && dataKelas.isNotEmpty) {
                      context
                          .read<StudentAttendanceCubit>()
                          .watchStudentsByClass(newKelas, dataKelas);
                    }
                  },
                );
              },
            ),

            // Di dalam file screen utama lu (AdminClassAttendanceScreen):
ElevatedButton.icon(
  onPressed: _kelasDipilih == null ? null : () {
    // Tampilkan Dialog konfirmasi pilihan status massal
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Ubah Status Kehadiran Masal"),
          content: const Text("Pilih status untuk semua siswa yang dicentang:"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // PANGGIL CUBIT DARI SCREEN UTAMA!
                context.read<StudentAttendanceCubit>().saveButtonAttendance('tepat_waktu', _kelasDipilih!);
              },
              child: const Text("Tepat Waktu", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<StudentAttendanceCubit>().saveButtonAttendance('terlambat', _kelasDipilih!);
              },
              child: const Text("Terlambat", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  },
  icon: const Icon(Icons.check_box, size: 18),
  label: const Text("Simpan Perubahan Massal"),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
),
            const SizedBox(height: 24),

            // 2. PANGGIL WIDGET TABEL
            Expanded(
              child: BlocBuilder<StudentAttendanceCubit, StudentAttendanceState>(
                builder: (context, state) {
                  if (state is StudentAttendanceLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is StudentAttendanceError)
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  if (state is StudentClassesLoaded ||
                      state is StudentAttendanceInitial) {
                    return const Center(
                      child: Text(
                        "Silakan pilih Unit Sekolah dan Kelas terlebih dahulu.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  if (state is StudentAttendanceLoaded) {
                    return AdminClassTableWidget(students: state.students);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
