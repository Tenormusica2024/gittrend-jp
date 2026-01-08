// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Repository _$RepositoryFromJson(Map<String, dynamic> json) {
  return _Repository.fromJson(json);
}

/// @nodoc
mixin _$Repository {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get owner => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get stars => throw _privateConstructorUsedError;
  int get starsToday => throw _privateConstructorUsedError;
  int get forks => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get languageColor => throw _privateConstructorUsedError;
  bool get hasJapaneseReadme => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get descriptionJa => throw _privateConstructorUsedError;
  String? get summaryJa => throw _privateConstructorUsedError;

  /// Serializes this Repository to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Repository
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepositoryCopyWith<Repository> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepositoryCopyWith<$Res> {
  factory $RepositoryCopyWith(
          Repository value, $Res Function(Repository) then) =
      _$RepositoryCopyWithImpl<$Res, Repository>;
  @useResult
  $Res call(
      {String id,
      String name,
      String fullName,
      String owner,
      String description,
      int stars,
      int starsToday,
      int forks,
      String? language,
      String? languageColor,
      bool hasJapaneseReadme,
      String url,
      DateTime? updatedAt,
      String? descriptionJa,
      String? summaryJa});
}

/// @nodoc
class _$RepositoryCopyWithImpl<$Res, $Val extends Repository>
    implements $RepositoryCopyWith<$Res> {
  _$RepositoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Repository
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fullName = null,
    Object? owner = null,
    Object? description = null,
    Object? stars = null,
    Object? starsToday = null,
    Object? forks = null,
    Object? language = freezed,
    Object? languageColor = freezed,
    Object? hasJapaneseReadme = null,
    Object? url = null,
    Object? updatedAt = freezed,
    Object? descriptionJa = freezed,
    Object? summaryJa = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      starsToday: null == starsToday
          ? _value.starsToday
          : starsToday // ignore: cast_nullable_to_non_nullable
              as int,
      forks: null == forks
          ? _value.forks
          : forks // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      languageColor: freezed == languageColor
          ? _value.languageColor
          : languageColor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasJapaneseReadme: null == hasJapaneseReadme
          ? _value.hasJapaneseReadme
          : hasJapaneseReadme // ignore: cast_nullable_to_non_nullable
              as bool,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      descriptionJa: freezed == descriptionJa
          ? _value.descriptionJa
          : descriptionJa // ignore: cast_nullable_to_non_nullable
              as String?,
      summaryJa: freezed == summaryJa
          ? _value.summaryJa
          : summaryJa // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepositoryImplCopyWith<$Res>
    implements $RepositoryCopyWith<$Res> {
  factory _$$RepositoryImplCopyWith(
          _$RepositoryImpl value, $Res Function(_$RepositoryImpl) then) =
      __$$RepositoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String fullName,
      String owner,
      String description,
      int stars,
      int starsToday,
      int forks,
      String? language,
      String? languageColor,
      bool hasJapaneseReadme,
      String url,
      DateTime? updatedAt,
      String? descriptionJa,
      String? summaryJa});
}

/// @nodoc
class __$$RepositoryImplCopyWithImpl<$Res>
    extends _$RepositoryCopyWithImpl<$Res, _$RepositoryImpl>
    implements _$$RepositoryImplCopyWith<$Res> {
  __$$RepositoryImplCopyWithImpl(
      _$RepositoryImpl _value, $Res Function(_$RepositoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Repository
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? fullName = null,
    Object? owner = null,
    Object? description = null,
    Object? stars = null,
    Object? starsToday = null,
    Object? forks = null,
    Object? language = freezed,
    Object? languageColor = freezed,
    Object? hasJapaneseReadme = null,
    Object? url = null,
    Object? updatedAt = freezed,
    Object? descriptionJa = freezed,
    Object? summaryJa = freezed,
  }) {
    return _then(_$RepositoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      starsToday: null == starsToday
          ? _value.starsToday
          : starsToday // ignore: cast_nullable_to_non_nullable
              as int,
      forks: null == forks
          ? _value.forks
          : forks // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      languageColor: freezed == languageColor
          ? _value.languageColor
          : languageColor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasJapaneseReadme: null == hasJapaneseReadme
          ? _value.hasJapaneseReadme
          : hasJapaneseReadme // ignore: cast_nullable_to_non_nullable
              as bool,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      descriptionJa: freezed == descriptionJa
          ? _value.descriptionJa
          : descriptionJa // ignore: cast_nullable_to_non_nullable
              as String?,
      summaryJa: freezed == summaryJa
          ? _value.summaryJa
          : summaryJa // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RepositoryImpl implements _Repository {
  const _$RepositoryImpl(
      {required this.id,
      required this.name,
      required this.fullName,
      required this.owner,
      required this.description,
      required this.stars,
      this.starsToday = 0,
      this.forks = 0,
      this.language,
      this.languageColor,
      this.hasJapaneseReadme = false,
      required this.url,
      this.updatedAt,
      this.descriptionJa,
      this.summaryJa});

  factory _$RepositoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepositoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String fullName;
  @override
  final String owner;
  @override
  final String description;
  @override
  final int stars;
  @override
  @JsonKey()
  final int starsToday;
  @override
  @JsonKey()
  final int forks;
  @override
  final String? language;
  @override
  final String? languageColor;
  @override
  @JsonKey()
  final bool hasJapaneseReadme;
  @override
  final String url;
  @override
  final DateTime? updatedAt;
  @override
  final String? descriptionJa;
  @override
  final String? summaryJa;

  @override
  String toString() {
    return 'Repository(id: $id, name: $name, fullName: $fullName, owner: $owner, description: $description, stars: $stars, starsToday: $starsToday, forks: $forks, language: $language, languageColor: $languageColor, hasJapaneseReadme: $hasJapaneseReadme, url: $url, updatedAt: $updatedAt, descriptionJa: $descriptionJa, summaryJa: $summaryJa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepositoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.starsToday, starsToday) ||
                other.starsToday == starsToday) &&
            (identical(other.forks, forks) || other.forks == forks) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.languageColor, languageColor) ||
                other.languageColor == languageColor) &&
            (identical(other.hasJapaneseReadme, hasJapaneseReadme) ||
                other.hasJapaneseReadme == hasJapaneseReadme) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.descriptionJa, descriptionJa) ||
                other.descriptionJa == descriptionJa) &&
            (identical(other.summaryJa, summaryJa) ||
                other.summaryJa == summaryJa));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      fullName,
      owner,
      description,
      stars,
      starsToday,
      forks,
      language,
      languageColor,
      hasJapaneseReadme,
      url,
      updatedAt,
      descriptionJa,
      summaryJa);

  /// Create a copy of Repository
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepositoryImplCopyWith<_$RepositoryImpl> get copyWith =>
      __$$RepositoryImplCopyWithImpl<_$RepositoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepositoryImplToJson(
      this,
    );
  }
}

abstract class _Repository implements Repository {
  const factory _Repository(
      {required final String id,
      required final String name,
      required final String fullName,
      required final String owner,
      required final String description,
      required final int stars,
      final int starsToday,
      final int forks,
      final String? language,
      final String? languageColor,
      final bool hasJapaneseReadme,
      required final String url,
      final DateTime? updatedAt,
      final String? descriptionJa,
      final String? summaryJa}) = _$RepositoryImpl;

  factory _Repository.fromJson(Map<String, dynamic> json) =
      _$RepositoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get fullName;
  @override
  String get owner;
  @override
  String get description;
  @override
  int get stars;
  @override
  int get starsToday;
  @override
  int get forks;
  @override
  String? get language;
  @override
  String? get languageColor;
  @override
  bool get hasJapaneseReadme;
  @override
  String get url;
  @override
  DateTime? get updatedAt;
  @override
  String? get descriptionJa;
  @override
  String? get summaryJa;

  /// Create a copy of Repository
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepositoryImplCopyWith<_$RepositoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendingResponse _$TrendingResponseFromJson(Map<String, dynamic> json) {
  return _TrendingResponse.fromJson(json);
}

/// @nodoc
mixin _$TrendingResponse {
  List<Repository> get repositories => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TrendingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendingResponseCopyWith<TrendingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendingResponseCopyWith<$Res> {
  factory $TrendingResponseCopyWith(
          TrendingResponse value, $Res Function(TrendingResponse) then) =
      _$TrendingResponseCopyWithImpl<$Res, TrendingResponse>;
  @useResult
  $Res call({List<Repository> repositories, DateTime updatedAt});
}

/// @nodoc
class _$TrendingResponseCopyWithImpl<$Res, $Val extends TrendingResponse>
    implements $TrendingResponseCopyWith<$Res> {
  _$TrendingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repositories = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      repositories: null == repositories
          ? _value.repositories
          : repositories // ignore: cast_nullable_to_non_nullable
              as List<Repository>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendingResponseImplCopyWith<$Res>
    implements $TrendingResponseCopyWith<$Res> {
  factory _$$TrendingResponseImplCopyWith(_$TrendingResponseImpl value,
          $Res Function(_$TrendingResponseImpl) then) =
      __$$TrendingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Repository> repositories, DateTime updatedAt});
}

/// @nodoc
class __$$TrendingResponseImplCopyWithImpl<$Res>
    extends _$TrendingResponseCopyWithImpl<$Res, _$TrendingResponseImpl>
    implements _$$TrendingResponseImplCopyWith<$Res> {
  __$$TrendingResponseImplCopyWithImpl(_$TrendingResponseImpl _value,
      $Res Function(_$TrendingResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repositories = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TrendingResponseImpl(
      repositories: null == repositories
          ? _value._repositories
          : repositories // ignore: cast_nullable_to_non_nullable
              as List<Repository>,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendingResponseImpl implements _TrendingResponse {
  const _$TrendingResponseImpl(
      {required final List<Repository> repositories, required this.updatedAt})
      : _repositories = repositories;

  factory _$TrendingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendingResponseImplFromJson(json);

  final List<Repository> _repositories;
  @override
  List<Repository> get repositories {
    if (_repositories is EqualUnmodifiableListView) return _repositories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repositories);
  }

  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TrendingResponse(repositories: $repositories, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendingResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._repositories, _repositories) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_repositories), updatedAt);

  /// Create a copy of TrendingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendingResponseImplCopyWith<_$TrendingResponseImpl> get copyWith =>
      __$$TrendingResponseImplCopyWithImpl<_$TrendingResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendingResponseImplToJson(
      this,
    );
  }
}

abstract class _TrendingResponse implements TrendingResponse {
  const factory _TrendingResponse(
      {required final List<Repository> repositories,
      required final DateTime updatedAt}) = _$TrendingResponseImpl;

  factory _TrendingResponse.fromJson(Map<String, dynamic> json) =
      _$TrendingResponseImpl.fromJson;

  @override
  List<Repository> get repositories;
  @override
  DateTime get updatedAt;

  /// Create a copy of TrendingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendingResponseImplCopyWith<_$TrendingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
