// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_repository.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedRepositoryAdapter extends TypeAdapter<SavedRepository> {
  @override
  final int typeId = 0;

  @override
  SavedRepository read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedRepository(
      repositoryId: fields[0] as String,
      savedAt: fields[1] as DateTime,
      name: fields[2] as String?,
      description: fields[3] as String?,
      stars: fields[4] as int?,
      language: fields[5] as String?,
      url: fields[6] as String?,
      descriptionJa: fields[7] as String?,
      summaryJa: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedRepository obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.repositoryId)
      ..writeByte(1)
      ..write(obj.savedAt)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.stars)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.descriptionJa)
      ..writeByte(8)
      ..write(obj.summaryJa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedRepositoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
