import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/navigation/presentation/screen/main_navigation_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../attendance/presentation/screen/attendance_screen.dart'; // Sesuaikan path ke screen absen lu

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _nomorIndukController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Sistem Absensi')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Kalau sukses login, pindah ke halaman absensi
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          } else if (state is AuthError) {
            // Munculin pesan error kalau gagal login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk menggunakan NISN / NIP dan Tanggal Lahir",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Input NISN / NIP
                TextField(
                  controller: _nomorIndukController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Induk (NISN / NIP)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Password (Tanggal Lahir DDMMYYYY)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi (Format: DDMMYYYY)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Login / Masuk
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  LoginButtonPressed(
                                    nomorInduk: _nomorIndukController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                          },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Masuk', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}