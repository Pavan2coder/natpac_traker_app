// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 0;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trip()
      ..date = fields[0] as DateTime
      ..durationInSeconds = fields[1] as int
      ..distanceInKm = fields[2] as double
      ..segments = (fields[3] as List).cast<TripSegment>()
      ..companions = (fields[4] as List).cast<Companion>();
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.durationInSeconds)
      ..writeByte(2)
      ..write(obj.distanceInKm)
      ..writeByte(3)
      ..write(obj.segments)
      ..writeByte(4)
      ..write(obj.companions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripSegmentAdapter extends TypeAdapter<TripSegment> {
  @override
  final int typeId = 1;

  @override
  TripSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripSegment()
      ..mode = fields[0] as String?
      ..purpose = fields[1] as String?;
  }

  @override
  void write(BinaryWriter writer, TripSegment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.mode)
      ..writeByte(1)
      ..write(obj.purpose);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompanionAdapter extends TypeAdapter<Companion> {
  @override
  final int typeId = 3;

  @override
  Companion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Companion()
      ..name = fields[0] as String
      ..age = fields[1] as String
      ..relation = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, Companion obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.relation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
