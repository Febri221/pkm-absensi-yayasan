import 'package:flutter/material.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/screen/admin_user_management_screen.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/screen/admin_guru_attendance_screen.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/screen/admin_karyawan_attendance_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/admin_sidebar_widget.dart';
import 'admin_class_attendance_screen.dart';
import 'admin_login_screen.dart';

class AdminMainLayoutScreen extends StatefulWidget {
  const AdminMainLayoutScreen({super.key});

  @override
  State<AdminMainLayoutScreen> createState() => _AdminMainLayoutScreenState();
}

class _AdminMainLayoutScreenState extends State<AdminMainLayoutScreen> {
  int _selectedIndex = 1; // Default ke Presensi Kelas

  // Daftar halaman admin
  final List<Widget> _adminPages = [
    const Center(
      child: Text(
        "Halaman Live Dashboard (Akan datang)",
        style: TextStyle(fontSize: 18),
      ),
    ),
    const AdminClassAttendanceScreen(), // Index 1: Presensi Kelas
    const AdminGuruAttendanceScreen(),
    const AdminKaryawanAttendanceScreen(),
    const AdminUserManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. SIDEBAR DI KIRI
          AdminSidebar(
            currentIndex: _selectedIndex,
            onMenuSelected: (index) {
              setState(() {
                _selectedIndex = index; 
              });
            },
            onLogout: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
          ),

          // Garis pembatas tipis
          const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),

          // 2. KONTEN UTAMA DI KANAN
          // Ganti dari ekspresi list biasa menjadi IndexedStack agar state & pilihan kelas terjaga!
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _adminPages,
            ),
          ),
        ],
      ),
    );
  }
}