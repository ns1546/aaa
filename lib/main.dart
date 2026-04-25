import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/analyzed_image.dart';
import 'ui/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(AnalyzedImageAdapter());
  await Hive.openBox<AnalyzedImage>('analyzed_images');

  runApp(const ProviderScope(child: SmartImageAnalyzerApp()));
}

class SmartImageAnalyzerApp extends StatelessWidget {
  const SmartImageAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return MaterialApp(
      title: 'Optic AI Image Analyzer',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFF0A0A0E),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6F00FF),
          secondary: const Color(0xFF00E5FF),
          surface: const Color(0xFF1E1E28),
          background: const Color(0xFF0A0A0E),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarTextStyle: textTheme.titleLarge,
          titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}
