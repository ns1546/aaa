import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/analyzed_image.dart';
import '../services/image_processor.dart';
import 'report_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  final File imageFile;

  const AnalyzerScreen({super.key, required this.imageFile});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> with SingleTickerProviderStateMixin {
  final ImageProcessorService _processor = ImageProcessorService();
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  String _statusMessage = "IDENTIFYING PIXELS...";

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut));
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // UX delay for visual
      if (mounted) setState(() => _statusMessage = "NEURAL INFERENCE ACTIVE...");
      
      final result = await _processor.processImage(widget.imageFile);
      
      if (result != null) {
        final box = Hive.box<AnalyzedImage>('analyzed_images');
        await box.add(result);

        if (mounted) {
           Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ReportScreen(analyzedImage: result),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        if (mounted) _handleError("Analysis failed. Try again.");
      }
    } catch (e) {
      if (mounted) _handleError("Network fault.");
    }
  }

  void _handleError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(widget.imageFile, fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.85),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFFB388FF)],
                  ).createShader(bounds),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 4, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: FileImage(widget.imageFile),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.15), blurRadius: 40, spreadRadius: 10),
                        ]
                      ),
                    ),
                    // Scanning line
                    AnimatedBuilder(
                      animation: _scannerAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scannerAnimation.value * 380, // Height is 400
                          child: Container(
                            width: 300,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF00E5FF), blurRadius: 15, spreadRadius: 3),
                                BoxShadow(color: Colors.white, blurRadius: 5, spreadRadius: 1),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
