// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepositoryImpl _$$RepositoryImplFromJson(Map<String, dynamic> json) =>
    _$RepositoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      fullName: json['fullName'] as String,
      owner: json['owner'] as String,
      description: json['description'] as String,
      stars: (json['stars'] as num).toInt(),
      starsToday: (json['starsToday'] as num?)?.toInt() ?? 0,
      forks: (json['forks'] as num?)?.toInt() ?? 0,
      language: json['language'] as String?,
      languageColor: json['languageColor'] as String?,
      hasJapaneseReadme: json['hasJapaneseReadme'] as bool? ?? false,
      url: json['url'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      descriptionJa: json['descriptionJa'] as String?,
      summaryJa: json['summaryJa'] as String?,
    );

Map<String, dynamic> _$$RepositoryImplToJson(_$RepositoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fullName': instance.fullName,
      'owner': instance.owner,
      'description': instance.description,
      'stars': instance.stars,
      'starsToday': instance.starsToday,
      'forks': instance.forks,
      'language': instance.language,
      'languageColor': instance.languageColor,
      'hasJapaneseReadme': instance.hasJapaneseReadme,
      'url': instance.url,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'descriptionJa': instance.descriptionJa,
      'summaryJa': instance.summaryJa,
    };

_$TrendingResponseImpl _$$TrendingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendingResponseImpl(
      repositories: (json['repositories'] as List<dynamic>)
          .map((e) => Repository.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TrendingResponseImplToJson(
        _$TrendingResponseImpl instance) =>
    <String, dynamic>{
      'repositories': instance.repositories,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
