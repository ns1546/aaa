import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analyzed_image.dart';
import 'glass_card.dart';

class ReportScreen extends StatelessWidget {
  final AnalyzedImage analyzedImage;

  const ReportScreen({super.key, required this.analyzedImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: analyzedImage.id,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(analyzedImage.localImagePath), fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Card
                    GlassCard(
                      blur: 20,
                      opacity: 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFFB388FF)],
                            ).createShader(bounds),
                            child: Text(
                              analyzedImage.smartName.replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            analyzedImage.description,
                            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.6),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: analyzedImage.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                              ),
                              child: Text("#$tag", style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // AI Metrics
                    Text("SYNTHETIC METRICS", style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Row(
                        children: [
                          Expanded(child: _buildMetricRing(context, "Lighting", analyzedImage.quality['Lighting'] ?? '7')),
                          Expanded(child: _buildMetricRing(context, "Sharpness", analyzedImage.quality['Sharpness'] ?? '8')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exif Data
                    Text("FILE METADATA", style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildMetaDataRow(Icons.crop_free, "Dimensions", analyzedImage.resolution),
                          _buildDivider(),
                          _buildMetaDataRow(Icons.data_usage, "Size", "${analyzedImage.sizeInMb.toStringAsFixed(2)} MB"),
                          _buildDivider(),
                          _buildMetaDataRow(Icons.camera, "Hardware", analyzedImage.cameraModel),
                          _buildDivider(),
                          _buildMetaDataRow(Icons.access_time, "Timestamp", analyzedImage.capturedDate.toLocal().toString().split('.')[0]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRing(BuildContext context, String label, String valueStr) {
    int value = int.tryParse(valueStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (value > 10) value = (value / 10).round();
    final double percentage = (value / 10).clamp(0.0, 1.0);
    
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: Theme.of(context).colorScheme.secondary,
                strokeCap: StrokeCap.round,
              ),
              Center(child: Text("$value/10", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMetaDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white30),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 16);
  }
}
