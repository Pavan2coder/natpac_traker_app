import 'package:hive/hive.dart';

part 'complaint_model.g.dart';

@HiveType(typeId: 2)
class Complaint extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late String priority;

  @HiveField(3)
  late String description;
}