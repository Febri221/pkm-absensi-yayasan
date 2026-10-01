import 'package:flutter/material.dart';
import 'package:sistem_absensi_sekolah/features/admin/data/repositories/admin_attendance_repository_impl.dart';
import 'package:sistem_absensi_sekolah/features/admin/domain/usecase/get_admin_attendance_usecase.dart';
import 'package:sistem_absensi_sekolah/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard_screen.dart'; // Nanti kita buat file ini
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _loginAdmin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Login ke Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception('Login gagal.');

      // 2. KUNCI PENGAMAN: Cek apakah user ini rolenya benar-benar 'admin'?
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final String role = userData['role'] ?? '';

      if (role == 'admin') {
        // Kalau bener admin, lempar ke Dashboard Web!
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => AdminDashboardCubit(
                getAdminAttendanceUseCase: GetAdminAttendanceUseCase(
                  AdminAttendanceRepositoryImpl(),
                ),
              )..fetchAttendanceData(),
              child: const AdminDashboardScreen(),
            ),
          ),
        );
      } else {
        // Kalau bukan admin (misal siswa nyoba login disini), tolak!
        await supabase.auth.signOut();
        setState(() {
          _errorMessage = 'Akses ditolak! Akun ini bukan akun Admin.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 400, // Lebar kotak form ala Web Desktop
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Admin Panel",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Sistem Absensi Yayasan Pendidikan",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Admin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Masuk ke Dashboard',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
