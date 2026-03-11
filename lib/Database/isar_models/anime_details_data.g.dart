// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_details_data.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AnilistMediaDataSchema = Schema(
  name: r'AnilistMediaData',
  id: -5760830946583651264,
  properties: {
    r'coverImage': PropertySchema(
      id: 0,
      name: r'coverImage',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'episodes': PropertySchema(id: 2, name: r'episodes', type: IsarType.long),
    r'genres': PropertySchema(
      id: 3,
      name: r'genres',
      type: IsarType.stringList,
    ),
    r'id': PropertySchema(id: 4, name: r'id', type: IsarType.string),
    r'image': PropertySchema(id: 5, name: r'image', type: IsarType.string),
    r'mediaType': PropertySchema(
      id: 6,
      name: r'mediaType',
      type: IsarType.int,
      enumMap: _AnilistMediaDatamediaTypeEnumValueMap,
    ),
    r'popularity': PropertySchema(
      id: 7,
      name: r'popularity',
      type: IsarType.long,
    ),
    r'rating': PropertySchema(id: 8, name: r'rating', type: IsarType.string),
    r'servicesType': PropertySchema(
      id: 9,
      name: r'servicesType',
      type: IsarType.int,
      enumMap: _AnilistMediaDataservicesTypeEnumValueMap,
    ),
    r'status': PropertySchema(id: 10, name: r'status', type: IsarType.string),
    r'timeUntilAiring': PropertySchema(
      id: 11,
      name: r'timeUntilAiring',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 12, name: r'title', type: IsarType.string),
    r'type': PropertySchema(id: 13, name: r'type', type: IsarType.string),
  },

  estimateSize: _anilistMediaDataEstimateSize,
  serialize: _anilistMediaDataSerialize,
  deserialize: _anilistMediaDataDeserialize,
  deserializeProp: _anilistMediaDataDeserializeProp,
);

int _anilistMediaDataEstimateSize(
  AnilistMediaData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.coverImage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.genres;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.id;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.image;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rating;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _anilistMediaDataSerialize(
  AnilistMediaData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.coverImage);
  writer.writeString(offsets[1], object.description);
  writer.writeLong(offsets[2], object.episodes);
  writer.writeStringList(offsets[3], object.genres);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.image);
  writer.writeInt(offsets[6], object.mediaType?.index);
  writer.writeLong(offsets[7], object.popularity);
  writer.writeString(offsets[8], object.rating);
  writer.writeInt(offsets[9], object.servicesType?.index);
  writer.writeString(offsets[10], object.status);
  writer.writeLong(offsets[11], object.timeUntilAiring);
  writer.writeString(offsets[12], object.title);
  writer.writeString(offsets[13], object.type);
}

AnilistMediaData _anilistMediaDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnilistMediaData(
    coverImage: reader.readStringOrNull(offsets[0]),
    description: reader.readStringOrNull(offsets[1]),
    episodes: reader.readLongOrNull(offsets[2]),
    genres: reader.readStringList(offsets[3]),
    id: reader.readStringOrNull(offsets[4]),
    image: reader.readStringOrNull(offsets[5]),
    mediaType:
        _AnilistMediaDatamediaTypeValueEnumMap[reader.readIntOrNull(
          offsets[6],
        )],
    popularity: reader.readLongOrNull(offsets[7]),
    rating: reader.readStringOrNull(offsets[8]),
    servicesType:
        _AnilistMediaDataservicesTypeValueEnumMap[reader.readIntOrNull(
          offsets[9],
        )],
    status: reader.readStringOrNull(offsets[10]),
    timeUntilAiring: reader.readLongOrNull(offsets[11]),
    title: reader.readStringOrNull(offsets[12]),
    type: reader.readStringOrNull(offsets[13]),
  );
  return object;
}

P _anilistMediaDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (_AnilistMediaDatamediaTypeValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (_AnilistMediaDataservicesTypeValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AnilistMediaDatamediaTypeEnumValueMap = {
  'manga': 0,
  'anime': 1,
  'novel': 2,
};
const _AnilistMediaDatamediaTypeValueEnumMap = {
  0: MediaType.manga,
  1: MediaType.anime,
  2: MediaType.novel,
};
const _AnilistMediaDataservicesTypeEnumValueMap = {
  'anilist': 0,
  'mal': 1,
  'simkl': 2,
};
const _AnilistMediaDataservicesTypeValueEnumMap = {
  0: ServicesType.anilist,
  1: ServicesType.mal,
  2: ServicesType.simkl,
};

extension AnilistMediaDataQueryFilter
    on QueryBuilder<AnilistMediaData, AnilistMediaData, QFilterCondition> {
  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'coverImage'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'coverImage'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'coverImage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'coverImage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'coverImage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'coverImage', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  coverImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'coverImage', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodes'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodes'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodes', value: value),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  episodesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'genres'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'genres'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'genres',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'genres',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', length, true, length, true);
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, true, 0, true);
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, false, 999999, true);
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', 0, true, length, include);
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'genres', length, include, 999999, true);
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  genresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'genres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idLessThan(String? value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'image'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'image'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'image',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'image',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeEqualTo(MediaType? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaType', value: value),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeGreaterThan(MediaType? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeLessThan(MediaType? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  mediaTypeBetween(
    MediaType? lower,
    MediaType? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'popularity'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'popularity'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'popularity', value: value),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'popularity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'popularity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  popularityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'popularity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rating'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rating'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rating',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rating',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rating', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  ratingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rating', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'servicesType'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'servicesType'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeEqualTo(ServicesType? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'servicesType', value: value),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeGreaterThan(ServicesType? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'servicesType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeLessThan(ServicesType? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'servicesType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  servicesTypeBetween(
    ServicesType? lower,
    ServicesType? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'servicesType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'status'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'status'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'timeUntilAiring'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'timeUntilAiring'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeUntilAiring', value: value),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeUntilAiring',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeUntilAiring',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  timeUntilAiringBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeUntilAiring',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'title'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'title'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'type'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'type'),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<AnilistMediaData, AnilistMediaData, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension AnilistMediaDataQueryObject
    on QueryBuilder<AnilistMediaData, AnilistMediaData, QFilterCondition> {}
