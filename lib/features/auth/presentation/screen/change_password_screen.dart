import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ubah Kata Sandi")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordChangedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _oldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Kata Sandi Lama (Tgl Lahir DDMMYYYY)",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Kata Sandi Baru",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Konfirmasi Kata Sandi Baru",
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                              ChangePasswordButtonPressed(
                                oldPassword: _oldController.text.trim(),
                                newPassword: _newController.text.trim(),
                                confirmPassword: _confirmController.text.trim(),
                              ),
                            );
                          },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text("Simpan Perubahan"),
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
