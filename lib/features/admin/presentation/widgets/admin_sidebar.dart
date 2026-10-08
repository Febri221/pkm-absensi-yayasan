import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Sidebar / Judul Aplikasi
          Container(
            padding: const EdgeInsets.all(24.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SIApresensi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 4),
                Text(
                  "Yayasan Pendidikan",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Menu 1: Dashboard / Live Monitoring
          _buildMenuItem(
            index: 0,
            icon: LucideIcons.layoutDashboard,
            title: "Live Dashboard",
          ),

          // Menu 2: Presensi Kelas & Input Manual (Yang baru kita buat!)
          _buildMenuItem(
            index: 1,
            icon: LucideIcons.users,
            title: "Presensi Kelas",
          ),
          _buildMenuItem(
            index: 2,
            icon: LucideIcons.users,
            title: "Presensi Dewan Guru",
          ),
          _buildMenuItem(
            index: 3,
            icon: LucideIcons.users,
            title: "Presensi Karyawan",
          ),

          // Menu 3: Manajemen Siswa (Nanti buat Upload Excel)
          _buildMenuItem(
            index: 4,
            icon: LucideIcons.database,
            title: "Manajemen Siswa",
          ),

          const Spacer(),
          const Divider(height: 1),

          // Tombol Logout di bawah
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text("Keluar (Logout)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: onLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required int index, required dynamic icon, required String title}) {
    final bool isSelected = currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey.shade600, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blueAccent : Colors.black87,
          ),
        ),
        onTap: () => onMenuSelected(index),
      ),
    );
  }
}