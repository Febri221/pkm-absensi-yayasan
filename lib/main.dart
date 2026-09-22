import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey:
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

// class TestConnectionScreen extends StatefulWidget {
//   const TestConnectionScreen({super.key});

//   @override
//   State<TestConnectionScreen> createState() => _TestConnectionScreenState();
// }

// class _TestConnectionScreenState extends State<TestConnectionScreen> {
//   String _status = 'Belum dites';

//   Future<void> _testSupabase() async {
//     setState(() {
//       _status = 'Menghubungkan...';
//     });

//     try {
//       // Kita coba menarik data dari tabel companies
//       final data = await Supabase.instance.client.from('absensi').select();
      
//       setState(() {
//         // Jika kode sampai sini tanpa error, berarti koneksi INTERNET & API sukses!
//         _status = 'Koneksi Berhasil!\nRespon Database: $data';
//       });
//     } catch (e) {
//       setState(() {
//         _status = 'Koneksi Gagal: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Cek Koneksi Supabase')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(_status, textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _testSupabase,
//                 child: const Text('Test Koneksi Sekarang'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }