import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository.freezed.dart';
part 'repository.g.dart';

@freezed
class Repository with _$Repository {
  const factory Repository({
    required String id,
    required String name,
    required String fullName,
    required String owner,
    required String description,
    required int stars,
    @Default(0) int starsToday,
    @Default(0) int forks,
    String? language,
    String? languageColor,
    @Default(false) bool hasJapaneseReadme,
    required String url,
    DateTime? updatedAt,
    String? descriptionJa,
    String? summaryJa,
  }) = _Repository;

  factory Repository.fromJson(Map<String, dynamic> json) =>
      _$RepositoryFromJson(json);
}

@freezed
class TrendingResponse with _$TrendingResponse {
  const factory TrendingResponse({
    required List<Repository> repositories,
    required DateTime updatedAt,
  }) = _TrendingResponse;

  factory TrendingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrendingResponseFromJson(json);
}
