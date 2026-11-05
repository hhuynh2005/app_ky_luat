import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitDisciplineApp());
}

class HabitDisciplineApp extends StatelessWidget {
  const HabitDisciplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Kỷ Luật Cá Nhân',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            // Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: AppColors.primary,
              scaffoldBackgroundColor: AppColors.lightBg,
              fontFamily: GoogleFonts.inter().fontFamily,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightBg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: AppColors.lightCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
            ),
            // Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: AppColors.primary,
              scaffoldBackgroundColor: AppColors.darkBg,
              fontFamily: GoogleFonts.inter().fontFamily,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkBg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
