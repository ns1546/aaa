import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/analyzed_image.dart';
import 'analyzer_screen.dart';
import 'report_screen.dart';
import 'glass_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabAnimation.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (photo != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AnalyzerScreen(imageFile: File(photo.path)),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFFB388FF)],
          ).createShader(bounds),
          child: const Text('Optic.AI'),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.6),
            radius: 1.5,
            colors: [Color(0xFF1E103E), Color(0xFF0A0A0E)],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<AnalyzedImage>('analyzed_images').listenable(),
            builder: (context, Box<AnalyzedImage> box, _) {
              if (box.values.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Initialize a new scan.',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              final images = box.values.toList().reversed.toList();

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportScreen(analyzedImage: image)),
                      );
                    },
                    child: Hero(
                      tag: image.id,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(image.localImagePath), fit: BoxFit.cover),
                              Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  borderRadius: 0, // blends with bottom
                                  opacity: 0.2,
                                  blur: 15,
                                  border: Border.all(color: Colors.transparent),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        image.smartName,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.stars, size: 12, color: Theme.of(context).colorScheme.secondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              image.tags.isNotEmpty ? image.tags.take(2).join(', ') : 'AI Scanned',
                                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.4 + (_fabAnimation.value * 0.3)),
                  blurRadius: 20 + (_fabAnimation.value * 10),
                  spreadRadius: 2,
                )
              ]
            ),
            child: child,
          );
        },
        child: FloatingActionButton.large(
          onPressed: _captureImage,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6F00FF), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: const Center(child: Icon(Icons.center_focus_strong, color: Colors.white, size: 38)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
