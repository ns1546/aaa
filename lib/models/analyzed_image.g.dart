// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyzed_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalyzedImageAdapter extends TypeAdapter<AnalyzedImage> {
  @override
  final int typeId = 0;

  @override
  AnalyzedImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyzedImage(
      id: fields[0] as String,
      localImagePath: fields[1] as String,
      smartName: fields[2] as String,
      description: fields[3] as String,
      tags: (fields[4] as List).cast<String>(),
      quality: (fields[5] as Map).cast<String, String>(),
      resolution: fields[6] as String,
      sizeInMb: fields[7] as double,
      cameraModel: fields[8] as String,
      capturedDate: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AnalyzedImage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.localImagePath)
      ..writeByte(2)
      ..write(obj.smartName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.quality)
      ..writeByte(6)
      ..write(obj.resolution)
      ..writeByte(7)
      ..write(obj.sizeInMb)
      ..writeByte(8)
      ..write(obj.cameraModel)
      ..writeByte(9)
      ..write(obj.capturedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyzedImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
