import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan pakai Google Fonts
import 'package:sistem_absensi_sekolah/features/auth/presentation/screen/change_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/screen/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi buat ngambil maksimal 2 huruf inisial dari nama
  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background terang bersih ala instansi
      appBar: AppBar(
        title: Text(
          'Profil Pengguna',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: supabase.from('users').select().eq('id', user!.id).single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat profil: ${snapshot.error}"),
            );
          }

          final data = snapshot.data!;
          final nama = data['nama_lengkap'] ?? 'Tanpa Nama';
          final nomorInduk = data['nomor_induk'] ?? '-';
          final role = data['role'] ?? '-';
          final unit = data['unit_sekolah'] ?? '-';
          final kelas = data['kelas'] ?? '-';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // CIRCLE AVATAR INISIAL OTOMATIS
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade700,
                  child: Text(
                    _getInitials(nama),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // NAMA LENGKAP (Aman dari kepanjangan pake FittedBox/Ellipsis)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    nama,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // NOMOR INDUK
                Text(
                  "Nomor Induk: $nomorInduk",
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // BADGE ROLE & UNIT SEKOLAH
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$unit ${kelas != '-' && kelas != null ? '• Kelas $kelas' : ''}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await supabase.auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(LucideIcons.logOut, color: Colors.red),
                    label: Text(
                      'Keluar Aplikasi (Logout)',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(LucideIcons.lock),
                  title: const Text("Ubah Kata Sandi"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
