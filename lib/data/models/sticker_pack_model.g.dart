// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_pack_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStickerPackModelCollection on Isar {
  IsarCollection<StickerPackModel> get stickerPackModels => this.collection();
}

const StickerPackModelSchema = CollectionSchema(
  name: r'StickerPackModel',
  id: -5282790351227735557,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'canSendToWhatsApp': PropertySchema(
      id: 1,
      name: r'canSendToWhatsApp',
      type: IsarType.bool,
    ),
    r'coverImagePath': PropertySchema(
      id: 2,
      name: r'coverImagePath',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'filledCount': PropertySchema(
      id: 4,
      name: r'filledCount',
      type: IsarType.long,
    ),
    r'hasCover': PropertySchema(
      id: 5,
      name: r'hasCover',
      type: IsarType.bool,
    ),
    r'identifier': PropertySchema(
      id: 6,
      name: r'identifier',
      type: IsarType.string,
    ),
    r'isFull': PropertySchema(
      id: 7,
      name: r'isFull',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'stickers': PropertySchema(
      id: 9,
      name: r'stickers',
      type: IsarType.objectList,
      target: r'StickerModel',
    )
  },
  estimateSize: _stickerPackModelEstimateSize,
  serialize: _stickerPackModelSerialize,
  deserialize: _stickerPackModelDeserialize,
  deserializeProp: _stickerPackModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'StickerModel': StickerModelSchema},
  getId: _stickerPackModelGetId,
  getLinks: _stickerPackModelGetLinks,
  attach: _stickerPackModelAttach,
  version: '3.1.0+1',
);

int _stickerPackModelEstimateSize(
  StickerPackModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.author.length * 3;
  {
    final value = object.coverImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.identifier.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.stickers.length * 3;
  {
    final offsets = allOffsets[StickerModel]!;
    for (var i = 0; i < object.stickers.length; i++) {
      final value = object.stickers[i];
      bytesCount += StickerModelSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _stickerPackModelSerialize(
  StickerPackModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeBool(offsets[1], object.canSendToWhatsApp);
  writer.writeString(offsets[2], object.coverImagePath);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.filledCount);
  writer.writeBool(offsets[5], object.hasCover);
  writer.writeString(offsets[6], object.identifier);
  writer.writeBool(offsets[7], object.isFull);
  writer.writeString(offsets[8], object.name);
  writer.writeObjectList<StickerModel>(
    offsets[9],
    allOffsets,
    StickerModelSchema.serialize,
    object.stickers,
  );
}

StickerPackModel _stickerPackModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StickerPackModel();
  object.author = reader.readString(offsets[0]);
  object.coverImagePath = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.identifier = reader.readString(offsets[6]);
  object.name = reader.readString(offsets[8]);
  object.stickers = reader.readObjectList<StickerModel>(
        offsets[9],
        StickerModelSchema.deserialize,
        allOffsets,
        StickerModel(),
      ) ??
      [];
  return object;
}

P _stickerPackModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readObjectList<StickerModel>(
            offset,
            StickerModelSchema.deserialize,
            allOffsets,
            StickerModel(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stickerPackModelGetId(StickerPackModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stickerPackModelGetLinks(StickerPackModel object) {
  return [];
}

void _stickerPackModelAttach(
    IsarCollection<dynamic> col, Id id, StickerPackModel object) {
  object.id = id;
}

extension StickerPackModelQueryWhereSort
    on QueryBuilder<StickerPackModel, StickerPackModel, QWhere> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StickerPackModelQueryWhere
    on QueryBuilder<StickerPackModel, StickerPackModel, QWhereClause> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhereClause>
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

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StickerPackModelQueryFilter
    on QueryBuilder<StickerPackModel, StickerPackModel, QFilterCondition> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      canSendToWhatsAppEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canSendToWhatsApp',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverImagePath',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverImagePath',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      coverImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      filledCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      filledCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      filledCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      filledCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filledCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      hasCoverEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasCover',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'identifier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'identifier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identifier',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      identifierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'identifier',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      isFullEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFull',
        value: value,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stickers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension StickerPackModelQueryObject
    on QueryBuilder<StickerPackModel, StickerPackModel, QFilterCondition> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterFilterCondition>
      stickersElement(FilterQuery<StickerModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'stickers');
    });
  }
}

extension StickerPackModelQueryLinks
    on QueryBuilder<StickerPackModel, StickerPackModel, QFilterCondition> {}

extension StickerPackModelQuerySortBy
    on QueryBuilder<StickerPackModel, StickerPackModel, QSortBy> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCanSendToWhatsApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canSendToWhatsApp', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCanSendToWhatsAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canSendToWhatsApp', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCoverImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImagePath', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCoverImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImagePath', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByFilledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filledCount', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByFilledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filledCount', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByHasCover() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCover', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByHasCoverDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCover', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByIsFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFull', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByIsFullDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFull', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension StickerPackModelQuerySortThenBy
    on QueryBuilder<StickerPackModel, StickerPackModel, QSortThenBy> {
  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCanSendToWhatsApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canSendToWhatsApp', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCanSendToWhatsAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canSendToWhatsApp', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCoverImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImagePath', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCoverImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImagePath', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByFilledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filledCount', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByFilledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filledCount', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByHasCover() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCover', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByHasCoverDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCover', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByIsFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFull', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByIsFullDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFull', Sort.desc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension StickerPackModelQueryWhereDistinct
    on QueryBuilder<StickerPackModel, StickerPackModel, QDistinct> {
  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByCanSendToWhatsApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canSendToWhatsApp');
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByCoverImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByFilledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filledCount');
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByHasCover() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCover');
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByIdentifier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identifier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct>
      distinctByIsFull() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFull');
    });
  }

  QueryBuilder<StickerPackModel, StickerPackModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension StickerPackModelQueryProperty
    on QueryBuilder<StickerPackModel, StickerPackModel, QQueryProperty> {
  QueryBuilder<StickerPackModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StickerPackModel, String, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<StickerPackModel, bool, QQueryOperations>
      canSendToWhatsAppProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canSendToWhatsApp');
    });
  }

  QueryBuilder<StickerPackModel, String?, QQueryOperations>
      coverImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImagePath');
    });
  }

  QueryBuilder<StickerPackModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StickerPackModel, int, QQueryOperations> filledCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filledCount');
    });
  }

  QueryBuilder<StickerPackModel, bool, QQueryOperations> hasCoverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCover');
    });
  }

  QueryBuilder<StickerPackModel, String, QQueryOperations>
      identifierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identifier');
    });
  }

  QueryBuilder<StickerPackModel, bool, QQueryOperations> isFullProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFull');
    });
  }

  QueryBuilder<StickerPackModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StickerPackModel, List<StickerModel>, QQueryOperations>
      stickersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickers');
    });
  }
}
