import 'package:hive/hive.dart';

part 'analyzed_image.g.dart';

@HiveType(typeId: 0)
class AnalyzedImage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String localImagePath;

  @HiveField(2)
  final String smartName;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final Map<String, String> quality;

  @HiveField(6)
  final String resolution;

  @HiveField(7)
  final double sizeInMb;

  @HiveField(8)
  final String cameraModel;

  @HiveField(9)
  final DateTime capturedDate;

  AnalyzedImage({
    required this.id,
    required this.localImagePath,
    required this.smartName,
    required this.description,
    required this.tags,
    required this.quality,
    required this.resolution,
    required this.sizeInMb,
    required this.cameraModel,
    required this.capturedDate,
  });

  factory AnalyzedImage.fromJson(Map<String, dynamic> json, {
    required String id,
    required String localImagePath,
    required String resolution,
    required double sizeInMb,
    required String cameraModel,
    required DateTime capturedDate,
  }) {
    return AnalyzedImage(
      id: id,
      localImagePath: localImagePath,
      smartName: json['smart_name'] ?? 'Unknown_Image',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      quality: {
        'Lighting': json['lighting_quality']?.toString() ?? 'Unknown',
        'Sharpness': json['sharpness']?.toString() ?? 'Unknown',
      },
      resolution: resolution,
      sizeInMb: sizeInMb,
      cameraModel: cameraModel,
      capturedDate: capturedDate,
    );
  }
}
