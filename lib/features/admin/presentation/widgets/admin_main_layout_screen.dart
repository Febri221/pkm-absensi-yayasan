import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/admin_sidebar.dart';
import '../screen/admin_class_attendance_screen.dart'; 
import '../../../../features/admin/presentation/screen/admin_login_screen.dart';

class AdminMainLayoutScreen extends StatefulWidget {
  const AdminMainLayoutScreen({super.key});

  @override
  State<AdminMainLayoutScreen> createState() => _AdminMainLayoutScreenState();
}

class _AdminMainLayoutScreenState extends State<AdminMainLayoutScreen> {
  int _selectedIndex = 1; // Default kita arahkan langsung ke Index 1 (Presensi Kelas yang udah jadi)

  // Daftar halaman yang bakal nampil di sebelah kanan sidebar
  final List<Widget> _adminPages = [
    const Center(child: Text("Halaman Live Dashboard (Akan datang)", style: TextStyle(fontSize: 18))),
    const AdminClassAttendanceScreen(), // Halaman Presensi Kelas & Input Manual (Yang keren itu!)
    const Center(child: Text("Halaman Presensi Dewan Guru", style: TextStyle(fontSize: 18))), // Index 2
    const Center(child: Text("Halaman Presensi Karyawan", style: TextStyle(fontSize: 18))), // Index 3
    const Center(child: Text("Halaman Manajemen Siswa & Upload Excel (Akan datang)", style: TextStyle(fontSize: 18))),
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
                _selectedIndex = index; // Ganti halaman aktif pas menu diklik
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
          
          // Garis pembatas tipis antar sidebar dan konten
          const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),

          // 2. KONTEN UTAMA DI KANAN (Berubah dinamis sesuai menu sidebar)
          Expanded(
            child: _adminPages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}