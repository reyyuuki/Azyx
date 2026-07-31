// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOfflineItemCollection on Isar {
  IsarCollection<OfflineItem> get offlineItems => this.collection();
}

const OfflineItemSchema = CollectionSchema(
  name: r'OfflineItem',
  id: 2171157123690281263,
  properties: {
    r'animeTitle': PropertySchema(
      id: 0,
      name: r'animeTitle',
      type: IsarType.string,
    ),
    r'chaptersList': PropertySchema(
      id: 1,
      name: r'chaptersList',
      type: IsarType.objectList,

      target: r'Chapter',
    ),
    r'episodesList': PropertySchema(
      id: 2,
      name: r'episodesList',
      type: IsarType.objectList,

      target: r'Episode',
    ),
    r'mediaData': PropertySchema(
      id: 3,
      name: r'mediaData',
      type: IsarType.object,

      target: r'AnilistMediaData',
    ),
    r'mediaType': PropertySchema(
      id: 4,
      name: r'mediaType',
      type: IsarType.long,
    ),
    r'number': PropertySchema(id: 5, name: r'number', type: IsarType.string),
  },

  estimateSize: _offlineItemEstimateSize,
  serialize: _offlineItemSerialize,
  deserialize: _offlineItemDeserialize,
  deserializeProp: _offlineItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'number': IndexSchema(
      id: 5012388430481709372,
      name: r'number',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'number',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'mediaType': IndexSchema(
      id: 6292565701790234963,
      name: r'mediaType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mediaType',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'AnilistMediaData': AnilistMediaDataSchema,
    r'Character': CharacterSchema,
    r'Episode': EpisodeSchema,
    r'Chapter': ChapterSchema,
  },

  getId: _offlineItemGetId,
  getLinks: _offlineItemGetLinks,
  attach: _offlineItemAttach,
  version: '3.3.0-dev.3',
);

int _offlineItemEstimateSize(
  OfflineItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animeTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.chaptersList;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Chapter]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += ChapterSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final list = object.episodesList;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Episode]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += EpisodeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.mediaData;
    if (value != null) {
      bytesCount +=
          3 +
          AnilistMediaDataSchema.estimateSize(
            value,
            allOffsets[AnilistMediaData]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.number.length * 3;
  return bytesCount;
}

void _offlineItemSerialize(
  OfflineItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animeTitle);
  writer.writeObjectList<Chapter>(
    offsets[1],
    allOffsets,
    ChapterSchema.serialize,
    object.chaptersList,
  );
  writer.writeObjectList<Episode>(
    offsets[2],
    allOffsets,
    EpisodeSchema.serialize,
    object.episodesList,
  );
  writer.writeObject<AnilistMediaData>(
    offsets[3],
    allOffsets,
    AnilistMediaDataSchema.serialize,
    object.mediaData,
  );
  writer.writeLong(offsets[4], object.mediaType);
  writer.writeString(offsets[5], object.number);
}

OfflineItem _offlineItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OfflineItem(
    animeTitle: reader.readStringOrNull(offsets[0]),
    chaptersList: reader.readObjectList<Chapter>(
      offsets[1],
      ChapterSchema.deserialize,
      allOffsets,
      Chapter(),
    ),
    episodesList: reader.readObjectList<Episode>(
      offsets[2],
      EpisodeSchema.deserialize,
      allOffsets,
      Episode(),
    ),
    mediaData: reader.readObjectOrNull<AnilistMediaData>(
      offsets[3],
      AnilistMediaDataSchema.deserialize,
      allOffsets,
    ),
    mediaType: reader.readLongOrNull(offsets[4]),
    number: reader.readString(offsets[5]),
  );
  object.id = id;
  return object;
}

P _offlineItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<Chapter>(
            offset,
            ChapterSchema.deserialize,
            allOffsets,
            Chapter(),
          ))
          as P;
    case 2:
      return (reader.readObjectList<Episode>(
            offset,
            EpisodeSchema.deserialize,
            allOffsets,
            Episode(),
          ))
          as P;
    case 3:
      return (reader.readObjectOrNull<AnilistMediaData>(
            offset,
            AnilistMediaDataSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _offlineItemGetId(OfflineItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _offlineItemGetLinks(OfflineItem object) {
  return [];
}

void _offlineItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  OfflineItem object,
) {
  object.id = id;
}

extension OfflineItemQueryWhereSort
    on QueryBuilder<OfflineItem, OfflineItem, QWhere> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhere> anyMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mediaType'),
      );
    });
  }
}

extension OfflineItemQueryWhere
    on QueryBuilder<OfflineItem, OfflineItem, QWhereClause> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> numberEqualTo(
    String number,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'number', value: [number]),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> numberNotEqualTo(
    String number,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'number',
                lower: [],
                upper: [number],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'number',
                lower: [number],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'number',
                lower: [number],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'number',
                lower: [],
                upper: [number],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> mediaTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mediaType', value: [null]),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause>
  mediaTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaType',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> mediaTypeEqualTo(
    int? mediaType,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mediaType', value: [mediaType]),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> mediaTypeNotEqualTo(
    int? mediaType,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaType',
                lower: [],
                upper: [mediaType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaType',
                lower: [mediaType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaType',
                lower: [mediaType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaType',
                lower: [],
                upper: [mediaType],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause>
  mediaTypeGreaterThan(int? mediaType, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaType',
          lower: [mediaType],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> mediaTypeLessThan(
    int? mediaType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaType',
          lower: [],
          upper: [mediaType],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterWhereClause> mediaTypeBetween(
    int? lowerMediaType,
    int? upperMediaType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaType',
          lower: [lowerMediaType],
          includeLower: includeLower,
          upper: [upperMediaType],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OfflineItemQueryFilter
    on QueryBuilder<OfflineItem, OfflineItem, QFilterCondition> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'animeTitle'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'animeTitle'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animeTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'animeTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'animeTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animeTitle', value: ''),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  animeTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'animeTitle', value: ''),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'chaptersList'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'chaptersList'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chaptersList', length, true, length, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chaptersList', 0, true, 0, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chaptersList', 0, false, 999999, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chaptersList', 0, true, length, include);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chaptersList', length, include, 999999, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chaptersList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodesList'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodesList'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodesList', length, true, length, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodesList', 0, true, 0, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodesList', 0, false, 999999, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodesList', 0, true, length, include);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodesList', length, include, 999999, true);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodesList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaData'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaData'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaType', value: value),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeGreaterThan(int? value, {bool include = false}) {
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

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeLessThan(int? value, {bool include = false}) {
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

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  mediaTypeBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  numberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'number',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  numberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'number',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> numberMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'number',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  numberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'number', value: ''),
      );
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  numberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'number', value: ''),
      );
    });
  }
}

extension OfflineItemQueryObject
    on QueryBuilder<OfflineItem, OfflineItem, QFilterCondition> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  chaptersListElement(FilterQuery<Chapter> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'chaptersList');
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition>
  episodesListElement(FilterQuery<Episode> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'episodesList');
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterFilterCondition> mediaData(
    FilterQuery<AnilistMediaData> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'mediaData');
    });
  }
}

extension OfflineItemQueryLinks
    on QueryBuilder<OfflineItem, OfflineItem, QFilterCondition> {}

extension OfflineItemQuerySortBy
    on QueryBuilder<OfflineItem, OfflineItem, QSortBy> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByAnimeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeTitle', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByAnimeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeTitle', Sort.desc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }
}

extension OfflineItemQuerySortThenBy
    on QueryBuilder<OfflineItem, OfflineItem, QSortThenBy> {
  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByAnimeTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeTitle', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByAnimeTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeTitle', Sort.desc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }
}

extension OfflineItemQueryWhereDistinct
    on QueryBuilder<OfflineItem, OfflineItem, QDistinct> {
  QueryBuilder<OfflineItem, OfflineItem, QDistinct> distinctByAnimeTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animeTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QDistinct> distinctByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType');
    });
  }

  QueryBuilder<OfflineItem, OfflineItem, QDistinct> distinctByNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'number', caseSensitive: caseSensitive);
    });
  }
}

extension OfflineItemQueryProperty
    on QueryBuilder<OfflineItem, OfflineItem, QQueryProperty> {
  QueryBuilder<OfflineItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OfflineItem, String?, QQueryOperations> animeTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animeTitle');
    });
  }

  QueryBuilder<OfflineItem, List<Chapter>?, QQueryOperations>
  chaptersListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chaptersList');
    });
  }

  QueryBuilder<OfflineItem, List<Episode>?, QQueryOperations>
  episodesListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodesList');
    });
  }

  QueryBuilder<OfflineItem, AnilistMediaData?, QQueryOperations>
  mediaDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaData');
    });
  }

  QueryBuilder<OfflineItem, int?, QQueryOperations> mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<OfflineItem, String, QQueryOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'number');
    });
  }
}
