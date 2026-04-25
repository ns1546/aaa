import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/file_input.dart';
import '../models/analyzed_image.dart';
import 'groq_service.dart';

class ImageProcessorService {
  final GroqService _aiService = GroqService();

  Future<AnalyzedImage?> processImage(File file) async {
    try {
      // 1. Local Extraction
      final bytes = await file.readAsBytes();
      
      // Get file size in MB
      final double sizeInMb = bytes.lengthInBytes / (1024 * 1024);
      
      // Get exact dimensions (Resolution)
      final size = ImageSizeGetter.getSize(FileInput(file));
      final resolution = '${size.width}x${size.height}';
      
      // Get EXIF data (Camera Model, Date)
      final exifTags = await readExifFromBytes(bytes);
      String cameraModel = "Unknown Device";
      if (exifTags.containsKey('Image Model')) {
         cameraModel = exifTags['Image Model'].toString();
      } else if (exifTags.containsKey('Image Make')) {
         cameraModel = exifTags['Image Make'].toString();
      }

      DateTime capturedDate = DateTime.now();
      if (exifTags.containsKey('Image DateTime')) {
         try {
           final dateString = exifTags['Image DateTime'].toString();
           // Basic EXIF format: YYYY:MM:DD HH:MM:SS
           final formattedString = dateString.replaceFirst(':', '-').replaceFirst(':', '-');
           capturedDate = DateTime.parse(formattedString);
         } catch (e) {
           // Fallback to now
         }
      }

      // 2. AI Processing
      // Best guess for mime type
      String mimeType = 'image/jpeg';
      if (file.path.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }

      final aiResult = await _aiService.analyzeImage(bytes, mimeType);
      
      if (aiResult == null) {
        throw Exception("Failed to get AI analysis.");
      }

      // 3. Aggregation
      return AnalyzedImage.fromJson(
        aiResult,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        localImagePath: file.path,
        resolution: resolution,
        sizeInMb: sizeInMb,
        cameraModel: cameraModel,
        capturedDate: capturedDate,
      );

    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }
}
