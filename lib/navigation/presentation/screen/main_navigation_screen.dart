import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_absensi_sekolah/core/constants/main_nav_color.dart';
import 'package:sistem_absensi_sekolah/features/history/presentation/screen/history_screen.dart';
import '../../cubit/main_navigation_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/attendance/presentation/screen/attendance_screen.dart';
// Nanti kalau halaman history udah dibikin, di-import juga di sini:
// import '../../features/attendance/presentation/screen/history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainPageState();
}

class _MainPageState extends State<MainNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    // Pastikan urutan array ini sama dengan index 0, 1, 2, 3
    final List<Widget> _pages = [
      const AttendanceScreen(), // Tab 0: Home / Absen GPS lu
      const HistoryScreen(),
      Center(child: Text('Halaman Profile')),
      // const HistoryScreen(),    // Tab 1: Riwayat Absen
      // const ProfileScreen(),    // Tab 2: Profil User
    ];

    return BlocProvider(
      create: (context) => MainNavigationCubit(),
      child: BlocBuilder<MainNavigationCubit, int>(
        builder: (context, currentCubitIndex) {
          return Scaffold(
            extendBody:
                true, // WAJIB: Biar background konten nembus ke bawah kaca
            body: IndexedStack(index: currentCubitIndex, children: _pages),
            bottomNavigationBar: _buildGlassBottomNav(
              context,
              currentCubitIndex,
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET NAVBAR KACA ---
  Widget _buildGlassBottomNav(BuildContext context, int currentIndex) {
    // Data menu disesuaikan dengan kebutuhan HRIS lu
    final List<Map<String, dynamic>> navItems = [
      {"icon": LucideIcons.home, "label": "Home"},
      {"icon": LucideIcons.clock, "label": "Riwayat"},
      {"icon": LucideIcons.user, "label": "Profile"},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: MainNavColor.surface,
        border: const Border(
          top: BorderSide(color: MainNavColor.borderSub, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final bool isActive = currentIndex == index;
            final item = navItems[index];

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  // Langsung panggil Cubit dengan index murni (0, 1, 2, 3)
                  onTap: () =>
                      context.read<MainNavigationCubit>().switchTab(index),

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // --- GARIS INDIKATOR AKTIF MELAYANG ---
                        if (isActive)
                          Positioned(
                            top: -12, // Posisinya persis numpang di atas border
                            child: Container(
                              width: 32,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    MainNavColor.blue,
                                    MainNavColor.blueMid,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),

                        // --- IKON & TEKS ---
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item["icon"],
                              color: isActive
                                  ? MainNavColor.blue
                                  : MainNavColor.textMuted,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["label"],
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w700,
                                color: isActive
                                    ? MainNavColor.blue
                                    : MainNavColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
