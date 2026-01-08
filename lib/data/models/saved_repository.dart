import 'package:hive/hive.dart';

part 'saved_repository.g.dart';

@HiveType(typeId: 0)
class SavedRepository extends HiveObject {
  @HiveField(0)
  final String repositoryId;

  @HiveField(1)
  final DateTime savedAt;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final int? stars;

  @HiveField(5)
  final String? language;

  @HiveField(6)
  final String? url;

  @HiveField(7)
  final String? descriptionJa;

  @HiveField(8)
  final String? summaryJa;

  SavedRepository({
    required this.repositoryId,
    required this.savedAt,
    this.name,
    this.description,
    this.stars,
    this.language,
    this.url,
    this.descriptionJa,
    this.summaryJa,
  });
}
