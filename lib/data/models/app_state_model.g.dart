// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppStateModelCollection on Isar {
  IsarCollection<AppStateModel> get appStateModels => this.collection();
}

const AppStateModelSchema = CollectionSchema(
  name: r'AppStateModel',
  id: -6573728095823601529,
  properties: {
    r'lastModified': PropertySchema(
      id: 0,
      name: r'lastModified',
      type: IsarType.dateTime,
    ),
    r'onboardingCompleted': PropertySchema(
      id: 1,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    ),
    r'preferredLocale': PropertySchema(
      id: 2,
      name: r'preferredLocale',
      type: IsarType.string,
    )
  },
  estimateSize: _appStateModelEstimateSize,
  serialize: _appStateModelSerialize,
  deserialize: _appStateModelDeserialize,
  deserializeProp: _appStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appStateModelGetId,
  getLinks: _appStateModelGetLinks,
  attach: _appStateModelAttach,
  version: '3.1.0+1',
);

int _appStateModelEstimateSize(
  AppStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.preferredLocale;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appStateModelSerialize(
  AppStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastModified);
  writer.writeBool(offsets[1], object.onboardingCompleted);
  writer.writeString(offsets[2], object.preferredLocale);
}

AppStateModel _appStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppStateModel();
  object.id = id;
  object.lastModified = reader.readDateTimeOrNull(offsets[0]);
  object.onboardingCompleted = reader.readBool(offsets[1]);
  object.preferredLocale = reader.readStringOrNull(offsets[2]);
  return object;
}

P _appStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appStateModelGetId(AppStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appStateModelGetLinks(AppStateModel object) {
  return [];
}

void _appStateModelAttach(
    IsarCollection<dynamic> col, Id id, AppStateModel object) {
  object.id = id;
}

extension AppStateModelQueryWhereSort
    on QueryBuilder<AppStateModel, AppStateModel, QWhere> {
  QueryBuilder<AppStateModel, AppStateModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppStateModelQueryWhere
    on QueryBuilder<AppStateModel, AppStateModel, QWhereClause> {
  QueryBuilder<AppStateModel, AppStateModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AppStateModel, AppStateModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterWhereClause> idBetween(
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

extension AppStateModelQueryFilter
    on QueryBuilder<AppStateModel, AppStateModel, QFilterCondition> {
  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
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

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastModified',
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastModified',
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      lastModifiedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preferredLocale',
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preferredLocale',
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preferredLocale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preferredLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preferredLocale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLocale',
        value: '',
      ));
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterFilterCondition>
      preferredLocaleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preferredLocale',
        value: '',
      ));
    });
  }
}

extension AppStateModelQueryObject
    on QueryBuilder<AppStateModel, AppStateModel, QFilterCondition> {}

extension AppStateModelQueryLinks
    on QueryBuilder<AppStateModel, AppStateModel, QFilterCondition> {}

extension AppStateModelQuerySortBy
    on QueryBuilder<AppStateModel, AppStateModel, QSortBy> {
  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByPreferredLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLocale', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      sortByPreferredLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLocale', Sort.desc);
    });
  }
}

extension AppStateModelQuerySortThenBy
    on QueryBuilder<AppStateModel, AppStateModel, QSortThenBy> {
  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByPreferredLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLocale', Sort.asc);
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QAfterSortBy>
      thenByPreferredLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLocale', Sort.desc);
    });
  }
}

extension AppStateModelQueryWhereDistinct
    on QueryBuilder<AppStateModel, AppStateModel, QDistinct> {
  QueryBuilder<AppStateModel, AppStateModel, QDistinct>
      distinctByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModified');
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QDistinct>
      distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }

  QueryBuilder<AppStateModel, AppStateModel, QDistinct>
      distinctByPreferredLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredLocale',
          caseSensitive: caseSensitive);
    });
  }
}

extension AppStateModelQueryProperty
    on QueryBuilder<AppStateModel, AppStateModel, QQueryProperty> {
  QueryBuilder<AppStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppStateModel, DateTime?, QQueryOperations>
      lastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModified');
    });
  }

  QueryBuilder<AppStateModel, bool, QQueryOperations>
      onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }

  QueryBuilder<AppStateModel, String?, QQueryOperations>
      preferredLocaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredLocale');
    });
  }
}
