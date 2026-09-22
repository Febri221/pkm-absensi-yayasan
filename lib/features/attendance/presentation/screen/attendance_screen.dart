import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Absen Geofencing')),
      body: Center(
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            
            // Pake pola switch-case atau if-else buat nangkep sealed class
            if (state is AttendanceLoading) {
              return const CircularProgressIndicator();
            } 
            
            else if (state is AttendanceLoaded) {
              // Ambil data Entity dari state
              final distance = state.data.distanceInMeters.toInt();
              final inRadius = state.data.isWithinRadius;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    inRadius ? "BISA ABSEN!" : "KEJAUHAN BOS!",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: inRadius ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Jarak lu: $distance meter dari titik nol"),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Nanti ini buat nembak Supabase kalau di dalem radius
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inRadius ? Colors.green : Colors.grey,
                    ),
                    child: const Text('Kirim Absen'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.read<AttendanceBloc>().add(CheckLocationButtonPressed()),
                    child: const Text('Cek Ulang Lokasi'),
                  )
                ],
              );
            } 
            
            else if (state is AttendanceError) {
              return Text(state.message, style: const TextStyle(color: Colors.red));
            }

            // State Initial (Pas pertama kali buka app)
            return ElevatedButton(
              onPressed: () {
                // Lempar event ke BLoC pas dipencet
                context.read<AttendanceBloc>().add(CheckLocationButtonPressed());
              },
              child: const Text('Cek Lokasi Absen'),
            );
          },
        ),
      ),
    );
  }
}