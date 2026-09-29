import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Trigger fetch data pas halaman dibuka
    context.read<HistoryBloc>().add(FetchHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kehadiran')),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryLoaded) {
            final listHistory = state.historyList;

            if (listHistory.isEmpty) {
              return const Center(child: Text("Belum ada riwayat absensi."));
            }

            return ListView.builder(
              itemCount: listHistory.length,
              itemBuilder: (context, index) {
                final item = listHistory[index];
                final isTepatWaktu = item.statusKehadiran == 'tepat_waktu';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.tipeAbsen == 'masuk'
                          ? Colors.blue
                          : Colors.orange,
                      child: Icon(
                        item.tipeAbsen == 'masuk' ? Icons.login : Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "Absen ${item.tipeAbsen.toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Waktu: ${item.waktuAbsen.toLocal()}"),
                    trailing: Chip(
                      label: Text(
                        item.statusKehadiran.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: isTepatWaktu ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            );
          } else if (state is HistoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
