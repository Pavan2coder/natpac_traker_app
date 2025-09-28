// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComplaintAdapter extends TypeAdapter<Complaint> {
  @override
  final int typeId = 2;

  @override
  Complaint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Complaint()
      ..date = fields[0] as DateTime
      ..category = fields[1] as String
      ..priority = fields[2] as String
      ..description = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Complaint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
