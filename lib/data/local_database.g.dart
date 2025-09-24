// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $SpacesTableTable extends SpacesTable
    with TableInfo<$SpacesTableTable, SpaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionDxMeta =
      const VerificationMeta('positionDx');
  @override
  late final GeneratedColumn<double> positionDx = GeneratedColumn<double>(
      'position_dx', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _positionDyMeta =
      const VerificationMeta('positionDy');
  @override
  late final GeneratedColumn<double> positionDy = GeneratedColumn<double>(
      'position_dy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sizeWidthMeta =
      const VerificationMeta('sizeWidth');
  @override
  late final GeneratedColumn<double> sizeWidth = GeneratedColumn<double>(
      'size_width', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sizeHeightMeta =
      const VerificationMeta('sizeHeight');
  @override
  late final GeneratedColumn<double> sizeHeight = GeneratedColumn<double>(
      'size_height', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'NULL REFERENCES spaces(id) ON DELETE CASCADE');
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        positionDx,
        positionDy,
        sizeWidth,
        sizeHeight,
        parentId,
        updatedAt,
        version,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(Insertable<SpaceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position_dx')) {
      context.handle(
          _positionDxMeta,
          positionDx.isAcceptableOrUnknown(
              data['position_dx']!, _positionDxMeta));
    } else if (isInserting) {
      context.missing(_positionDxMeta);
    }
    if (data.containsKey('position_dy')) {
      context.handle(
          _positionDyMeta,
          positionDy.isAcceptableOrUnknown(
              data['position_dy']!, _positionDyMeta));
    } else if (isInserting) {
      context.missing(_positionDyMeta);
    }
    if (data.containsKey('size_width')) {
      context.handle(_sizeWidthMeta,
          sizeWidth.isAcceptableOrUnknown(data['size_width']!, _sizeWidthMeta));
    } else if (isInserting) {
      context.missing(_sizeWidthMeta);
    }
    if (data.containsKey('size_height')) {
      context.handle(
          _sizeHeightMeta,
          sizeHeight.isAcceptableOrUnknown(
              data['size_height']!, _sizeHeightMeta));
    } else if (isInserting) {
      context.missing(_sizeHeightMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      positionDx: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}position_dx'])!,
      positionDy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}position_dy'])!,
      sizeWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}size_width'])!,
      sizeHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}size_height'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $SpacesTableTable createAlias(String alias) {
    return $SpacesTableTable(attachedDatabase, alias);
  }
}

class SpaceRow extends DataClass implements Insertable<SpaceRow> {
  final String id;
  final String name;
  final double positionDx;
  final double positionDy;
  final double sizeWidth;
  final double sizeHeight;
  final String? parentId;
  final int updatedAt;
  final int version;
  final bool isDeleted;
  const SpaceRow(
      {required this.id,
      required this.name,
      required this.positionDx,
      required this.positionDy,
      required this.sizeWidth,
      required this.sizeHeight,
      this.parentId,
      required this.updatedAt,
      required this.version,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['position_dx'] = Variable<double>(positionDx);
    map['position_dy'] = Variable<double>(positionDy);
    map['size_width'] = Variable<double>(sizeWidth);
    map['size_height'] = Variable<double>(sizeHeight);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SpacesTableCompanion toCompanion(bool nullToAbsent) {
    return SpacesTableCompanion(
      id: Value(id),
      name: Value(name),
      positionDx: Value(positionDx),
      positionDy: Value(positionDy),
      sizeWidth: Value(sizeWidth),
      sizeHeight: Value(sizeHeight),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory SpaceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      positionDx: serializer.fromJson<double>(json['positionDx']),
      positionDy: serializer.fromJson<double>(json['positionDy']),
      sizeWidth: serializer.fromJson<double>(json['sizeWidth']),
      sizeHeight: serializer.fromJson<double>(json['sizeHeight']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'positionDx': serializer.toJson<double>(positionDx),
      'positionDy': serializer.toJson<double>(positionDy),
      'sizeWidth': serializer.toJson<double>(sizeWidth),
      'sizeHeight': serializer.toJson<double>(sizeHeight),
      'parentId': serializer.toJson<String?>(parentId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SpaceRow copyWith(
          {String? id,
          String? name,
          double? positionDx,
          double? positionDy,
          double? sizeWidth,
          double? sizeHeight,
          Value<String?> parentId = const Value.absent(),
          int? updatedAt,
          int? version,
          bool? isDeleted}) =>
      SpaceRow(
        id: id ?? this.id,
        name: name ?? this.name,
        positionDx: positionDx ?? this.positionDx,
        positionDy: positionDy ?? this.positionDy,
        sizeWidth: sizeWidth ?? this.sizeWidth,
        sizeHeight: sizeHeight ?? this.sizeHeight,
        parentId: parentId.present ? parentId.value : this.parentId,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  @override
  String toString() {
    return (StringBuffer('SpaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('positionDx: $positionDx, ')
          ..write('positionDy: $positionDy, ')
          ..write('sizeWidth: $sizeWidth, ')
          ..write('sizeHeight: $sizeHeight, ')
          ..write('parentId: $parentId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, positionDx, positionDy, sizeWidth,
      sizeHeight, parentId, updatedAt, version, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.positionDx == this.positionDx &&
          other.positionDy == this.positionDy &&
          other.sizeWidth == this.sizeWidth &&
          other.sizeHeight == this.sizeHeight &&
          other.parentId == this.parentId &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class SpacesTableCompanion extends UpdateCompanion<SpaceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> positionDx;
  final Value<double> positionDy;
  final Value<double> sizeWidth;
  final Value<double> sizeHeight;
  final Value<String?> parentId;
  final Value<int> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const SpacesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.positionDx = const Value.absent(),
    this.positionDy = const Value.absent(),
    this.sizeWidth = const Value.absent(),
    this.sizeHeight = const Value.absent(),
    this.parentId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesTableCompanion.insert({
    required String id,
    required String name,
    required double positionDx,
    required double positionDy,
    required double sizeWidth,
    required double sizeHeight,
    this.parentId = const Value.absent(),
    required int updatedAt,
    required int version,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        positionDx = Value(positionDx),
        positionDy = Value(positionDy),
        sizeWidth = Value(sizeWidth),
        sizeHeight = Value(sizeHeight),
        updatedAt = Value(updatedAt),
        version = Value(version);
  static Insertable<SpaceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? positionDx,
    Expression<double>? positionDy,
    Expression<double>? sizeWidth,
    Expression<double>? sizeHeight,
    Expression<String>? parentId,
    Expression<int>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (positionDx != null) 'position_dx': positionDx,
      if (positionDy != null) 'position_dy': positionDy,
      if (sizeWidth != null) 'size_width': sizeWidth,
      if (sizeHeight != null) 'size_height': sizeHeight,
      if (parentId != null) 'parent_id': parentId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? positionDx,
      Value<double>? positionDy,
      Value<double>? sizeWidth,
      Value<double>? sizeHeight,
      Value<String?>? parentId,
      Value<int>? updatedAt,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return SpacesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      positionDx: positionDx ?? this.positionDx,
      positionDy: positionDy ?? this.positionDy,
      sizeWidth: sizeWidth ?? this.sizeWidth,
      sizeHeight: sizeHeight ?? this.sizeHeight,
      parentId: parentId ?? this.parentId,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (positionDx.present) {
      map['position_dx'] = Variable<double>(positionDx.value);
    }
    if (positionDy.present) {
      map['position_dy'] = Variable<double>(positionDy.value);
    }
    if (sizeWidth.present) {
      map['size_width'] = Variable<double>(sizeWidth.value);
    }
    if (sizeHeight.present) {
      map['size_height'] = Variable<double>(sizeHeight.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('positionDx: $positionDx, ')
          ..write('positionDy: $positionDy, ')
          ..write('sizeWidth: $sizeWidth, ')
          ..write('sizeHeight: $sizeHeight, ')
          ..write('parentId: $parentId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTableTable extends ItemsTable
    with TableInfo<$ItemsTableTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES spaces(id) ON DELETE CASCADE NOT NULL');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationSpecificationMeta =
      const VerificationMeta('locationSpecification');
  @override
  late final GeneratedColumn<String> locationSpecification =
      GeneratedColumn<String>('location_specification', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        spaceId,
        name,
        description,
        locationSpecification,
        tagsJson,
        imagePath,
        updatedAt,
        version,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('location_specification')) {
      context.handle(
          _locationSpecificationMeta,
          locationSpecification.isAcceptableOrUnknown(
              data['location_specification']!, _locationSpecificationMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      locationSpecification: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}location_specification']),
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $ItemsTableTable createAlias(String alias) {
    return $ItemsTableTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String spaceId;
  final String name;
  final String description;
  final String? locationSpecification;
  final String? tagsJson;
  final String? imagePath;
  final int updatedAt;
  final int version;
  final bool isDeleted;
  const ItemRow(
      {required this.id,
      required this.spaceId,
      required this.name,
      required this.description,
      this.locationSpecification,
      this.tagsJson,
      this.imagePath,
      required this.updatedAt,
      required this.version,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || locationSpecification != null) {
      map['location_specification'] = Variable<String>(locationSpecification);
    }
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ItemsTableCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      name: Value(name),
      description: Value(description),
      locationSpecification: locationSpecification == null && nullToAbsent
          ? const Value.absent()
          : Value(locationSpecification),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory ItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      locationSpecification:
          serializer.fromJson<String?>(json['locationSpecification']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'locationSpecification':
          serializer.toJson<String?>(locationSpecification),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'imagePath': serializer.toJson<String?>(imagePath),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ItemRow copyWith(
          {String? id,
          String? spaceId,
          String? name,
          String? description,
          Value<String?> locationSpecification = const Value.absent(),
          Value<String?> tagsJson = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          int? updatedAt,
          int? version,
          bool? isDeleted}) =>
      ItemRow(
        id: id ?? this.id,
        spaceId: spaceId ?? this.spaceId,
        name: name ?? this.name,
        description: description ?? this.description,
        locationSpecification: locationSpecification.present
            ? locationSpecification.value
            : this.locationSpecification,
        tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('locationSpecification: $locationSpecification, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('imagePath: $imagePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      spaceId,
      name,
      description,
      locationSpecification,
      tagsJson,
      imagePath,
      updatedAt,
      version,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.name == this.name &&
          other.description == this.description &&
          other.locationSpecification == this.locationSpecification &&
          other.tagsJson == this.tagsJson &&
          other.imagePath == this.imagePath &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class ItemsTableCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> locationSpecification;
  final Value<String?> tagsJson;
  final Value<String?> imagePath;
  final Value<int> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ItemsTableCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.locationSpecification = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsTableCompanion.insert({
    required String id,
    required String spaceId,
    required String name,
    required String description,
    this.locationSpecification = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.imagePath = const Value.absent(),
    required int updatedAt,
    required int version,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        spaceId = Value(spaceId),
        name = Value(name),
        description = Value(description),
        updatedAt = Value(updatedAt),
        version = Value(version);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? locationSpecification,
    Expression<String>? tagsJson,
    Expression<String>? imagePath,
    Expression<int>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (locationSpecification != null)
        'location_specification': locationSpecification,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (imagePath != null) 'image_path': imagePath,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? spaceId,
      Value<String>? name,
      Value<String>? description,
      Value<String?>? locationSpecification,
      Value<String?>? tagsJson,
      Value<String?>? imagePath,
      Value<int>? updatedAt,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return ItemsTableCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      locationSpecification:
          locationSpecification ?? this.locationSpecification,
      tagsJson: tagsJson ?? this.tagsJson,
      imagePath: imagePath ?? this.imagePath,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (locationSpecification.present) {
      map['location_specification'] =
          Variable<String>(locationSpecification.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('locationSpecification: $locationSpecification, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('imagePath: $imagePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCurrentMeta =
      const VerificationMeta('isCurrent');
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
      'is_current', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_current" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        displayName,
        avatarUrl,
        isCurrent,
        updatedAt,
        version,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('is_current')) {
      context.handle(_isCurrentMeta,
          isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      isCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isCurrent;
  final int updatedAt;
  final int version;
  final bool isDeleted;
  const UserRow(
      {required this.id,
      required this.email,
      this.displayName,
      this.avatarUrl,
      required this.isCurrent,
      required this.updatedAt,
      required this.version,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_current'] = Variable<bool>(isCurrent);
    map['updated_at'] = Variable<int>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isCurrent: Value(isCurrent),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  UserRow copyWith(
          {String? id,
          String? email,
          Value<String?> displayName = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          bool? isCurrent,
          int? updatedAt,
          int? version,
          bool? isDeleted}) =>
      UserRow(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName.present ? displayName.value : this.displayName,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        isCurrent: isCurrent ?? this.isCurrent,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, avatarUrl, isCurrent,
      updatedAt, version, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.isCurrent == this.isCurrent &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class UsersTableCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<bool> isCurrent;
  final Value<int> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isCurrent = const Value.absent(),
    required int updatedAt,
    required int version,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        updatedAt = Value(updatedAt),
        version = Value(version);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<bool>? isCurrent,
    Expression<int>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isCurrent != null) 'is_current': isCurrent,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String?>? displayName,
      Value<String?>? avatarUrl,
      Value<bool>? isCurrent,
      Value<int>? updatedAt,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return UsersTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCurrent: isCurrent ?? this.isCurrent,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpaceMembershipsTableTable extends SpaceMembershipsTable
    with TableInfo<$SpaceMembershipsTableTable, MembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceMembershipsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES spaces(id) ON DELETE CASCADE NOT NULL');
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES users(id) ON DELETE CASCADE NOT NULL');
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _attachmentVisibilityMeta =
      const VerificationMeta('attachmentVisibility');
  @override
  late final GeneratedColumn<String> attachmentVisibility =
      GeneratedColumn<String>('attachment_visibility', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        spaceId,
        userId,
        role,
        joinedAt,
        attachmentVisibility,
        updatedAt,
        version,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_memberships';
  @override
  VerificationContext validateIntegrity(Insertable<MembershipRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    }
    if (data.containsKey('attachment_visibility')) {
      context.handle(
          _attachmentVisibilityMeta,
          attachmentVisibility.isAcceptableOrUnknown(
              data['attachment_visibility']!, _attachmentVisibilityMeta));
    } else if (isInserting) {
      context.missing(_attachmentVisibilityMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {spaceId, userId};
  @override
  MembershipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipRow(
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at']),
      attachmentVisibility: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachment_visibility'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $SpaceMembershipsTableTable createAlias(String alias) {
    return $SpaceMembershipsTableTable(attachedDatabase, alias);
  }
}

class MembershipRow extends DataClass implements Insertable<MembershipRow> {
  final String spaceId;
  final String userId;
  final String role;
  final int? joinedAt;
  final String attachmentVisibility;
  final int updatedAt;
  final int version;
  final bool isDeleted;
  const MembershipRow(
      {required this.spaceId,
      required this.userId,
      required this.role,
      this.joinedAt,
      required this.attachmentVisibility,
      required this.updatedAt,
      required this.version,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['space_id'] = Variable<String>(spaceId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<int>(joinedAt);
    }
    map['attachment_visibility'] = Variable<String>(attachmentVisibility);
    map['updated_at'] = Variable<int>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SpaceMembershipsTableCompanion toCompanion(bool nullToAbsent) {
    return SpaceMembershipsTableCompanion(
      spaceId: Value(spaceId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      attachmentVisibility: Value(attachmentVisibility),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory MembershipRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipRow(
      spaceId: serializer.fromJson<String>(json['spaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<int?>(json['joinedAt']),
      attachmentVisibility:
          serializer.fromJson<String>(json['attachmentVisibility']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'spaceId': serializer.toJson<String>(spaceId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<int?>(joinedAt),
      'attachmentVisibility': serializer.toJson<String>(attachmentVisibility),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  MembershipRow copyWith(
          {String? spaceId,
          String? userId,
          String? role,
          Value<int?> joinedAt = const Value.absent(),
          String? attachmentVisibility,
          int? updatedAt,
          int? version,
          bool? isDeleted}) =>
      MembershipRow(
        spaceId: spaceId ?? this.spaceId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
        attachmentVisibility: attachmentVisibility ?? this.attachmentVisibility,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  @override
  String toString() {
    return (StringBuffer('MembershipRow(')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('attachmentVisibility: $attachmentVisibility, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(spaceId, userId, role, joinedAt,
      attachmentVisibility, updatedAt, version, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipRow &&
          other.spaceId == this.spaceId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt &&
          other.attachmentVisibility == this.attachmentVisibility &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class SpaceMembershipsTableCompanion extends UpdateCompanion<MembershipRow> {
  final Value<String> spaceId;
  final Value<String> userId;
  final Value<String> role;
  final Value<int?> joinedAt;
  final Value<String> attachmentVisibility;
  final Value<int> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const SpaceMembershipsTableCompanion({
    this.spaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.attachmentVisibility = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpaceMembershipsTableCompanion.insert({
    required String spaceId,
    required String userId,
    required String role,
    this.joinedAt = const Value.absent(),
    required String attachmentVisibility,
    required int updatedAt,
    required int version,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : spaceId = Value(spaceId),
        userId = Value(userId),
        role = Value(role),
        attachmentVisibility = Value(attachmentVisibility),
        updatedAt = Value(updatedAt),
        version = Value(version);
  static Insertable<MembershipRow> custom({
    Expression<String>? spaceId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<int>? joinedAt,
    Expression<String>? attachmentVisibility,
    Expression<int>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (spaceId != null) 'space_id': spaceId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (attachmentVisibility != null)
        'attachment_visibility': attachmentVisibility,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpaceMembershipsTableCompanion copyWith(
      {Value<String>? spaceId,
      Value<String>? userId,
      Value<String>? role,
      Value<int?>? joinedAt,
      Value<String>? attachmentVisibility,
      Value<int>? updatedAt,
      Value<int>? version,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return SpaceMembershipsTableCompanion(
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      attachmentVisibility: attachmentVisibility ?? this.attachmentVisibility,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (attachmentVisibility.present) {
      map['attachment_visibility'] =
          Variable<String>(attachmentVisibility.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpaceMembershipsTableCompanion(')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('attachmentVisibility: $attachmentVisibility, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTableTable extends OutboxEntriesTable
    with TableInfo<$OutboxEntriesTableTable, OutboxEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        spaceId,
        operation,
        payload,
        updatedAt,
        version,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id']),
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxEntriesTableTable createAlias(String alias) {
    return $OutboxEntriesTableTable(attachedDatabase, alias);
  }
}

class OutboxEntryRow extends DataClass implements Insertable<OutboxEntryRow> {
  final int id;
  final String entityType;
  final String entityId;
  final String? spaceId;
  final String operation;
  final String payload;
  final int updatedAt;
  final int version;
  final int createdAt;
  const OutboxEntryRow(
      {required this.id,
      required this.entityType,
      required this.entityId,
      this.spaceId,
      required this.operation,
      required this.payload,
      required this.updatedAt,
      required this.version,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<int>(updatedAt);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      operation: Value(operation),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      version: Value(version),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntryRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'spaceId': serializer.toJson<String?>(spaceId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxEntryRow copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          Value<String?> spaceId = const Value.absent(),
          String? operation,
          String? payload,
          int? updatedAt,
          int? version,
          int? createdAt}) =>
      OutboxEntryRow(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        spaceId: spaceId.present ? spaceId.value : this.spaceId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('OutboxEntryRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('spaceId: $spaceId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, spaceId, operation,
      payload, updatedAt, version, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntryRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.spaceId == this.spaceId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.createdAt == this.createdAt);
}

class OutboxEntriesTableCompanion extends UpdateCompanion<OutboxEntryRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> spaceId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> updatedAt;
  final Value<int> version;
  final Value<int> createdAt;
  const OutboxEntriesTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxEntriesTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    this.spaceId = const Value.absent(),
    required String operation,
    required String payload,
    required int updatedAt,
    required int version,
    required int createdAt,
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        updatedAt = Value(updatedAt),
        version = Value(version),
        createdAt = Value(createdAt);
  static Insertable<OutboxEntryRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? spaceId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? updatedAt,
    Expression<int>? version,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (spaceId != null) 'space_id': spaceId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxEntriesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String?>? spaceId,
      Value<String>? operation,
      Value<String>? payload,
      Value<int>? updatedAt,
      Value<int>? version,
      Value<int>? createdAt}) {
    return OutboxEntriesTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      spaceId: spaceId ?? this.spaceId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('spaceId: $spaceId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  _$LocalDatabaseManager get managers => _$LocalDatabaseManager(this);
  late final $SpacesTableTable spacesTable = $SpacesTableTable(this);
  late final $ItemsTableTable itemsTable = $ItemsTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $SpaceMembershipsTableTable spaceMembershipsTable =
      $SpaceMembershipsTableTable(this);
  late final $OutboxEntriesTableTable outboxEntriesTable =
      $OutboxEntriesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        spacesTable,
        itemsTable,
        usersTable,
        spaceMembershipsTable,
        outboxEntriesTable
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('spaces',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('space_memberships', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('space_memberships', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SpacesTableTableInsertCompanionBuilder = SpacesTableCompanion
    Function({
  required String id,
  required String name,
  required double positionDx,
  required double positionDy,
  required double sizeWidth,
  required double sizeHeight,
  Value<String?> parentId,
  required int updatedAt,
  required int version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$SpacesTableTableUpdateCompanionBuilder = SpacesTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<double> positionDx,
  Value<double> positionDy,
  Value<double> sizeWidth,
  Value<double> sizeHeight,
  Value<String?> parentId,
  Value<int> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$SpacesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SpacesTableTable,
    SpaceRow,
    $$SpacesTableTableFilterComposer,
    $$SpacesTableTableOrderingComposer,
    $$SpacesTableTableProcessedTableManager,
    $$SpacesTableTableInsertCompanionBuilder,
    $$SpacesTableTableUpdateCompanionBuilder> {
  $$SpacesTableTableTableManager(_$LocalDatabase db, $SpacesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SpacesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SpacesTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SpacesTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> positionDx = const Value.absent(),
            Value<double> positionDy = const Value.absent(),
            Value<double> sizeWidth = const Value.absent(),
            Value<double> sizeHeight = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesTableCompanion(
            id: id,
            name: name,
            positionDx: positionDx,
            positionDy: positionDy,
            sizeWidth: sizeWidth,
            sizeHeight: sizeHeight,
            parentId: parentId,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String name,
            required double positionDx,
            required double positionDy,
            required double sizeWidth,
            required double sizeHeight,
            Value<String?> parentId = const Value.absent(),
            required int updatedAt,
            required int version,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpacesTableCompanion.insert(
            id: id,
            name: name,
            positionDx: positionDx,
            positionDy: positionDy,
            sizeWidth: sizeWidth,
            sizeHeight: sizeHeight,
            parentId: parentId,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
        ));
}

class $$SpacesTableTableProcessedTableManager extends ProcessedTableManager<
    _$LocalDatabase,
    $SpacesTableTable,
    SpaceRow,
    $$SpacesTableTableFilterComposer,
    $$SpacesTableTableOrderingComposer,
    $$SpacesTableTableProcessedTableManager,
    $$SpacesTableTableInsertCompanionBuilder,
    $$SpacesTableTableUpdateCompanionBuilder> {
  $$SpacesTableTableProcessedTableManager(super.$state);
}

class $$SpacesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $SpacesTableTable> {
  $$SpacesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get positionDx => $state.composableBuilder(
      column: $state.table.positionDx,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get positionDy => $state.composableBuilder(
      column: $state.table.positionDy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get sizeWidth => $state.composableBuilder(
      column: $state.table.sizeWidth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get sizeHeight => $state.composableBuilder(
      column: $state.table.sizeHeight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parentId => $state.composableBuilder(
      column: $state.table.parentId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter itemsTableRefs(
      ComposableFilter Function($$ItemsTableTableFilterComposer f) f) {
    final $$ItemsTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.itemsTable,
        getReferencedColumn: (t) => t.spaceId,
        builder: (joinBuilder, parentComposers) =>
            $$ItemsTableTableFilterComposer(ComposerState($state.db,
                $state.db.itemsTable, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter spaceMembershipsTableRefs(
      ComposableFilter Function($$SpaceMembershipsTableTableFilterComposer f)
          f) {
    final $$SpaceMembershipsTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.spaceMembershipsTable,
            getReferencedColumn: (t) => t.spaceId,
            builder: (joinBuilder, parentComposers) =>
                $$SpaceMembershipsTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.spaceMembershipsTable,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$SpacesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $SpacesTableTable> {
  $$SpacesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get positionDx => $state.composableBuilder(
      column: $state.table.positionDx,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get positionDy => $state.composableBuilder(
      column: $state.table.positionDy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get sizeWidth => $state.composableBuilder(
      column: $state.table.sizeWidth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get sizeHeight => $state.composableBuilder(
      column: $state.table.sizeHeight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parentId => $state.composableBuilder(
      column: $state.table.parentId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ItemsTableTableInsertCompanionBuilder = ItemsTableCompanion Function({
  required String id,
  required String spaceId,
  required String name,
  required String description,
  Value<String?> locationSpecification,
  Value<String?> tagsJson,
  Value<String?> imagePath,
  required int updatedAt,
  required int version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$ItemsTableTableUpdateCompanionBuilder = ItemsTableCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> name,
  Value<String> description,
  Value<String?> locationSpecification,
  Value<String?> tagsJson,
  Value<String?> imagePath,
  Value<int> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$ItemsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ItemsTableTable,
    ItemRow,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableProcessedTableManager,
    $$ItemsTableTableInsertCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder> {
  $$ItemsTableTableTableManager(_$LocalDatabase db, $ItemsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemsTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ItemsTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> spaceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> locationSpecification = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsTableCompanion(
            id: id,
            spaceId: spaceId,
            name: name,
            description: description,
            locationSpecification: locationSpecification,
            tagsJson: tagsJson,
            imagePath: imagePath,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String spaceId,
            required String name,
            required String description,
            Value<String?> locationSpecification = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            required int updatedAt,
            required int version,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsTableCompanion.insert(
            id: id,
            spaceId: spaceId,
            name: name,
            description: description,
            locationSpecification: locationSpecification,
            tagsJson: tagsJson,
            imagePath: imagePath,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
        ));
}

class $$ItemsTableTableProcessedTableManager extends ProcessedTableManager<
    _$LocalDatabase,
    $ItemsTableTable,
    ItemRow,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableProcessedTableManager,
    $$ItemsTableTableInsertCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder> {
  $$ItemsTableTableProcessedTableManager(super.$state);
}

class $$ItemsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $ItemsTableTable> {
  $$ItemsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get locationSpecification => $state.composableBuilder(
      column: $state.table.locationSpecification,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tagsJson => $state.composableBuilder(
      column: $state.table.tagsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$SpacesTableTableFilterComposer get spaceId {
    final $$SpacesTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $state.db.spacesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SpacesTableTableFilterComposer(ComposerState($state.db,
                $state.db.spacesTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ItemsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $ItemsTableTable> {
  $$ItemsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get locationSpecification => $state.composableBuilder(
      column: $state.table.locationSpecification,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tagsJson => $state.composableBuilder(
      column: $state.table.tagsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$SpacesTableTableOrderingComposer get spaceId {
    final $$SpacesTableTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $state.db.spacesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SpacesTableTableOrderingComposer(ComposerState($state.db,
                $state.db.spacesTable, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$UsersTableTableInsertCompanionBuilder = UsersTableCompanion Function({
  required String id,
  required String email,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  Value<bool> isCurrent,
  required int updatedAt,
  required int version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  Value<bool> isCurrent,
  Value<int> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$UsersTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UsersTableTable,
    UserRow,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableProcessedTableManager,
    $$UsersTableTableInsertCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder> {
  $$UsersTableTableTableManager(_$LocalDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsersTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsersTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$UsersTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isCurrent = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersTableCompanion(
            id: id,
            email: email,
            displayName: displayName,
            avatarUrl: avatarUrl,
            isCurrent: isCurrent,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String email,
            Value<String?> displayName = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isCurrent = const Value.absent(),
            required int updatedAt,
            required int version,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersTableCompanion.insert(
            id: id,
            email: email,
            displayName: displayName,
            avatarUrl: avatarUrl,
            isCurrent: isCurrent,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
        ));
}

class $$UsersTableTableProcessedTableManager extends ProcessedTableManager<
    _$LocalDatabase,
    $UsersTableTable,
    UserRow,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableProcessedTableManager,
    $$UsersTableTableInsertCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder> {
  $$UsersTableTableProcessedTableManager(super.$state);
}

class $$UsersTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCurrent => $state.composableBuilder(
      column: $state.table.isCurrent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter spaceMembershipsTableRefs(
      ComposableFilter Function($$SpaceMembershipsTableTableFilterComposer f)
          f) {
    final $$SpaceMembershipsTableTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.spaceMembershipsTable,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder, parentComposers) =>
                $$SpaceMembershipsTableTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.spaceMembershipsTable,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get email => $state.composableBuilder(
      column: $state.table.email,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCurrent => $state.composableBuilder(
      column: $state.table.isCurrent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SpaceMembershipsTableTableInsertCompanionBuilder
    = SpaceMembershipsTableCompanion Function({
  required String spaceId,
  required String userId,
  required String role,
  Value<int?> joinedAt,
  required String attachmentVisibility,
  required int updatedAt,
  required int version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$SpaceMembershipsTableTableUpdateCompanionBuilder
    = SpaceMembershipsTableCompanion Function({
  Value<String> spaceId,
  Value<String> userId,
  Value<String> role,
  Value<int?> joinedAt,
  Value<String> attachmentVisibility,
  Value<int> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$SpaceMembershipsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SpaceMembershipsTableTable,
    MembershipRow,
    $$SpaceMembershipsTableTableFilterComposer,
    $$SpaceMembershipsTableTableOrderingComposer,
    $$SpaceMembershipsTableTableProcessedTableManager,
    $$SpaceMembershipsTableTableInsertCompanionBuilder,
    $$SpaceMembershipsTableTableUpdateCompanionBuilder> {
  $$SpaceMembershipsTableTableTableManager(
      _$LocalDatabase db, $SpaceMembershipsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SpaceMembershipsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$SpaceMembershipsTableTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SpaceMembershipsTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> spaceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int?> joinedAt = const Value.absent(),
            Value<String> attachmentVisibility = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpaceMembershipsTableCompanion(
            spaceId: spaceId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            attachmentVisibility: attachmentVisibility,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String spaceId,
            required String userId,
            required String role,
            Value<int?> joinedAt = const Value.absent(),
            required String attachmentVisibility,
            required int updatedAt,
            required int version,
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpaceMembershipsTableCompanion.insert(
            spaceId: spaceId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            attachmentVisibility: attachmentVisibility,
            updatedAt: updatedAt,
            version: version,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
        ));
}

class $$SpaceMembershipsTableTableProcessedTableManager
    extends ProcessedTableManager<
        _$LocalDatabase,
        $SpaceMembershipsTableTable,
        MembershipRow,
        $$SpaceMembershipsTableTableFilterComposer,
        $$SpaceMembershipsTableTableOrderingComposer,
        $$SpaceMembershipsTableTableProcessedTableManager,
        $$SpaceMembershipsTableTableInsertCompanionBuilder,
        $$SpaceMembershipsTableTableUpdateCompanionBuilder> {
  $$SpaceMembershipsTableTableProcessedTableManager(super.$state);
}

class $$SpaceMembershipsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $SpaceMembershipsTableTable> {
  $$SpaceMembershipsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get joinedAt => $state.composableBuilder(
      column: $state.table.joinedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get attachmentVisibility => $state.composableBuilder(
      column: $state.table.attachmentVisibility,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$SpacesTableTableFilterComposer get spaceId {
    final $$SpacesTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $state.db.spacesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SpacesTableTableFilterComposer(ComposerState($state.db,
                $state.db.spacesTable, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableTableFilterComposer get userId {
    final $$UsersTableTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.usersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UsersTableTableFilterComposer(ComposerState($state.db,
                $state.db.usersTable, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$SpaceMembershipsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $SpaceMembershipsTableTable> {
  $$SpaceMembershipsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get joinedAt => $state.composableBuilder(
      column: $state.table.joinedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get attachmentVisibility => $state.composableBuilder(
      column: $state.table.attachmentVisibility,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$SpacesTableTableOrderingComposer get spaceId {
    final $$SpacesTableTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.spaceId,
        referencedTable: $state.db.spacesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SpacesTableTableOrderingComposer(ComposerState($state.db,
                $state.db.spacesTable, joinBuilder, parentComposers)));
    return composer;
  }

  $$UsersTableTableOrderingComposer get userId {
    final $$UsersTableTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $state.db.usersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$UsersTableTableOrderingComposer(ComposerState($state.db,
                $state.db.usersTable, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$OutboxEntriesTableTableInsertCompanionBuilder
    = OutboxEntriesTableCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  Value<String?> spaceId,
  required String operation,
  required String payload,
  required int updatedAt,
  required int version,
  required int createdAt,
});
typedef $$OutboxEntriesTableTableUpdateCompanionBuilder
    = OutboxEntriesTableCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String?> spaceId,
  Value<String> operation,
  Value<String> payload,
  Value<int> updatedAt,
  Value<int> version,
  Value<int> createdAt,
});

class $$OutboxEntriesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $OutboxEntriesTableTable,
    OutboxEntryRow,
    $$OutboxEntriesTableTableFilterComposer,
    $$OutboxEntriesTableTableOrderingComposer,
    $$OutboxEntriesTableTableProcessedTableManager,
    $$OutboxEntriesTableTableInsertCompanionBuilder,
    $$OutboxEntriesTableTableUpdateCompanionBuilder> {
  $$OutboxEntriesTableTableTableManager(
      _$LocalDatabase db, $OutboxEntriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OutboxEntriesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$OutboxEntriesTableTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$OutboxEntriesTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String?> spaceId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              OutboxEntriesTableCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            spaceId: spaceId,
            operation: operation,
            payload: payload,
            updatedAt: updatedAt,
            version: version,
            createdAt: createdAt,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            Value<String?> spaceId = const Value.absent(),
            required String operation,
            required String payload,
            required int updatedAt,
            required int version,
            required int createdAt,
          }) =>
              OutboxEntriesTableCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            spaceId: spaceId,
            operation: operation,
            payload: payload,
            updatedAt: updatedAt,
            version: version,
            createdAt: createdAt,
          ),
        ));
}

class $$OutboxEntriesTableTableProcessedTableManager
    extends ProcessedTableManager<
        _$LocalDatabase,
        $OutboxEntriesTableTable,
        OutboxEntryRow,
        $$OutboxEntriesTableTableFilterComposer,
        $$OutboxEntriesTableTableOrderingComposer,
        $$OutboxEntriesTableTableProcessedTableManager,
        $$OutboxEntriesTableTableInsertCompanionBuilder,
        $$OutboxEntriesTableTableUpdateCompanionBuilder> {
  $$OutboxEntriesTableTableProcessedTableManager(super.$state);
}

class $$OutboxEntriesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $OutboxEntriesTableTable> {
  $$OutboxEntriesTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get spaceId => $state.composableBuilder(
      column: $state.table.spaceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OutboxEntriesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $OutboxEntriesTableTable> {
  $$OutboxEntriesTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityType => $state.composableBuilder(
      column: $state.table.entityType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get entityId => $state.composableBuilder(
      column: $state.table.entityId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get spaceId => $state.composableBuilder(
      column: $state.table.spaceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$LocalDatabaseManager {
  final _$LocalDatabase _db;
  _$LocalDatabaseManager(this._db);
  $$SpacesTableTableTableManager get spacesTable =>
      $$SpacesTableTableTableManager(_db, _db.spacesTable);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db, _db.itemsTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$SpaceMembershipsTableTableTableManager get spaceMembershipsTable =>
      $$SpaceMembershipsTableTableTableManager(_db, _db.spaceMembershipsTable);
  $$OutboxEntriesTableTableTableManager get outboxEntriesTable =>
      $$OutboxEntriesTableTableTableManager(_db, _db.outboxEntriesTable);
}
