// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_history_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalHistoryItemCollection on Isar {
  IsarCollection<LocalHistoryItem> get localHistoryItems => this.collection();
}

const LocalHistoryItemSchema = CollectionSchema(
  name: r'LocalHistoryItem',
  id: -4354684500416878768,
  properties: {
    r'chapterList': PropertySchema(
      id: 0,
      name: r'chapterList',
      type: IsarType.objectList,

      target: r'Chapter',
    ),
    r'currentPage': PropertySchema(
      id: 1,
      name: r'currentPage',
      type: IsarType.long,
    ),
    r'currentTimeSeconds': PropertySchema(
      id: 2,
      name: r'currentTimeSeconds',
      type: IsarType.long,
    ),
    r'episodeList': PropertySchema(
      id: 3,
      name: r'episodeList',
      type: IsarType.objectList,

      target: r'Episode',
    ),
    r'episodeUrlsJson': PropertySchema(
      id: 4,
      name: r'episodeUrlsJson',
      type: IsarType.string,
    ),
    r'image': PropertySchema(id: 5, name: r'image', type: IsarType.string),
    r'lastTimeSeconds': PropertySchema(
      id: 6,
      name: r'lastTimeSeconds',
      type: IsarType.long,
    ),
    r'lastWatched': PropertySchema(
      id: 7,
      name: r'lastWatched',
      type: IsarType.dateTime,
    ),
    r'link': PropertySchema(id: 8, name: r'link', type: IsarType.string),
    r'mangaSourceJson': PropertySchema(
      id: 9,
      name: r'mangaSourceJson',
      type: IsarType.string,
    ),
    r'mediaData': PropertySchema(
      id: 10,
      name: r'mediaData',
      type: IsarType.object,

      target: r'AnilistMediaData',
    ),
    r'mediaId': PropertySchema(id: 11, name: r'mediaId', type: IsarType.long),
    r'mediaType': PropertySchema(
      id: 12,
      name: r'mediaType',
      type: IsarType.int,
      enumMap: _LocalHistoryItemmediaTypeEnumValueMap,
    ),
    r'progress': PropertySchema(
      id: 13,
      name: r'progress',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 14,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'sourceName': PropertySchema(
      id: 15,
      name: r'sourceName',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 16, name: r'title', type: IsarType.string),
    r'totalDurationSeconds': PropertySchema(
      id: 17,
      name: r'totalDurationSeconds',
      type: IsarType.long,
    ),
  },

  estimateSize: _localHistoryItemEstimateSize,
  serialize: _localHistoryItemSerialize,
  deserialize: _localHistoryItemDeserialize,
  deserializeProp: _localHistoryItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'mediaId': IndexSchema(
      id: -8001372983137409759,
      name: r'mediaId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mediaId',
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
    r'Chapter': ChapterSchema,
    r'Episode': EpisodeSchema,
  },

  getId: _localHistoryItemGetId,
  getLinks: _localHistoryItemGetLinks,
  attach: _localHistoryItemAttach,
  version: '3.3.0-dev.3',
);

int _localHistoryItemEstimateSize(
  LocalHistoryItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.chapterList;
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
    final list = object.episodeList;
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
    final value = object.episodeUrlsJson;
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
    final value = object.link;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mangaSourceJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
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
  {
    final value = object.progress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceName;
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
  return bytesCount;
}

void _localHistoryItemSerialize(
  LocalHistoryItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<Chapter>(
    offsets[0],
    allOffsets,
    ChapterSchema.serialize,
    object.chapterList,
  );
  writer.writeLong(offsets[1], object.currentPage);
  writer.writeLong(offsets[2], object.currentTimeSeconds);
  writer.writeObjectList<Episode>(
    offsets[3],
    allOffsets,
    EpisodeSchema.serialize,
    object.episodeList,
  );
  writer.writeString(offsets[4], object.episodeUrlsJson);
  writer.writeString(offsets[5], object.image);
  writer.writeLong(offsets[6], object.lastTimeSeconds);
  writer.writeDateTime(offsets[7], object.lastWatched);
  writer.writeString(offsets[8], object.link);
  writer.writeString(offsets[9], object.mangaSourceJson);
  writer.writeObject<AnilistMediaData>(
    offsets[10],
    allOffsets,
    AnilistMediaDataSchema.serialize,
    object.mediaData,
  );
  writer.writeLong(offsets[11], object.mediaId);
  writer.writeInt(offsets[12], object.mediaType?.index);
  writer.writeString(offsets[13], object.progress);
  writer.writeString(offsets[14], object.sourceId);
  writer.writeString(offsets[15], object.sourceName);
  writer.writeString(offsets[16], object.title);
  writer.writeLong(offsets[17], object.totalDurationSeconds);
}

LocalHistoryItem _localHistoryItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalHistoryItem();
  object.chapterList = reader.readObjectList<Chapter>(
    offsets[0],
    ChapterSchema.deserialize,
    allOffsets,
    Chapter(),
  );
  object.currentPage = reader.readLongOrNull(offsets[1]);
  object.currentTimeSeconds = reader.readLongOrNull(offsets[2]);
  object.episodeList = reader.readObjectList<Episode>(
    offsets[3],
    EpisodeSchema.deserialize,
    allOffsets,
    Episode(),
  );
  object.episodeUrlsJson = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.image = reader.readStringOrNull(offsets[5]);
  object.lastTimeSeconds = reader.readLongOrNull(offsets[6]);
  object.lastWatched = reader.readDateTimeOrNull(offsets[7]);
  object.link = reader.readStringOrNull(offsets[8]);
  object.mangaSourceJson = reader.readStringOrNull(offsets[9]);
  object.mediaData = reader.readObjectOrNull<AnilistMediaData>(
    offsets[10],
    AnilistMediaDataSchema.deserialize,
    allOffsets,
  );
  object.mediaId = reader.readLongOrNull(offsets[11]);
  object.mediaType =
      _LocalHistoryItemmediaTypeValueEnumMap[reader.readIntOrNull(offsets[12])];
  object.progress = reader.readStringOrNull(offsets[13]);
  object.sourceId = reader.readStringOrNull(offsets[14]);
  object.sourceName = reader.readStringOrNull(offsets[15]);
  object.title = reader.readStringOrNull(offsets[16]);
  object.totalDurationSeconds = reader.readLongOrNull(offsets[17]);
  return object;
}

P _localHistoryItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<Chapter>(
            offset,
            ChapterSchema.deserialize,
            allOffsets,
            Chapter(),
          ))
          as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readObjectList<Episode>(
            offset,
            EpisodeSchema.deserialize,
            allOffsets,
            Episode(),
          ))
          as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readObjectOrNull<AnilistMediaData>(
            offset,
            AnilistMediaDataSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (_LocalHistoryItemmediaTypeValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalHistoryItemmediaTypeEnumValueMap = {'anime': 0, 'manga': 1};
const _LocalHistoryItemmediaTypeValueEnumMap = {
  0: HistoryMediaType.anime,
  1: HistoryMediaType.manga,
};

Id _localHistoryItemGetId(LocalHistoryItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localHistoryItemGetLinks(LocalHistoryItem object) {
  return [];
}

void _localHistoryItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalHistoryItem object,
) {
  object.id = id;
}

extension LocalHistoryItemByIndex on IsarCollection<LocalHistoryItem> {
  Future<LocalHistoryItem?> getByMediaId(int? mediaId) {
    return getByIndex(r'mediaId', [mediaId]);
  }

  LocalHistoryItem? getByMediaIdSync(int? mediaId) {
    return getByIndexSync(r'mediaId', [mediaId]);
  }

  Future<bool> deleteByMediaId(int? mediaId) {
    return deleteByIndex(r'mediaId', [mediaId]);
  }

  bool deleteByMediaIdSync(int? mediaId) {
    return deleteByIndexSync(r'mediaId', [mediaId]);
  }

  Future<List<LocalHistoryItem?>> getAllByMediaId(List<int?> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'mediaId', values);
  }

  List<LocalHistoryItem?> getAllByMediaIdSync(List<int?> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'mediaId', values);
  }

  Future<int> deleteAllByMediaId(List<int?> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'mediaId', values);
  }

  int deleteAllByMediaIdSync(List<int?> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'mediaId', values);
  }

  Future<Id> putByMediaId(LocalHistoryItem object) {
    return putByIndex(r'mediaId', object);
  }

  Id putByMediaIdSync(LocalHistoryItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'mediaId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMediaId(List<LocalHistoryItem> objects) {
    return putAllByIndex(r'mediaId', objects);
  }

  List<Id> putAllByMediaIdSync(
    List<LocalHistoryItem> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'mediaId', objects, saveLinks: saveLinks);
  }
}

extension LocalHistoryItemQueryWhereSort
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QWhere> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhere> anyMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mediaId'),
      );
    });
  }
}

extension LocalHistoryItemQueryWhere
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QWhereClause> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mediaId', value: [null]),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdEqualTo(int? mediaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mediaId', value: [mediaId]),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdNotEqualTo(int? mediaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [],
                upper: [mediaId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [mediaId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [mediaId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [],
                upper: [mediaId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdGreaterThan(int? mediaId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaId',
          lower: [mediaId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdLessThan(int? mediaId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaId',
          lower: [],
          upper: [mediaId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterWhereClause>
  mediaIdBetween(
    int? lowerMediaId,
    int? upperMediaId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'mediaId',
          lower: [lowerMediaId],
          includeLower: includeLower,
          upper: [upperMediaId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LocalHistoryItemQueryFilter
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QFilterCondition> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'chapterList'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'chapterList'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chapterList', length, true, length, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chapterList', 0, true, 0, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chapterList', 0, false, 999999, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chapterList', 0, true, length, include);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'chapterList', length, include, 999999, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chapterList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentPage'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentPage'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentPage', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentPage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentPageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentPage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentTimeSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentTimeSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentTimeSeconds', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  currentTimeSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentTimeSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeList'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeList'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodeList', length, true, length, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodeList', 0, true, 0, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodeList', 0, false, 999999, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodeList', 0, true, length, include);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'episodeList', length, include, 999999, true);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodeList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeUrlsJson'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeUrlsJson'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeUrlsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeUrlsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeUrlsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeUrlsJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeUrlsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeUrlsJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  imageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'image'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  imageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'image'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastTimeSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastTimeSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastTimeSeconds', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastTimeSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastTimeSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastTimeSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastWatched'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastWatched'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastWatched', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastWatched',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastWatched',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  lastWatchedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastWatched',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'link'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'link'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'link',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'link',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'link',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'link', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  linkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'link', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mangaSourceJson'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mangaSourceJson'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mangaSourceJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mangaSourceJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mangaSourceJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mangaSourceJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mangaSourceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mangaSourceJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaData'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaData'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaId'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaId'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaId', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaType'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeEqualTo(HistoryMediaType? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaType', value: value),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeGreaterThan(HistoryMediaType? value, {bool include = false}) {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeLessThan(HistoryMediaType? value, {bool include = false}) {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaTypeBetween(
    HistoryMediaType? lower,
    HistoryMediaType? upper, {
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'progress'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'progress'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'progress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'progress',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'progress', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  progressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'progress', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceId'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceId'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceId', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceId', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceName'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceName'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceName', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  sourceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceName', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'title'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'title'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
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

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalDurationSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalDurationSeconds'),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  totalDurationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalDurationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LocalHistoryItemQueryObject
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QFilterCondition> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  chapterListElement(FilterQuery<Chapter> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'chapterList');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  episodeListElement(FilterQuery<Episode> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'episodeList');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterFilterCondition>
  mediaData(FilterQuery<AnilistMediaData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'mediaData');
    });
  }
}

extension LocalHistoryItemQueryLinks
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QFilterCondition> {}

extension LocalHistoryItemQuerySortBy
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QSortBy> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByCurrentPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPage', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByCurrentPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPage', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByCurrentTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByCurrentTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByEpisodeUrlsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeUrlsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByEpisodeUrlsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeUrlsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> sortByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByLastTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByLastTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByLastWatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> sortByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMangaSourceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaSourceJson', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMangaSourceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaSourceJson', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  sortByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }
}

extension LocalHistoryItemQuerySortThenBy
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QSortThenBy> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByCurrentPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPage', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByCurrentPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPage', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByCurrentTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByCurrentTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByEpisodeUrlsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeUrlsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByEpisodeUrlsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeUrlsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> thenByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByLastTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByLastTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByLastWatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> thenByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMangaSourceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaSourceJson', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMangaSourceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaSourceJson', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QAfterSortBy>
  thenByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }
}

extension LocalHistoryItemQueryWhereDistinct
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct> {
  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByCurrentPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentPage');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByCurrentTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentTimeSeconds');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByEpisodeUrlsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeUrlsJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct> distinctByImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'image', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByLastTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTimeSeconds');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWatched');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct> distinctByLink({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'link', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByMangaSourceJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'mangaSourceJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType');
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByProgress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctBySourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctBySourceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalHistoryItem, LocalHistoryItem, QDistinct>
  distinctByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationSeconds');
    });
  }
}

extension LocalHistoryItemQueryProperty
    on QueryBuilder<LocalHistoryItem, LocalHistoryItem, QQueryProperty> {
  QueryBuilder<LocalHistoryItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalHistoryItem, List<Chapter>?, QQueryOperations>
  chapterListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterList');
    });
  }

  QueryBuilder<LocalHistoryItem, int?, QQueryOperations> currentPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentPage');
    });
  }

  QueryBuilder<LocalHistoryItem, int?, QQueryOperations>
  currentTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentTimeSeconds');
    });
  }

  QueryBuilder<LocalHistoryItem, List<Episode>?, QQueryOperations>
  episodeListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeList');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations>
  episodeUrlsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeUrlsJson');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations> imageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'image');
    });
  }

  QueryBuilder<LocalHistoryItem, int?, QQueryOperations>
  lastTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTimeSeconds');
    });
  }

  QueryBuilder<LocalHistoryItem, DateTime?, QQueryOperations>
  lastWatchedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWatched');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations> linkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'link');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations>
  mangaSourceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaSourceJson');
    });
  }

  QueryBuilder<LocalHistoryItem, AnilistMediaData?, QQueryOperations>
  mediaDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaData');
    });
  }

  QueryBuilder<LocalHistoryItem, int?, QQueryOperations> mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }

  QueryBuilder<LocalHistoryItem, HistoryMediaType?, QQueryOperations>
  mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations>
  sourceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceName');
    });
  }

  QueryBuilder<LocalHistoryItem, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LocalHistoryItem, int?, QQueryOperations>
  totalDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationSeconds');
    });
  }
}
