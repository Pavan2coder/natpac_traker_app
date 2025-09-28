import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late int durationInSeconds;

  @HiveField(2)
  late double distanceInKm;

  @HiveField(3)
  late List<TripSegment> segments;

  // New field to store companions
  @HiveField(4)
  late List<Companion> companions;
}

@HiveType(typeId: 1)
class TripSegment extends HiveObject {
  @HiveField(0)
  String? mode;

  @HiveField(1)
  String? purpose;
}

// New HiveObject for Companions
@HiveType(typeId: 3)
class Companion extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String age;

  @HiveField(2)
  late String relation;
}