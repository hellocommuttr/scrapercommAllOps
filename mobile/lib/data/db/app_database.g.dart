// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OperatorsTable extends Operators with TableInfo<$OperatorsTable, Operator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeCountMeta = const VerificationMeta('routeCount');
  @override
  late final GeneratedColumn<int> routeCount = GeneratedColumn<int>(
    'route_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [code, name, kind, routeCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operators';
  @override
  VerificationContext validateIntegrity(Insertable<Operator> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('route_count')) {
      context.handle(_routeCountMeta, routeCount.isAcceptableOrUnknown(data['route_count']!, _routeCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Operator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Operator(
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      routeCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}route_count'])!,
    );
  }

  @override
  $OperatorsTable createAlias(String alias) {
    return $OperatorsTable(attachedDatabase, alias);
  }
}

class Operator extends DataClass implements Insertable<Operator> {
  final String code;
  final String name;
  final String kind;
  final int routeCount;
  const Operator({required this.code, required this.name, required this.kind, required this.routeCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['route_count'] = Variable<int>(routeCount);
    return map;
  }

  OperatorsCompanion toCompanion(bool nullToAbsent) {
    return OperatorsCompanion(code: Value(code), name: Value(name), kind: Value(kind), routeCount: Value(routeCount));
  }

  factory Operator.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Operator(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      routeCount: serializer.fromJson<int>(json['routeCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'routeCount': serializer.toJson<int>(routeCount),
    };
  }

  Operator copyWith({String? code, String? name, String? kind, int? routeCount}) => Operator(
    code: code ?? this.code,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    routeCount: routeCount ?? this.routeCount,
  );
  Operator copyWithCompanion(OperatorsCompanion data) {
    return Operator(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      routeCount: data.routeCount.present ? data.routeCount.value : this.routeCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Operator(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('routeCount: $routeCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, kind, routeCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Operator &&
          other.code == this.code &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.routeCount == this.routeCount);
}

class OperatorsCompanion extends UpdateCompanion<Operator> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> routeCount;
  final Value<int> rowid;
  const OperatorsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.routeCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperatorsCompanion.insert({
    required String code,
    required String name,
    required String kind,
    this.routeCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       kind = Value(kind);
  static Insertable<Operator> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? routeCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (routeCount != null) 'route_count': routeCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperatorsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? routeCount,
    Value<int>? rowid,
  }) {
    return OperatorsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      routeCount: routeCount ?? this.routeCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (routeCount.present) {
      map['route_count'] = Variable<int>(routeCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperatorsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('routeCount: $routeCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StopsTable extends Stops with TableInfo<$StopsTable, Stop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorCodeMeta = const VerificationMeta('operatorCode');
  @override
  late final GeneratedColumn<String> operatorCode = GeneratedColumn<String>(
    'operator_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gabs'),
  );
  static const VerificationMeta _operatorKindMeta = const VerificationMeta('operatorKind');
  @override
  late final GeneratedColumn<String> operatorKind = GeneratedColumn<String>(
    'operator_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bus'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, lat, lon, operatorCode, operatorKind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stops';
  @override
  VerificationContext validateIntegrity(Insertable<Stop> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(_lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('operator_code')) {
      context.handle(_operatorCodeMeta, operatorCode.isAcceptableOrUnknown(data['operator_code']!, _operatorCodeMeta));
    }
    if (data.containsKey('operator_kind')) {
      context.handle(_operatorKindMeta, operatorKind.isAcceptableOrUnknown(data['operator_kind']!, _operatorKindMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stop(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      operatorCode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_code'])!,
      operatorKind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_kind'])!,
    );
  }

  @override
  $StopsTable createAlias(String alias) {
    return $StopsTable(attachedDatabase, alias);
  }
}

class Stop extends DataClass implements Insertable<Stop> {
  final int id;
  final String name;
  final double lat;
  final double lon;
  final String operatorCode;
  final String operatorKind;
  const Stop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.operatorCode,
    required this.operatorKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['operator_code'] = Variable<String>(operatorCode);
    map['operator_kind'] = Variable<String>(operatorKind);
    return map;
  }

  StopsCompanion toCompanion(bool nullToAbsent) {
    return StopsCompanion(
      id: Value(id),
      name: Value(name),
      lat: Value(lat),
      lon: Value(lon),
      operatorCode: Value(operatorCode),
      operatorKind: Value(operatorKind),
    );
  }

  factory Stop.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stop(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      operatorCode: serializer.fromJson<String>(json['operatorCode']),
      operatorKind: serializer.fromJson<String>(json['operatorKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'operatorCode': serializer.toJson<String>(operatorCode),
      'operatorKind': serializer.toJson<String>(operatorKind),
    };
  }

  Stop copyWith({int? id, String? name, double? lat, double? lon, String? operatorCode, String? operatorKind}) => Stop(
    id: id ?? this.id,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    operatorCode: operatorCode ?? this.operatorCode,
    operatorKind: operatorKind ?? this.operatorKind,
  );
  Stop copyWithCompanion(StopsCompanion data) {
    return Stop(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      operatorCode: data.operatorCode.present ? data.operatorCode.value : this.operatorCode,
      operatorKind: data.operatorKind.present ? data.operatorKind.value : this.operatorKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stop(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('operatorCode: $operatorCode, ')
          ..write('operatorKind: $operatorKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lat, lon, operatorCode, operatorKind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stop &&
          other.id == this.id &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.operatorCode == this.operatorCode &&
          other.operatorKind == this.operatorKind);
}

class StopsCompanion extends UpdateCompanion<Stop> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> operatorCode;
  final Value<String> operatorKind;
  const StopsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.operatorCode = const Value.absent(),
    this.operatorKind = const Value.absent(),
  });
  StopsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double lat,
    required double lon,
    this.operatorCode = const Value.absent(),
    this.operatorKind = const Value.absent(),
  }) : name = Value(name),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<Stop> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? operatorCode,
    Expression<String>? operatorKind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (operatorCode != null) 'operator_code': operatorCode,
      if (operatorKind != null) 'operator_kind': operatorKind,
    });
  }

  StopsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? lat,
    Value<double>? lon,
    Value<String>? operatorCode,
    Value<String>? operatorKind,
  }) {
    return StopsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      operatorCode: operatorCode ?? this.operatorCode,
      operatorKind: operatorKind ?? this.operatorKind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (operatorCode.present) {
      map['operator_code'] = Variable<String>(operatorCode.value);
    }
    if (operatorKind.present) {
      map['operator_kind'] = Variable<String>(operatorKind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StopsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('operatorCode: $operatorCode, ')
          ..write('operatorKind: $operatorKind')
          ..write(')'))
        .toString();
  }
}

class $BusRoutesTable extends BusRoutes with TableInfo<$BusRoutesTable, BusRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _letterGroupMeta = const VerificationMeta('letterGroup');
  @override
  late final GeneratedColumn<String> letterGroup = GeneratedColumn<String>(
    'letter_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timetableCountMeta = const VerificationMeta('timetableCount');
  @override
  late final GeneratedColumn<int> timetableCount = GeneratedColumn<int>(
    'timetable_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _operatorCodeMeta = const VerificationMeta('operatorCode');
  @override
  late final GeneratedColumn<String> operatorCode = GeneratedColumn<String>(
    'operator_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gabs'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, origin, destination, letterGroup, timetableCount, operatorCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bus_routes';
  @override
  VerificationContext validateIntegrity(Insertable<BusRoute> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta, origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(_destinationMeta, destination.isAcceptableOrUnknown(data['destination']!, _destinationMeta));
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('letter_group')) {
      context.handle(_letterGroupMeta, letterGroup.isAcceptableOrUnknown(data['letter_group']!, _letterGroupMeta));
    } else if (isInserting) {
      context.missing(_letterGroupMeta);
    }
    if (data.containsKey('timetable_count')) {
      context.handle(
        _timetableCountMeta,
        timetableCount.isAcceptableOrUnknown(data['timetable_count']!, _timetableCountMeta),
      );
    }
    if (data.containsKey('operator_code')) {
      context.handle(_operatorCodeMeta, operatorCode.isAcceptableOrUnknown(data['operator_code']!, _operatorCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusRoute(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      origin: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      destination: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}destination'])!,
      letterGroup: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}letter_group'])!,
      timetableCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}timetable_count'])!,
      operatorCode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_code'])!,
    );
  }

  @override
  $BusRoutesTable createAlias(String alias) {
    return $BusRoutesTable(attachedDatabase, alias);
  }
}

class BusRoute extends DataClass implements Insertable<BusRoute> {
  final int id;
  final String name;
  final String origin;
  final String destination;
  final String letterGroup;
  final int timetableCount;
  final String operatorCode;
  const BusRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.letterGroup,
    required this.timetableCount,
    required this.operatorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['origin'] = Variable<String>(origin);
    map['destination'] = Variable<String>(destination);
    map['letter_group'] = Variable<String>(letterGroup);
    map['timetable_count'] = Variable<int>(timetableCount);
    map['operator_code'] = Variable<String>(operatorCode);
    return map;
  }

  BusRoutesCompanion toCompanion(bool nullToAbsent) {
    return BusRoutesCompanion(
      id: Value(id),
      name: Value(name),
      origin: Value(origin),
      destination: Value(destination),
      letterGroup: Value(letterGroup),
      timetableCount: Value(timetableCount),
      operatorCode: Value(operatorCode),
    );
  }

  factory BusRoute.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusRoute(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      origin: serializer.fromJson<String>(json['origin']),
      destination: serializer.fromJson<String>(json['destination']),
      letterGroup: serializer.fromJson<String>(json['letterGroup']),
      timetableCount: serializer.fromJson<int>(json['timetableCount']),
      operatorCode: serializer.fromJson<String>(json['operatorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'origin': serializer.toJson<String>(origin),
      'destination': serializer.toJson<String>(destination),
      'letterGroup': serializer.toJson<String>(letterGroup),
      'timetableCount': serializer.toJson<int>(timetableCount),
      'operatorCode': serializer.toJson<String>(operatorCode),
    };
  }

  BusRoute copyWith({
    int? id,
    String? name,
    String? origin,
    String? destination,
    String? letterGroup,
    int? timetableCount,
    String? operatorCode,
  }) => BusRoute(
    id: id ?? this.id,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    letterGroup: letterGroup ?? this.letterGroup,
    timetableCount: timetableCount ?? this.timetableCount,
    operatorCode: operatorCode ?? this.operatorCode,
  );
  BusRoute copyWithCompanion(BusRoutesCompanion data) {
    return BusRoute(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      origin: data.origin.present ? data.origin.value : this.origin,
      destination: data.destination.present ? data.destination.value : this.destination,
      letterGroup: data.letterGroup.present ? data.letterGroup.value : this.letterGroup,
      timetableCount: data.timetableCount.present ? data.timetableCount.value : this.timetableCount,
      operatorCode: data.operatorCode.present ? data.operatorCode.value : this.operatorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusRoute(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('destination: $destination, ')
          ..write('letterGroup: $letterGroup, ')
          ..write('timetableCount: $timetableCount, ')
          ..write('operatorCode: $operatorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, origin, destination, letterGroup, timetableCount, operatorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusRoute &&
          other.id == this.id &&
          other.name == this.name &&
          other.origin == this.origin &&
          other.destination == this.destination &&
          other.letterGroup == this.letterGroup &&
          other.timetableCount == this.timetableCount &&
          other.operatorCode == this.operatorCode);
}

class BusRoutesCompanion extends UpdateCompanion<BusRoute> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> origin;
  final Value<String> destination;
  final Value<String> letterGroup;
  final Value<int> timetableCount;
  final Value<String> operatorCode;
  const BusRoutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.origin = const Value.absent(),
    this.destination = const Value.absent(),
    this.letterGroup = const Value.absent(),
    this.timetableCount = const Value.absent(),
    this.operatorCode = const Value.absent(),
  });
  BusRoutesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String origin,
    required String destination,
    required String letterGroup,
    this.timetableCount = const Value.absent(),
    this.operatorCode = const Value.absent(),
  }) : name = Value(name),
       origin = Value(origin),
       destination = Value(destination),
       letterGroup = Value(letterGroup);
  static Insertable<BusRoute> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? origin,
    Expression<String>? destination,
    Expression<String>? letterGroup,
    Expression<int>? timetableCount,
    Expression<String>? operatorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (origin != null) 'origin': origin,
      if (destination != null) 'destination': destination,
      if (letterGroup != null) 'letter_group': letterGroup,
      if (timetableCount != null) 'timetable_count': timetableCount,
      if (operatorCode != null) 'operator_code': operatorCode,
    });
  }

  BusRoutesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? origin,
    Value<String>? destination,
    Value<String>? letterGroup,
    Value<int>? timetableCount,
    Value<String>? operatorCode,
  }) {
    return BusRoutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      letterGroup: letterGroup ?? this.letterGroup,
      timetableCount: timetableCount ?? this.timetableCount,
      operatorCode: operatorCode ?? this.operatorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (letterGroup.present) {
      map['letter_group'] = Variable<String>(letterGroup.value);
    }
    if (timetableCount.present) {
      map['timetable_count'] = Variable<int>(timetableCount.value);
    }
    if (operatorCode.present) {
      map['operator_code'] = Variable<String>(operatorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusRoutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('origin: $origin, ')
          ..write('destination: $destination, ')
          ..write('letterGroup: $letterGroup, ')
          ..write('timetableCount: $timetableCount, ')
          ..write('operatorCode: $operatorCode')
          ..write(')'))
        .toString();
  }
}

class $TimetablesTable extends Timetables with TableInfo<$TimetablesTable, Timetable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta('routeId');
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timetableNumberMeta = const VerificationMeta('timetableNumber');
  @override
  late final GeneratedColumn<String> timetableNumber = GeneratedColumn<String>(
    'timetable_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPublicHolidayMeta = const VerificationMeta('isPublicHoliday');
  @override
  late final GeneratedColumn<bool> isPublicHoliday = GeneratedColumn<bool>(
    'is_public_holiday',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_public_holiday" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta('effectiveFrom');
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveToMeta = const VerificationMeta('effectiveTo');
  @override
  late final GeneratedColumn<String> effectiveTo = GeneratedColumn<String>(
    'effective_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pdfUrlMeta = const VerificationMeta('pdfUrl');
  @override
  late final GeneratedColumn<String> pdfUrl = GeneratedColumn<String>(
    'pdf_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    timetableNumber,
    isPublicHoliday,
    effectiveFrom,
    effectiveTo,
    pdfUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetables';
  @override
  VerificationContext validateIntegrity(Insertable<Timetable> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta, routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('timetable_number')) {
      context.handle(
        _timetableNumberMeta,
        timetableNumber.isAcceptableOrUnknown(data['timetable_number']!, _timetableNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_timetableNumberMeta);
    }
    if (data.containsKey('is_public_holiday')) {
      context.handle(
        _isPublicHolidayMeta,
        isPublicHoliday.isAcceptableOrUnknown(data['is_public_holiday']!, _isPublicHolidayMeta),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(data['effective_from']!, _effectiveFromMeta),
      );
    }
    if (data.containsKey('effective_to')) {
      context.handle(_effectiveToMeta, effectiveTo.isAcceptableOrUnknown(data['effective_to']!, _effectiveToMeta));
    }
    if (data.containsKey('pdf_url')) {
      context.handle(_pdfUrlMeta, pdfUrl.isAcceptableOrUnknown(data['pdf_url']!, _pdfUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timetable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timetable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routeId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}route_id'])!,
      timetableNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timetable_number'],
      )!,
      isPublicHoliday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public_holiday'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}effective_from']),
      effectiveTo: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}effective_to']),
      pdfUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pdf_url']),
    );
  }

  @override
  $TimetablesTable createAlias(String alias) {
    return $TimetablesTable(attachedDatabase, alias);
  }
}

class Timetable extends DataClass implements Insertable<Timetable> {
  final int id;
  final int routeId;
  final String timetableNumber;
  final bool isPublicHoliday;
  final String? effectiveFrom;
  final String? effectiveTo;
  final String? pdfUrl;
  const Timetable({
    required this.id,
    required this.routeId,
    required this.timetableNumber,
    required this.isPublicHoliday,
    this.effectiveFrom,
    this.effectiveTo,
    this.pdfUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['timetable_number'] = Variable<String>(timetableNumber);
    map['is_public_holiday'] = Variable<bool>(isPublicHoliday);
    if (!nullToAbsent || effectiveFrom != null) {
      map['effective_from'] = Variable<String>(effectiveFrom);
    }
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<String>(effectiveTo);
    }
    if (!nullToAbsent || pdfUrl != null) {
      map['pdf_url'] = Variable<String>(pdfUrl);
    }
    return map;
  }

  TimetablesCompanion toCompanion(bool nullToAbsent) {
    return TimetablesCompanion(
      id: Value(id),
      routeId: Value(routeId),
      timetableNumber: Value(timetableNumber),
      isPublicHoliday: Value(isPublicHoliday),
      effectiveFrom: effectiveFrom == null && nullToAbsent ? const Value.absent() : Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent ? const Value.absent() : Value(effectiveTo),
      pdfUrl: pdfUrl == null && nullToAbsent ? const Value.absent() : Value(pdfUrl),
    );
  }

  factory Timetable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timetable(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      timetableNumber: serializer.fromJson<String>(json['timetableNumber']),
      isPublicHoliday: serializer.fromJson<bool>(json['isPublicHoliday']),
      effectiveFrom: serializer.fromJson<String?>(json['effectiveFrom']),
      effectiveTo: serializer.fromJson<String?>(json['effectiveTo']),
      pdfUrl: serializer.fromJson<String?>(json['pdfUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'timetableNumber': serializer.toJson<String>(timetableNumber),
      'isPublicHoliday': serializer.toJson<bool>(isPublicHoliday),
      'effectiveFrom': serializer.toJson<String?>(effectiveFrom),
      'effectiveTo': serializer.toJson<String?>(effectiveTo),
      'pdfUrl': serializer.toJson<String?>(pdfUrl),
    };
  }

  Timetable copyWith({
    int? id,
    int? routeId,
    String? timetableNumber,
    bool? isPublicHoliday,
    Value<String?> effectiveFrom = const Value.absent(),
    Value<String?> effectiveTo = const Value.absent(),
    Value<String?> pdfUrl = const Value.absent(),
  }) => Timetable(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    timetableNumber: timetableNumber ?? this.timetableNumber,
    isPublicHoliday: isPublicHoliday ?? this.isPublicHoliday,
    effectiveFrom: effectiveFrom.present ? effectiveFrom.value : this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
    pdfUrl: pdfUrl.present ? pdfUrl.value : this.pdfUrl,
  );
  Timetable copyWithCompanion(TimetablesCompanion data) {
    return Timetable(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      timetableNumber: data.timetableNumber.present ? data.timetableNumber.value : this.timetableNumber,
      isPublicHoliday: data.isPublicHoliday.present ? data.isPublicHoliday.value : this.isPublicHoliday,
      effectiveFrom: data.effectiveFrom.present ? data.effectiveFrom.value : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present ? data.effectiveTo.value : this.effectiveTo,
      pdfUrl: data.pdfUrl.present ? data.pdfUrl.value : this.pdfUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timetable(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('timetableNumber: $timetableNumber, ')
          ..write('isPublicHoliday: $isPublicHoliday, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('pdfUrl: $pdfUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routeId, timetableNumber, isPublicHoliday, effectiveFrom, effectiveTo, pdfUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timetable &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.timetableNumber == this.timetableNumber &&
          other.isPublicHoliday == this.isPublicHoliday &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.pdfUrl == this.pdfUrl);
}

class TimetablesCompanion extends UpdateCompanion<Timetable> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<String> timetableNumber;
  final Value<bool> isPublicHoliday;
  final Value<String?> effectiveFrom;
  final Value<String?> effectiveTo;
  final Value<String?> pdfUrl;
  const TimetablesCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.timetableNumber = const Value.absent(),
    this.isPublicHoliday = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.pdfUrl = const Value.absent(),
  });
  TimetablesCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required String timetableNumber,
    this.isPublicHoliday = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.pdfUrl = const Value.absent(),
  }) : routeId = Value(routeId),
       timetableNumber = Value(timetableNumber);
  static Insertable<Timetable> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<String>? timetableNumber,
    Expression<bool>? isPublicHoliday,
    Expression<String>? effectiveFrom,
    Expression<String>? effectiveTo,
    Expression<String>? pdfUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (timetableNumber != null) 'timetable_number': timetableNumber,
      if (isPublicHoliday != null) 'is_public_holiday': isPublicHoliday,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (pdfUrl != null) 'pdf_url': pdfUrl,
    });
  }

  TimetablesCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<String>? timetableNumber,
    Value<bool>? isPublicHoliday,
    Value<String?>? effectiveFrom,
    Value<String?>? effectiveTo,
    Value<String?>? pdfUrl,
  }) {
    return TimetablesCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      timetableNumber: timetableNumber ?? this.timetableNumber,
      isPublicHoliday: isPublicHoliday ?? this.isPublicHoliday,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (timetableNumber.present) {
      map['timetable_number'] = Variable<String>(timetableNumber.value);
    }
    if (isPublicHoliday.present) {
      map['is_public_holiday'] = Variable<bool>(isPublicHoliday.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<String>(effectiveTo.value);
    }
    if (pdfUrl.present) {
      map['pdf_url'] = Variable<String>(pdfUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetablesCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('timetableNumber: $timetableNumber, ')
          ..write('isPublicHoliday: $isPublicHoliday, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('pdfUrl: $pdfUrl')
          ..write(')'))
        .toString();
  }
}

class $TimetableNotesTable extends TimetableNotes with TableInfo<$TimetableNotesTable, TimetableNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _timetableIdMeta = const VerificationMeta('timetableId');
  @override
  late final GeneratedColumn<int> timetableId = GeneratedColumn<int>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [timetableId, code, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_notes';
  @override
  VerificationContext validateIntegrity(Insertable<TimetableNote> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timetable_id')) {
      context.handle(_timetableIdMeta, timetableId.isAcceptableOrUnknown(data['timetable_id']!, _timetableIdMeta));
    } else if (isInserting) {
      context.missing(_timetableIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {timetableId, code};
  @override
  TimetableNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableNote(
      timetableId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}timetable_id'])!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $TimetableNotesTable createAlias(String alias) {
    return $TimetableNotesTable(attachedDatabase, alias);
  }
}

class TimetableNote extends DataClass implements Insertable<TimetableNote> {
  final int timetableId;
  final String code;
  final String description;
  const TimetableNote({required this.timetableId, required this.code, required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['timetable_id'] = Variable<int>(timetableId);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    return map;
  }

  TimetableNotesCompanion toCompanion(bool nullToAbsent) {
    return TimetableNotesCompanion(timetableId: Value(timetableId), code: Value(code), description: Value(description));
  }

  factory TimetableNote.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableNote(
      timetableId: serializer.fromJson<int>(json['timetableId']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timetableId': serializer.toJson<int>(timetableId),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
    };
  }

  TimetableNote copyWith({int? timetableId, String? code, String? description}) => TimetableNote(
    timetableId: timetableId ?? this.timetableId,
    code: code ?? this.code,
    description: description ?? this.description,
  );
  TimetableNote copyWithCompanion(TimetableNotesCompanion data) {
    return TimetableNote(
      timetableId: data.timetableId.present ? data.timetableId.value : this.timetableId,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableNote(')
          ..write('timetableId: $timetableId, ')
          ..write('code: $code, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(timetableId, code, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableNote &&
          other.timetableId == this.timetableId &&
          other.code == this.code &&
          other.description == this.description);
}

class TimetableNotesCompanion extends UpdateCompanion<TimetableNote> {
  final Value<int> timetableId;
  final Value<String> code;
  final Value<String> description;
  final Value<int> rowid;
  const TimetableNotesCompanion({
    this.timetableId = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimetableNotesCompanion.insert({
    required int timetableId,
    required String code,
    required String description,
    this.rowid = const Value.absent(),
  }) : timetableId = Value(timetableId),
       code = Value(code),
       description = Value(description);
  static Insertable<TimetableNote> custom({
    Expression<int>? timetableId,
    Expression<String>? code,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (timetableId != null) 'timetable_id': timetableId,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimetableNotesCompanion copyWith({
    Value<int>? timetableId,
    Value<String>? code,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return TimetableNotesCompanion(
      timetableId: timetableId ?? this.timetableId,
      code: code ?? this.code,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (timetableId.present) {
      map['timetable_id'] = Variable<int>(timetableId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableNotesCompanion(')
          ..write('timetableId: $timetableId, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiCacheTable extends ApiCache with TableInfo<$ApiCacheTable, CachedResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta('dataVersion');
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, body, fetchedAt, lastUsedAt, dataVersion, sizeBytes, pinned];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CachedResponse> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta, cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta, fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(_lastUsedAtMeta, lastUsedAt.isAcceptableOrUnknown(data['last_used_at']!, _lastUsedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(_dataVersionMeta, dataVersion.isAcceptableOrUnknown(data['data_version']!, _dataVersionMeta));
    } else if (isInserting) {
      context.missing(_dataVersionMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta, sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta, pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CachedResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResponse(
      cacheKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      fetchedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fetched_at'])!,
      lastUsedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_used_at'])!,
      dataVersion: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data_version'])!,
      sizeBytes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      pinned: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
    );
  }

  @override
  $ApiCacheTable createAlias(String alias) {
    return $ApiCacheTable(attachedDatabase, alias);
  }
}

class CachedResponse extends DataClass implements Insertable<CachedResponse> {
  final String cacheKey;
  final String body;
  final int fetchedAt;
  final int lastUsedAt;
  final String dataVersion;
  final int sizeBytes;

  /// Pinned entries (the saved commute, planner trips) are never evicted.
  final bool pinned;
  const CachedResponse({
    required this.cacheKey,
    required this.body,
    required this.fetchedAt,
    required this.lastUsedAt,
    required this.dataVersion,
    required this.sizeBytes,
    required this.pinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['body'] = Variable<String>(body);
    map['fetched_at'] = Variable<int>(fetchedAt);
    map['last_used_at'] = Variable<int>(lastUsedAt);
    map['data_version'] = Variable<String>(dataVersion);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['pinned'] = Variable<bool>(pinned);
    return map;
  }

  ApiCacheCompanion toCompanion(bool nullToAbsent) {
    return ApiCacheCompanion(
      cacheKey: Value(cacheKey),
      body: Value(body),
      fetchedAt: Value(fetchedAt),
      lastUsedAt: Value(lastUsedAt),
      dataVersion: Value(dataVersion),
      sizeBytes: Value(sizeBytes),
      pinned: Value(pinned),
    );
  }

  factory CachedResponse.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResponse(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      body: serializer.fromJson<String>(json['body']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
      lastUsedAt: serializer.fromJson<int>(json['lastUsedAt']),
      dataVersion: serializer.fromJson<String>(json['dataVersion']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      pinned: serializer.fromJson<bool>(json['pinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'body': serializer.toJson<String>(body),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
      'lastUsedAt': serializer.toJson<int>(lastUsedAt),
      'dataVersion': serializer.toJson<String>(dataVersion),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'pinned': serializer.toJson<bool>(pinned),
    };
  }

  CachedResponse copyWith({
    String? cacheKey,
    String? body,
    int? fetchedAt,
    int? lastUsedAt,
    String? dataVersion,
    int? sizeBytes,
    bool? pinned,
  }) => CachedResponse(
    cacheKey: cacheKey ?? this.cacheKey,
    body: body ?? this.body,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    dataVersion: dataVersion ?? this.dataVersion,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    pinned: pinned ?? this.pinned,
  );
  CachedResponse copyWithCompanion(ApiCacheCompanion data) {
    return CachedResponse(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      body: data.body.present ? data.body.value : this.body,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      lastUsedAt: data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      dataVersion: data.dataVersion.present ? data.dataVersion.value : this.dataVersion,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponse(')
          ..write('cacheKey: $cacheKey, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, body, fetchedAt, lastUsedAt, dataVersion, sizeBytes, pinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResponse &&
          other.cacheKey == this.cacheKey &&
          other.body == this.body &&
          other.fetchedAt == this.fetchedAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.dataVersion == this.dataVersion &&
          other.sizeBytes == this.sizeBytes &&
          other.pinned == this.pinned);
}

class ApiCacheCompanion extends UpdateCompanion<CachedResponse> {
  final Value<String> cacheKey;
  final Value<String> body;
  final Value<int> fetchedAt;
  final Value<int> lastUsedAt;
  final Value<String> dataVersion;
  final Value<int> sizeBytes;
  final Value<bool> pinned;
  final Value<int> rowid;
  const ApiCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.body = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiCacheCompanion.insert({
    required String cacheKey,
    required String body,
    required int fetchedAt,
    required int lastUsedAt,
    required String dataVersion,
    required int sizeBytes,
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       body = Value(body),
       fetchedAt = Value(fetchedAt),
       lastUsedAt = Value(lastUsedAt),
       dataVersion = Value(dataVersion),
       sizeBytes = Value(sizeBytes);
  static Insertable<CachedResponse> custom({
    Expression<String>? cacheKey,
    Expression<String>? body,
    Expression<int>? fetchedAt,
    Expression<int>? lastUsedAt,
    Expression<String>? dataVersion,
    Expression<int>? sizeBytes,
    Expression<bool>? pinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (body != null) 'body': body,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (dataVersion != null) 'data_version': dataVersion,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (pinned != null) 'pinned': pinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiCacheCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? body,
    Value<int>? fetchedAt,
    Value<int>? lastUsedAt,
    Value<String>? dataVersion,
    Value<int>? sizeBytes,
    Value<bool>? pinned,
    Value<int>? rowid,
  }) {
    return ApiCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      body: body ?? this.body,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      dataVersion: dataVersion ?? this.dataVersion,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pinned: pinned ?? this.pinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('body: $body, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pinned: $pinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedJourneysTable extends SavedJourneys with TableInfo<$SavedJourneysTable, SavedJourney> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedJourneysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceDateMeta = const VerificationMeta('serviceDate');
  @override
  late final GeneratedColumn<String> serviceDate = GeneratedColumn<String>(
    'service_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromEndpointMeta = const VerificationMeta('fromEndpoint');
  @override
  late final GeneratedColumn<String> fromEndpoint = GeneratedColumn<String>(
    'from_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toEndpointMeta = const VerificationMeta('toEndpoint');
  @override
  late final GeneratedColumn<String> toEndpoint = GeneratedColumn<String>(
    'to_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeLabelMeta = const VerificationMeta('routeLabel');
  @override
  late final GeneratedColumn<String> routeLabel = GeneratedColumn<String>(
    'route_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorCodeMeta = const VerificationMeta('operatorCode');
  @override
  late final GeneratedColumn<String> operatorCode = GeneratedColumn<String>(
    'operator_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gabs'),
  );
  static const VerificationMeta _operatorNameMeta = const VerificationMeta('operatorName');
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
    'operator_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Golden Arrow Buses'),
  );
  static const VerificationMeta _operatorKindMeta = const VerificationMeta('operatorKind');
  @override
  late final GeneratedColumn<String> operatorKind = GeneratedColumn<String>(
    'operator_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bus'),
  );
  static const VerificationMeta _cashFareCentsMeta = const VerificationMeta('cashFareCents');
  @override
  late final GeneratedColumn<int> cashFareCents = GeneratedColumn<int>(
    'cash_fare_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timetableNumberMeta = const VerificationMeta('timetableNumber');
  @override
  late final GeneratedColumn<String> timetableNumber = GeneratedColumn<String>(
    'timetable_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTypeMeta = const VerificationMeta('dayType');
  @override
  late final GeneratedColumn<String> dayType = GeneratedColumn<String>(
    'day_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayLabelMeta = const VerificationMeta('dayLabel');
  @override
  late final GeneratedColumn<String> dayLabel = GeneratedColumn<String>(
    'day_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardRawMeta = const VerificationMeta('boardRaw');
  @override
  late final GeneratedColumn<String> boardRaw = GeneratedColumn<String>(
    'board_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arriveRawMeta = const VerificationMeta('arriveRaw');
  @override
  late final GeneratedColumn<String> arriveRaw = GeneratedColumn<String>(
    'arrive_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boardMinutesMeta = const VerificationMeta('boardMinutes');
  @override
  late final GeneratedColumn<double> boardMinutes = GeneratedColumn<double>(
    'board_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arriveMinutesMeta = const VerificationMeta('arriveMinutes');
  @override
  late final GeneratedColumn<double> arriveMinutes = GeneratedColumn<double>(
    'arrive_minutes',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardApproxMeta = const VerificationMeta('boardApprox');
  @override
  late final GeneratedColumn<bool> boardApprox = GeneratedColumn<bool>(
    'board_approx',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("board_approx" IN (0, 1))'),
  );
  static const VerificationMeta _arriveApproxMeta = const VerificationMeta('arriveApprox');
  @override
  late final GeneratedColumn<bool> arriveApprox = GeneratedColumn<bool>(
    'arrive_approx',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("arrive_approx" IN (0, 1))'),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIndexMeta = const VerificationMeta('tripIndex');
  @override
  late final GeneratedColumn<int> tripIndex = GeneratedColumn<int>(
    'trip_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromSeqMeta = const VerificationMeta('fromSeq');
  @override
  late final GeneratedColumn<int> fromSeq = GeneratedColumn<int>(
    'from_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toSeqMeta = const VerificationMeta('toSeq');
  @override
  late final GeneratedColumn<int> toSeq = GeneratedColumn<int>(
    'to_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripSnapshotMeta = const VerificationMeta('tripSnapshot');
  @override
  late final GeneratedColumn<String> tripSnapshot = GeneratedColumn<String>(
    'trip_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _reminderLeadMinutesMeta = const VerificationMeta('reminderLeadMinutes');
  @override
  late final GeneratedColumn<int> reminderLeadMinutes = GeneratedColumn<int>(
    'reminder_lead_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardLabelMeta = const VerificationMeta('boardLabel');
  @override
  late final GeneratedColumn<String> boardLabel = GeneratedColumn<String>(
    'board_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alightLabelMeta = const VerificationMeta('alightLabel');
  @override
  late final GeneratedColumn<String> alightLabel = GeneratedColumn<String>(
    'alight_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceDate,
    fromEndpoint,
    toEndpoint,
    routeLabel,
    operatorCode,
    operatorName,
    operatorKind,
    cashFareCents,
    timetableNumber,
    dayType,
    dayLabel,
    boardRaw,
    arriveRaw,
    boardMinutes,
    arriveMinutes,
    boardApprox,
    arriveApprox,
    scheduleId,
    tripIndex,
    fromSeq,
    toSeq,
    tripSnapshot,
    status,
    reminderLeadMinutes,
    groupId,
    boardLabel,
    alightLabel,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_journeys';
  @override
  VerificationContext validateIntegrity(Insertable<SavedJourney> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_date')) {
      context.handle(_serviceDateMeta, serviceDate.isAcceptableOrUnknown(data['service_date']!, _serviceDateMeta));
    } else if (isInserting) {
      context.missing(_serviceDateMeta);
    }
    if (data.containsKey('from_endpoint')) {
      context.handle(_fromEndpointMeta, fromEndpoint.isAcceptableOrUnknown(data['from_endpoint']!, _fromEndpointMeta));
    } else if (isInserting) {
      context.missing(_fromEndpointMeta);
    }
    if (data.containsKey('to_endpoint')) {
      context.handle(_toEndpointMeta, toEndpoint.isAcceptableOrUnknown(data['to_endpoint']!, _toEndpointMeta));
    } else if (isInserting) {
      context.missing(_toEndpointMeta);
    }
    if (data.containsKey('route_label')) {
      context.handle(_routeLabelMeta, routeLabel.isAcceptableOrUnknown(data['route_label']!, _routeLabelMeta));
    } else if (isInserting) {
      context.missing(_routeLabelMeta);
    }
    if (data.containsKey('operator_code')) {
      context.handle(_operatorCodeMeta, operatorCode.isAcceptableOrUnknown(data['operator_code']!, _operatorCodeMeta));
    }
    if (data.containsKey('operator_name')) {
      context.handle(_operatorNameMeta, operatorName.isAcceptableOrUnknown(data['operator_name']!, _operatorNameMeta));
    }
    if (data.containsKey('operator_kind')) {
      context.handle(_operatorKindMeta, operatorKind.isAcceptableOrUnknown(data['operator_kind']!, _operatorKindMeta));
    }
    if (data.containsKey('cash_fare_cents')) {
      context.handle(
        _cashFareCentsMeta,
        cashFareCents.isAcceptableOrUnknown(data['cash_fare_cents']!, _cashFareCentsMeta),
      );
    }
    if (data.containsKey('timetable_number')) {
      context.handle(
        _timetableNumberMeta,
        timetableNumber.isAcceptableOrUnknown(data['timetable_number']!, _timetableNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_timetableNumberMeta);
    }
    if (data.containsKey('day_type')) {
      context.handle(_dayTypeMeta, dayType.isAcceptableOrUnknown(data['day_type']!, _dayTypeMeta));
    } else if (isInserting) {
      context.missing(_dayTypeMeta);
    }
    if (data.containsKey('day_label')) {
      context.handle(_dayLabelMeta, dayLabel.isAcceptableOrUnknown(data['day_label']!, _dayLabelMeta));
    } else if (isInserting) {
      context.missing(_dayLabelMeta);
    }
    if (data.containsKey('board_raw')) {
      context.handle(_boardRawMeta, boardRaw.isAcceptableOrUnknown(data['board_raw']!, _boardRawMeta));
    } else if (isInserting) {
      context.missing(_boardRawMeta);
    }
    if (data.containsKey('arrive_raw')) {
      context.handle(_arriveRawMeta, arriveRaw.isAcceptableOrUnknown(data['arrive_raw']!, _arriveRawMeta));
    } else if (isInserting) {
      context.missing(_arriveRawMeta);
    }
    if (data.containsKey('board_minutes')) {
      context.handle(_boardMinutesMeta, boardMinutes.isAcceptableOrUnknown(data['board_minutes']!, _boardMinutesMeta));
    } else if (isInserting) {
      context.missing(_boardMinutesMeta);
    }
    if (data.containsKey('arrive_minutes')) {
      context.handle(
        _arriveMinutesMeta,
        arriveMinutes.isAcceptableOrUnknown(data['arrive_minutes']!, _arriveMinutesMeta),
      );
    }
    if (data.containsKey('board_approx')) {
      context.handle(_boardApproxMeta, boardApprox.isAcceptableOrUnknown(data['board_approx']!, _boardApproxMeta));
    } else if (isInserting) {
      context.missing(_boardApproxMeta);
    }
    if (data.containsKey('arrive_approx')) {
      context.handle(_arriveApproxMeta, arriveApprox.isAcceptableOrUnknown(data['arrive_approx']!, _arriveApproxMeta));
    } else if (isInserting) {
      context.missing(_arriveApproxMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(_scheduleIdMeta, scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('trip_index')) {
      context.handle(_tripIndexMeta, tripIndex.isAcceptableOrUnknown(data['trip_index']!, _tripIndexMeta));
    } else if (isInserting) {
      context.missing(_tripIndexMeta);
    }
    if (data.containsKey('from_seq')) {
      context.handle(_fromSeqMeta, fromSeq.isAcceptableOrUnknown(data['from_seq']!, _fromSeqMeta));
    } else if (isInserting) {
      context.missing(_fromSeqMeta);
    }
    if (data.containsKey('to_seq')) {
      context.handle(_toSeqMeta, toSeq.isAcceptableOrUnknown(data['to_seq']!, _toSeqMeta));
    } else if (isInserting) {
      context.missing(_toSeqMeta);
    }
    if (data.containsKey('trip_snapshot')) {
      context.handle(_tripSnapshotMeta, tripSnapshot.isAcceptableOrUnknown(data['trip_snapshot']!, _tripSnapshotMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('reminder_lead_minutes')) {
      context.handle(
        _reminderLeadMinutesMeta,
        reminderLeadMinutes.isAcceptableOrUnknown(data['reminder_lead_minutes']!, _reminderLeadMinutesMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('board_label')) {
      context.handle(_boardLabelMeta, boardLabel.isAcceptableOrUnknown(data['board_label']!, _boardLabelMeta));
    }
    if (data.containsKey('alight_label')) {
      context.handle(_alightLabelMeta, alightLabel.isAcceptableOrUnknown(data['alight_label']!, _alightLabelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedJourney map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedJourney(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serviceDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}service_date'])!,
      fromEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}from_endpoint'])!,
      toEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}to_endpoint'])!,
      routeLabel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}route_label'])!,
      operatorCode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_code'])!,
      operatorName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_name'])!,
      operatorKind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}operator_kind'])!,
      cashFareCents: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cash_fare_cents']),
      timetableNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timetable_number'],
      )!,
      dayType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day_type'])!,
      dayLabel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day_label'])!,
      boardRaw: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}board_raw'])!,
      arriveRaw: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}arrive_raw'])!,
      boardMinutes: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}board_minutes'])!,
      arriveMinutes: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}arrive_minutes']),
      boardApprox: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}board_approx'])!,
      arriveApprox: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}arrive_approx'])!,
      scheduleId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}schedule_id'])!,
      tripIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}trip_index'])!,
      fromSeq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}from_seq'])!,
      toSeq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}to_seq'])!,
      tripSnapshot: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}trip_snapshot']),
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      reminderLeadMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_lead_minutes'],
      ),
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      boardLabel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}board_label']),
      alightLabel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}alight_label']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $SavedJourneysTable createAlias(String alias) {
    return $SavedJourneysTable(attachedDatabase, alias);
  }
}

class SavedJourney extends DataClass implements Insertable<SavedJourney> {
  final String id;
  final String serviceDate;
  final String fromEndpoint;
  final String toEndpoint;
  final String routeLabel;
  final String operatorCode;
  final String operatorName;
  final String operatorKind;
  final int? cashFareCents;
  final String timetableNumber;
  final String dayType;
  final String dayLabel;
  final String boardRaw;
  final String arriveRaw;
  final double boardMinutes;
  final double? arriveMinutes;
  final bool boardApprox;
  final bool arriveApprox;
  final int scheduleId;
  final int tripIndex;
  final int fromSeq;
  final int toSeq;
  final String? tripSnapshot;
  final String status;
  final int? reminderLeadMinutes;
  final String? groupId;
  final String? boardLabel;
  final String? alightLabel;
  final int createdAt;
  final int? completedAt;
  const SavedJourney({
    required this.id,
    required this.serviceDate,
    required this.fromEndpoint,
    required this.toEndpoint,
    required this.routeLabel,
    required this.operatorCode,
    required this.operatorName,
    required this.operatorKind,
    this.cashFareCents,
    required this.timetableNumber,
    required this.dayType,
    required this.dayLabel,
    required this.boardRaw,
    required this.arriveRaw,
    required this.boardMinutes,
    this.arriveMinutes,
    required this.boardApprox,
    required this.arriveApprox,
    required this.scheduleId,
    required this.tripIndex,
    required this.fromSeq,
    required this.toSeq,
    this.tripSnapshot,
    required this.status,
    this.reminderLeadMinutes,
    this.groupId,
    this.boardLabel,
    this.alightLabel,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_date'] = Variable<String>(serviceDate);
    map['from_endpoint'] = Variable<String>(fromEndpoint);
    map['to_endpoint'] = Variable<String>(toEndpoint);
    map['route_label'] = Variable<String>(routeLabel);
    map['operator_code'] = Variable<String>(operatorCode);
    map['operator_name'] = Variable<String>(operatorName);
    map['operator_kind'] = Variable<String>(operatorKind);
    if (!nullToAbsent || cashFareCents != null) {
      map['cash_fare_cents'] = Variable<int>(cashFareCents);
    }
    map['timetable_number'] = Variable<String>(timetableNumber);
    map['day_type'] = Variable<String>(dayType);
    map['day_label'] = Variable<String>(dayLabel);
    map['board_raw'] = Variable<String>(boardRaw);
    map['arrive_raw'] = Variable<String>(arriveRaw);
    map['board_minutes'] = Variable<double>(boardMinutes);
    if (!nullToAbsent || arriveMinutes != null) {
      map['arrive_minutes'] = Variable<double>(arriveMinutes);
    }
    map['board_approx'] = Variable<bool>(boardApprox);
    map['arrive_approx'] = Variable<bool>(arriveApprox);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['trip_index'] = Variable<int>(tripIndex);
    map['from_seq'] = Variable<int>(fromSeq);
    map['to_seq'] = Variable<int>(toSeq);
    if (!nullToAbsent || tripSnapshot != null) {
      map['trip_snapshot'] = Variable<String>(tripSnapshot);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reminderLeadMinutes != null) {
      map['reminder_lead_minutes'] = Variable<int>(reminderLeadMinutes);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || boardLabel != null) {
      map['board_label'] = Variable<String>(boardLabel);
    }
    if (!nullToAbsent || alightLabel != null) {
      map['alight_label'] = Variable<String>(alightLabel);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  SavedJourneysCompanion toCompanion(bool nullToAbsent) {
    return SavedJourneysCompanion(
      id: Value(id),
      serviceDate: Value(serviceDate),
      fromEndpoint: Value(fromEndpoint),
      toEndpoint: Value(toEndpoint),
      routeLabel: Value(routeLabel),
      operatorCode: Value(operatorCode),
      operatorName: Value(operatorName),
      operatorKind: Value(operatorKind),
      cashFareCents: cashFareCents == null && nullToAbsent ? const Value.absent() : Value(cashFareCents),
      timetableNumber: Value(timetableNumber),
      dayType: Value(dayType),
      dayLabel: Value(dayLabel),
      boardRaw: Value(boardRaw),
      arriveRaw: Value(arriveRaw),
      boardMinutes: Value(boardMinutes),
      arriveMinutes: arriveMinutes == null && nullToAbsent ? const Value.absent() : Value(arriveMinutes),
      boardApprox: Value(boardApprox),
      arriveApprox: Value(arriveApprox),
      scheduleId: Value(scheduleId),
      tripIndex: Value(tripIndex),
      fromSeq: Value(fromSeq),
      toSeq: Value(toSeq),
      tripSnapshot: tripSnapshot == null && nullToAbsent ? const Value.absent() : Value(tripSnapshot),
      status: Value(status),
      reminderLeadMinutes: reminderLeadMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderLeadMinutes),
      groupId: groupId == null && nullToAbsent ? const Value.absent() : Value(groupId),
      boardLabel: boardLabel == null && nullToAbsent ? const Value.absent() : Value(boardLabel),
      alightLabel: alightLabel == null && nullToAbsent ? const Value.absent() : Value(alightLabel),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
    );
  }

  factory SavedJourney.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedJourney(
      id: serializer.fromJson<String>(json['id']),
      serviceDate: serializer.fromJson<String>(json['serviceDate']),
      fromEndpoint: serializer.fromJson<String>(json['fromEndpoint']),
      toEndpoint: serializer.fromJson<String>(json['toEndpoint']),
      routeLabel: serializer.fromJson<String>(json['routeLabel']),
      operatorCode: serializer.fromJson<String>(json['operatorCode']),
      operatorName: serializer.fromJson<String>(json['operatorName']),
      operatorKind: serializer.fromJson<String>(json['operatorKind']),
      cashFareCents: serializer.fromJson<int?>(json['cashFareCents']),
      timetableNumber: serializer.fromJson<String>(json['timetableNumber']),
      dayType: serializer.fromJson<String>(json['dayType']),
      dayLabel: serializer.fromJson<String>(json['dayLabel']),
      boardRaw: serializer.fromJson<String>(json['boardRaw']),
      arriveRaw: serializer.fromJson<String>(json['arriveRaw']),
      boardMinutes: serializer.fromJson<double>(json['boardMinutes']),
      arriveMinutes: serializer.fromJson<double?>(json['arriveMinutes']),
      boardApprox: serializer.fromJson<bool>(json['boardApprox']),
      arriveApprox: serializer.fromJson<bool>(json['arriveApprox']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      tripIndex: serializer.fromJson<int>(json['tripIndex']),
      fromSeq: serializer.fromJson<int>(json['fromSeq']),
      toSeq: serializer.fromJson<int>(json['toSeq']),
      tripSnapshot: serializer.fromJson<String?>(json['tripSnapshot']),
      status: serializer.fromJson<String>(json['status']),
      reminderLeadMinutes: serializer.fromJson<int?>(json['reminderLeadMinutes']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      boardLabel: serializer.fromJson<String?>(json['boardLabel']),
      alightLabel: serializer.fromJson<String?>(json['alightLabel']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceDate': serializer.toJson<String>(serviceDate),
      'fromEndpoint': serializer.toJson<String>(fromEndpoint),
      'toEndpoint': serializer.toJson<String>(toEndpoint),
      'routeLabel': serializer.toJson<String>(routeLabel),
      'operatorCode': serializer.toJson<String>(operatorCode),
      'operatorName': serializer.toJson<String>(operatorName),
      'operatorKind': serializer.toJson<String>(operatorKind),
      'cashFareCents': serializer.toJson<int?>(cashFareCents),
      'timetableNumber': serializer.toJson<String>(timetableNumber),
      'dayType': serializer.toJson<String>(dayType),
      'dayLabel': serializer.toJson<String>(dayLabel),
      'boardRaw': serializer.toJson<String>(boardRaw),
      'arriveRaw': serializer.toJson<String>(arriveRaw),
      'boardMinutes': serializer.toJson<double>(boardMinutes),
      'arriveMinutes': serializer.toJson<double?>(arriveMinutes),
      'boardApprox': serializer.toJson<bool>(boardApprox),
      'arriveApprox': serializer.toJson<bool>(arriveApprox),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'tripIndex': serializer.toJson<int>(tripIndex),
      'fromSeq': serializer.toJson<int>(fromSeq),
      'toSeq': serializer.toJson<int>(toSeq),
      'tripSnapshot': serializer.toJson<String?>(tripSnapshot),
      'status': serializer.toJson<String>(status),
      'reminderLeadMinutes': serializer.toJson<int?>(reminderLeadMinutes),
      'groupId': serializer.toJson<String?>(groupId),
      'boardLabel': serializer.toJson<String?>(boardLabel),
      'alightLabel': serializer.toJson<String?>(alightLabel),
      'createdAt': serializer.toJson<int>(createdAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  SavedJourney copyWith({
    String? id,
    String? serviceDate,
    String? fromEndpoint,
    String? toEndpoint,
    String? routeLabel,
    String? operatorCode,
    String? operatorName,
    String? operatorKind,
    Value<int?> cashFareCents = const Value.absent(),
    String? timetableNumber,
    String? dayType,
    String? dayLabel,
    String? boardRaw,
    String? arriveRaw,
    double? boardMinutes,
    Value<double?> arriveMinutes = const Value.absent(),
    bool? boardApprox,
    bool? arriveApprox,
    int? scheduleId,
    int? tripIndex,
    int? fromSeq,
    int? toSeq,
    Value<String?> tripSnapshot = const Value.absent(),
    String? status,
    Value<int?> reminderLeadMinutes = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    Value<String?> boardLabel = const Value.absent(),
    Value<String?> alightLabel = const Value.absent(),
    int? createdAt,
    Value<int?> completedAt = const Value.absent(),
  }) => SavedJourney(
    id: id ?? this.id,
    serviceDate: serviceDate ?? this.serviceDate,
    fromEndpoint: fromEndpoint ?? this.fromEndpoint,
    toEndpoint: toEndpoint ?? this.toEndpoint,
    routeLabel: routeLabel ?? this.routeLabel,
    operatorCode: operatorCode ?? this.operatorCode,
    operatorName: operatorName ?? this.operatorName,
    operatorKind: operatorKind ?? this.operatorKind,
    cashFareCents: cashFareCents.present ? cashFareCents.value : this.cashFareCents,
    timetableNumber: timetableNumber ?? this.timetableNumber,
    dayType: dayType ?? this.dayType,
    dayLabel: dayLabel ?? this.dayLabel,
    boardRaw: boardRaw ?? this.boardRaw,
    arriveRaw: arriveRaw ?? this.arriveRaw,
    boardMinutes: boardMinutes ?? this.boardMinutes,
    arriveMinutes: arriveMinutes.present ? arriveMinutes.value : this.arriveMinutes,
    boardApprox: boardApprox ?? this.boardApprox,
    arriveApprox: arriveApprox ?? this.arriveApprox,
    scheduleId: scheduleId ?? this.scheduleId,
    tripIndex: tripIndex ?? this.tripIndex,
    fromSeq: fromSeq ?? this.fromSeq,
    toSeq: toSeq ?? this.toSeq,
    tripSnapshot: tripSnapshot.present ? tripSnapshot.value : this.tripSnapshot,
    status: status ?? this.status,
    reminderLeadMinutes: reminderLeadMinutes.present ? reminderLeadMinutes.value : this.reminderLeadMinutes,
    groupId: groupId.present ? groupId.value : this.groupId,
    boardLabel: boardLabel.present ? boardLabel.value : this.boardLabel,
    alightLabel: alightLabel.present ? alightLabel.value : this.alightLabel,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SavedJourney copyWithCompanion(SavedJourneysCompanion data) {
    return SavedJourney(
      id: data.id.present ? data.id.value : this.id,
      serviceDate: data.serviceDate.present ? data.serviceDate.value : this.serviceDate,
      fromEndpoint: data.fromEndpoint.present ? data.fromEndpoint.value : this.fromEndpoint,
      toEndpoint: data.toEndpoint.present ? data.toEndpoint.value : this.toEndpoint,
      routeLabel: data.routeLabel.present ? data.routeLabel.value : this.routeLabel,
      operatorCode: data.operatorCode.present ? data.operatorCode.value : this.operatorCode,
      operatorName: data.operatorName.present ? data.operatorName.value : this.operatorName,
      operatorKind: data.operatorKind.present ? data.operatorKind.value : this.operatorKind,
      cashFareCents: data.cashFareCents.present ? data.cashFareCents.value : this.cashFareCents,
      timetableNumber: data.timetableNumber.present ? data.timetableNumber.value : this.timetableNumber,
      dayType: data.dayType.present ? data.dayType.value : this.dayType,
      dayLabel: data.dayLabel.present ? data.dayLabel.value : this.dayLabel,
      boardRaw: data.boardRaw.present ? data.boardRaw.value : this.boardRaw,
      arriveRaw: data.arriveRaw.present ? data.arriveRaw.value : this.arriveRaw,
      boardMinutes: data.boardMinutes.present ? data.boardMinutes.value : this.boardMinutes,
      arriveMinutes: data.arriveMinutes.present ? data.arriveMinutes.value : this.arriveMinutes,
      boardApprox: data.boardApprox.present ? data.boardApprox.value : this.boardApprox,
      arriveApprox: data.arriveApprox.present ? data.arriveApprox.value : this.arriveApprox,
      scheduleId: data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      tripIndex: data.tripIndex.present ? data.tripIndex.value : this.tripIndex,
      fromSeq: data.fromSeq.present ? data.fromSeq.value : this.fromSeq,
      toSeq: data.toSeq.present ? data.toSeq.value : this.toSeq,
      tripSnapshot: data.tripSnapshot.present ? data.tripSnapshot.value : this.tripSnapshot,
      status: data.status.present ? data.status.value : this.status,
      reminderLeadMinutes: data.reminderLeadMinutes.present ? data.reminderLeadMinutes.value : this.reminderLeadMinutes,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      boardLabel: data.boardLabel.present ? data.boardLabel.value : this.boardLabel,
      alightLabel: data.alightLabel.present ? data.alightLabel.value : this.alightLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedJourney(')
          ..write('id: $id, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('routeLabel: $routeLabel, ')
          ..write('operatorCode: $operatorCode, ')
          ..write('operatorName: $operatorName, ')
          ..write('operatorKind: $operatorKind, ')
          ..write('cashFareCents: $cashFareCents, ')
          ..write('timetableNumber: $timetableNumber, ')
          ..write('dayType: $dayType, ')
          ..write('dayLabel: $dayLabel, ')
          ..write('boardRaw: $boardRaw, ')
          ..write('arriveRaw: $arriveRaw, ')
          ..write('boardMinutes: $boardMinutes, ')
          ..write('arriveMinutes: $arriveMinutes, ')
          ..write('boardApprox: $boardApprox, ')
          ..write('arriveApprox: $arriveApprox, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('tripIndex: $tripIndex, ')
          ..write('fromSeq: $fromSeq, ')
          ..write('toSeq: $toSeq, ')
          ..write('tripSnapshot: $tripSnapshot, ')
          ..write('status: $status, ')
          ..write('reminderLeadMinutes: $reminderLeadMinutes, ')
          ..write('groupId: $groupId, ')
          ..write('boardLabel: $boardLabel, ')
          ..write('alightLabel: $alightLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serviceDate,
    fromEndpoint,
    toEndpoint,
    routeLabel,
    operatorCode,
    operatorName,
    operatorKind,
    cashFareCents,
    timetableNumber,
    dayType,
    dayLabel,
    boardRaw,
    arriveRaw,
    boardMinutes,
    arriveMinutes,
    boardApprox,
    arriveApprox,
    scheduleId,
    tripIndex,
    fromSeq,
    toSeq,
    tripSnapshot,
    status,
    reminderLeadMinutes,
    groupId,
    boardLabel,
    alightLabel,
    createdAt,
    completedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedJourney &&
          other.id == this.id &&
          other.serviceDate == this.serviceDate &&
          other.fromEndpoint == this.fromEndpoint &&
          other.toEndpoint == this.toEndpoint &&
          other.routeLabel == this.routeLabel &&
          other.operatorCode == this.operatorCode &&
          other.operatorName == this.operatorName &&
          other.operatorKind == this.operatorKind &&
          other.cashFareCents == this.cashFareCents &&
          other.timetableNumber == this.timetableNumber &&
          other.dayType == this.dayType &&
          other.dayLabel == this.dayLabel &&
          other.boardRaw == this.boardRaw &&
          other.arriveRaw == this.arriveRaw &&
          other.boardMinutes == this.boardMinutes &&
          other.arriveMinutes == this.arriveMinutes &&
          other.boardApprox == this.boardApprox &&
          other.arriveApprox == this.arriveApprox &&
          other.scheduleId == this.scheduleId &&
          other.tripIndex == this.tripIndex &&
          other.fromSeq == this.fromSeq &&
          other.toSeq == this.toSeq &&
          other.tripSnapshot == this.tripSnapshot &&
          other.status == this.status &&
          other.reminderLeadMinutes == this.reminderLeadMinutes &&
          other.groupId == this.groupId &&
          other.boardLabel == this.boardLabel &&
          other.alightLabel == this.alightLabel &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class SavedJourneysCompanion extends UpdateCompanion<SavedJourney> {
  final Value<String> id;
  final Value<String> serviceDate;
  final Value<String> fromEndpoint;
  final Value<String> toEndpoint;
  final Value<String> routeLabel;
  final Value<String> operatorCode;
  final Value<String> operatorName;
  final Value<String> operatorKind;
  final Value<int?> cashFareCents;
  final Value<String> timetableNumber;
  final Value<String> dayType;
  final Value<String> dayLabel;
  final Value<String> boardRaw;
  final Value<String> arriveRaw;
  final Value<double> boardMinutes;
  final Value<double?> arriveMinutes;
  final Value<bool> boardApprox;
  final Value<bool> arriveApprox;
  final Value<int> scheduleId;
  final Value<int> tripIndex;
  final Value<int> fromSeq;
  final Value<int> toSeq;
  final Value<String?> tripSnapshot;
  final Value<String> status;
  final Value<int?> reminderLeadMinutes;
  final Value<String?> groupId;
  final Value<String?> boardLabel;
  final Value<String?> alightLabel;
  final Value<int> createdAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const SavedJourneysCompanion({
    this.id = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.fromEndpoint = const Value.absent(),
    this.toEndpoint = const Value.absent(),
    this.routeLabel = const Value.absent(),
    this.operatorCode = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.operatorKind = const Value.absent(),
    this.cashFareCents = const Value.absent(),
    this.timetableNumber = const Value.absent(),
    this.dayType = const Value.absent(),
    this.dayLabel = const Value.absent(),
    this.boardRaw = const Value.absent(),
    this.arriveRaw = const Value.absent(),
    this.boardMinutes = const Value.absent(),
    this.arriveMinutes = const Value.absent(),
    this.boardApprox = const Value.absent(),
    this.arriveApprox = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.tripIndex = const Value.absent(),
    this.fromSeq = const Value.absent(),
    this.toSeq = const Value.absent(),
    this.tripSnapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderLeadMinutes = const Value.absent(),
    this.groupId = const Value.absent(),
    this.boardLabel = const Value.absent(),
    this.alightLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedJourneysCompanion.insert({
    required String id,
    required String serviceDate,
    required String fromEndpoint,
    required String toEndpoint,
    required String routeLabel,
    this.operatorCode = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.operatorKind = const Value.absent(),
    this.cashFareCents = const Value.absent(),
    required String timetableNumber,
    required String dayType,
    required String dayLabel,
    required String boardRaw,
    required String arriveRaw,
    required double boardMinutes,
    this.arriveMinutes = const Value.absent(),
    required bool boardApprox,
    required bool arriveApprox,
    required int scheduleId,
    required int tripIndex,
    required int fromSeq,
    required int toSeq,
    this.tripSnapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderLeadMinutes = const Value.absent(),
    this.groupId = const Value.absent(),
    this.boardLabel = const Value.absent(),
    this.alightLabel = const Value.absent(),
    required int createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceDate = Value(serviceDate),
       fromEndpoint = Value(fromEndpoint),
       toEndpoint = Value(toEndpoint),
       routeLabel = Value(routeLabel),
       timetableNumber = Value(timetableNumber),
       dayType = Value(dayType),
       dayLabel = Value(dayLabel),
       boardRaw = Value(boardRaw),
       arriveRaw = Value(arriveRaw),
       boardMinutes = Value(boardMinutes),
       boardApprox = Value(boardApprox),
       arriveApprox = Value(arriveApprox),
       scheduleId = Value(scheduleId),
       tripIndex = Value(tripIndex),
       fromSeq = Value(fromSeq),
       toSeq = Value(toSeq),
       createdAt = Value(createdAt);
  static Insertable<SavedJourney> custom({
    Expression<String>? id,
    Expression<String>? serviceDate,
    Expression<String>? fromEndpoint,
    Expression<String>? toEndpoint,
    Expression<String>? routeLabel,
    Expression<String>? operatorCode,
    Expression<String>? operatorName,
    Expression<String>? operatorKind,
    Expression<int>? cashFareCents,
    Expression<String>? timetableNumber,
    Expression<String>? dayType,
    Expression<String>? dayLabel,
    Expression<String>? boardRaw,
    Expression<String>? arriveRaw,
    Expression<double>? boardMinutes,
    Expression<double>? arriveMinutes,
    Expression<bool>? boardApprox,
    Expression<bool>? arriveApprox,
    Expression<int>? scheduleId,
    Expression<int>? tripIndex,
    Expression<int>? fromSeq,
    Expression<int>? toSeq,
    Expression<String>? tripSnapshot,
    Expression<String>? status,
    Expression<int>? reminderLeadMinutes,
    Expression<String>? groupId,
    Expression<String>? boardLabel,
    Expression<String>? alightLabel,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceDate != null) 'service_date': serviceDate,
      if (fromEndpoint != null) 'from_endpoint': fromEndpoint,
      if (toEndpoint != null) 'to_endpoint': toEndpoint,
      if (routeLabel != null) 'route_label': routeLabel,
      if (operatorCode != null) 'operator_code': operatorCode,
      if (operatorName != null) 'operator_name': operatorName,
      if (operatorKind != null) 'operator_kind': operatorKind,
      if (cashFareCents != null) 'cash_fare_cents': cashFareCents,
      if (timetableNumber != null) 'timetable_number': timetableNumber,
      if (dayType != null) 'day_type': dayType,
      if (dayLabel != null) 'day_label': dayLabel,
      if (boardRaw != null) 'board_raw': boardRaw,
      if (arriveRaw != null) 'arrive_raw': arriveRaw,
      if (boardMinutes != null) 'board_minutes': boardMinutes,
      if (arriveMinutes != null) 'arrive_minutes': arriveMinutes,
      if (boardApprox != null) 'board_approx': boardApprox,
      if (arriveApprox != null) 'arrive_approx': arriveApprox,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (tripIndex != null) 'trip_index': tripIndex,
      if (fromSeq != null) 'from_seq': fromSeq,
      if (toSeq != null) 'to_seq': toSeq,
      if (tripSnapshot != null) 'trip_snapshot': tripSnapshot,
      if (status != null) 'status': status,
      if (reminderLeadMinutes != null) 'reminder_lead_minutes': reminderLeadMinutes,
      if (groupId != null) 'group_id': groupId,
      if (boardLabel != null) 'board_label': boardLabel,
      if (alightLabel != null) 'alight_label': alightLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedJourneysCompanion copyWith({
    Value<String>? id,
    Value<String>? serviceDate,
    Value<String>? fromEndpoint,
    Value<String>? toEndpoint,
    Value<String>? routeLabel,
    Value<String>? operatorCode,
    Value<String>? operatorName,
    Value<String>? operatorKind,
    Value<int?>? cashFareCents,
    Value<String>? timetableNumber,
    Value<String>? dayType,
    Value<String>? dayLabel,
    Value<String>? boardRaw,
    Value<String>? arriveRaw,
    Value<double>? boardMinutes,
    Value<double?>? arriveMinutes,
    Value<bool>? boardApprox,
    Value<bool>? arriveApprox,
    Value<int>? scheduleId,
    Value<int>? tripIndex,
    Value<int>? fromSeq,
    Value<int>? toSeq,
    Value<String?>? tripSnapshot,
    Value<String>? status,
    Value<int?>? reminderLeadMinutes,
    Value<String?>? groupId,
    Value<String?>? boardLabel,
    Value<String?>? alightLabel,
    Value<int>? createdAt,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return SavedJourneysCompanion(
      id: id ?? this.id,
      serviceDate: serviceDate ?? this.serviceDate,
      fromEndpoint: fromEndpoint ?? this.fromEndpoint,
      toEndpoint: toEndpoint ?? this.toEndpoint,
      routeLabel: routeLabel ?? this.routeLabel,
      operatorCode: operatorCode ?? this.operatorCode,
      operatorName: operatorName ?? this.operatorName,
      operatorKind: operatorKind ?? this.operatorKind,
      cashFareCents: cashFareCents ?? this.cashFareCents,
      timetableNumber: timetableNumber ?? this.timetableNumber,
      dayType: dayType ?? this.dayType,
      dayLabel: dayLabel ?? this.dayLabel,
      boardRaw: boardRaw ?? this.boardRaw,
      arriveRaw: arriveRaw ?? this.arriveRaw,
      boardMinutes: boardMinutes ?? this.boardMinutes,
      arriveMinutes: arriveMinutes ?? this.arriveMinutes,
      boardApprox: boardApprox ?? this.boardApprox,
      arriveApprox: arriveApprox ?? this.arriveApprox,
      scheduleId: scheduleId ?? this.scheduleId,
      tripIndex: tripIndex ?? this.tripIndex,
      fromSeq: fromSeq ?? this.fromSeq,
      toSeq: toSeq ?? this.toSeq,
      tripSnapshot: tripSnapshot ?? this.tripSnapshot,
      status: status ?? this.status,
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      groupId: groupId ?? this.groupId,
      boardLabel: boardLabel ?? this.boardLabel,
      alightLabel: alightLabel ?? this.alightLabel,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<String>(serviceDate.value);
    }
    if (fromEndpoint.present) {
      map['from_endpoint'] = Variable<String>(fromEndpoint.value);
    }
    if (toEndpoint.present) {
      map['to_endpoint'] = Variable<String>(toEndpoint.value);
    }
    if (routeLabel.present) {
      map['route_label'] = Variable<String>(routeLabel.value);
    }
    if (operatorCode.present) {
      map['operator_code'] = Variable<String>(operatorCode.value);
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (operatorKind.present) {
      map['operator_kind'] = Variable<String>(operatorKind.value);
    }
    if (cashFareCents.present) {
      map['cash_fare_cents'] = Variable<int>(cashFareCents.value);
    }
    if (timetableNumber.present) {
      map['timetable_number'] = Variable<String>(timetableNumber.value);
    }
    if (dayType.present) {
      map['day_type'] = Variable<String>(dayType.value);
    }
    if (dayLabel.present) {
      map['day_label'] = Variable<String>(dayLabel.value);
    }
    if (boardRaw.present) {
      map['board_raw'] = Variable<String>(boardRaw.value);
    }
    if (arriveRaw.present) {
      map['arrive_raw'] = Variable<String>(arriveRaw.value);
    }
    if (boardMinutes.present) {
      map['board_minutes'] = Variable<double>(boardMinutes.value);
    }
    if (arriveMinutes.present) {
      map['arrive_minutes'] = Variable<double>(arriveMinutes.value);
    }
    if (boardApprox.present) {
      map['board_approx'] = Variable<bool>(boardApprox.value);
    }
    if (arriveApprox.present) {
      map['arrive_approx'] = Variable<bool>(arriveApprox.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (tripIndex.present) {
      map['trip_index'] = Variable<int>(tripIndex.value);
    }
    if (fromSeq.present) {
      map['from_seq'] = Variable<int>(fromSeq.value);
    }
    if (toSeq.present) {
      map['to_seq'] = Variable<int>(toSeq.value);
    }
    if (tripSnapshot.present) {
      map['trip_snapshot'] = Variable<String>(tripSnapshot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reminderLeadMinutes.present) {
      map['reminder_lead_minutes'] = Variable<int>(reminderLeadMinutes.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (boardLabel.present) {
      map['board_label'] = Variable<String>(boardLabel.value);
    }
    if (alightLabel.present) {
      map['alight_label'] = Variable<String>(alightLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedJourneysCompanion(')
          ..write('id: $id, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('routeLabel: $routeLabel, ')
          ..write('operatorCode: $operatorCode, ')
          ..write('operatorName: $operatorName, ')
          ..write('operatorKind: $operatorKind, ')
          ..write('cashFareCents: $cashFareCents, ')
          ..write('timetableNumber: $timetableNumber, ')
          ..write('dayType: $dayType, ')
          ..write('dayLabel: $dayLabel, ')
          ..write('boardRaw: $boardRaw, ')
          ..write('arriveRaw: $arriveRaw, ')
          ..write('boardMinutes: $boardMinutes, ')
          ..write('arriveMinutes: $arriveMinutes, ')
          ..write('boardApprox: $boardApprox, ')
          ..write('arriveApprox: $arriveApprox, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('tripIndex: $tripIndex, ')
          ..write('fromSeq: $fromSeq, ')
          ..write('toSeq: $toSeq, ')
          ..write('tripSnapshot: $tripSnapshot, ')
          ..write('status: $status, ')
          ..write('reminderLeadMinutes: $reminderLeadMinutes, ')
          ..write('groupId: $groupId, ')
          ..write('boardLabel: $boardLabel, ')
          ..write('alightLabel: $alightLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, Place> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointJsonMeta = const VerificationMeta('endpointJson');
  @override
  late final GeneratedColumn<String> endpointJson = GeneratedColumn<String>(
    'endpoint_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, label, endpointJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(Insertable<Place> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('endpoint_json')) {
      context.handle(_endpointJsonMeta, endpointJson.isAcceptableOrUnknown(data['endpoint_json']!, _endpointJsonMeta));
    } else if (isInserting) {
      context.missing(_endpointJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Place map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Place(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      endpointJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}endpoint_json'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class Place extends DataClass implements Insertable<Place> {
  final String id;
  final String kind;
  final String label;
  final String endpointJson;
  final int createdAt;
  const Place({
    required this.id,
    required this.kind,
    required this.label,
    required this.endpointJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    map['endpoint_json'] = Variable<String>(endpointJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      kind: Value(kind),
      label: Value(label),
      endpointJson: Value(endpointJson),
      createdAt: Value(createdAt),
    );
  }

  factory Place.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Place(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      endpointJson: serializer.fromJson<String>(json['endpointJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'endpointJson': serializer.toJson<String>(endpointJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Place copyWith({String? id, String? kind, String? label, String? endpointJson, int? createdAt}) => Place(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    endpointJson: endpointJson ?? this.endpointJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Place copyWithCompanion(PlacesCompanion data) {
    return Place(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      endpointJson: data.endpointJson.present ? data.endpointJson.value : this.endpointJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Place(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, label, endpointJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Place &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.endpointJson == this.endpointJson &&
          other.createdAt == this.createdAt);
}

class PlacesCompanion extends UpdateCompanion<Place> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> label;
  final Value<String> endpointJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.endpointJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacesCompanion.insert({
    required String id,
    required String kind,
    required String label,
    required String endpointJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label),
       endpointJson = Value(endpointJson),
       createdAt = Value(createdAt);
  static Insertable<Place> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<String>? endpointJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (endpointJson != null) 'endpoint_json': endpointJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? label,
    Value<String>? endpointJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      endpointJson: endpointJson ?? this.endpointJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (endpointJson.present) {
      map['endpoint_json'] = Variable<String>(endpointJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('endpointJson: $endpointJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedTripsTable extends SavedTrips with TableInfo<$SavedTripsTable, SavedTrip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedTripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromEndpointMeta = const VerificationMeta('fromEndpoint');
  @override
  late final GeneratedColumn<String> fromEndpoint = GeneratedColumn<String>(
    'from_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toEndpointMeta = const VerificationMeta('toEndpoint');
  @override
  late final GeneratedColumn<String> toEndpoint = GeneratedColumn<String>(
    'to_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fromEndpoint, toEndpoint, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_trips';
  @override
  VerificationContext validateIntegrity(Insertable<SavedTrip> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_endpoint')) {
      context.handle(_fromEndpointMeta, fromEndpoint.isAcceptableOrUnknown(data['from_endpoint']!, _fromEndpointMeta));
    } else if (isInserting) {
      context.missing(_fromEndpointMeta);
    }
    if (data.containsKey('to_endpoint')) {
      context.handle(_toEndpointMeta, toEndpoint.isAcceptableOrUnknown(data['to_endpoint']!, _toEndpointMeta));
    } else if (isInserting) {
      context.missing(_toEndpointMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedTrip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedTrip(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}from_endpoint'])!,
      toEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}to_endpoint'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavedTripsTable createAlias(String alias) {
    return $SavedTripsTable(attachedDatabase, alias);
  }
}

class SavedTrip extends DataClass implements Insertable<SavedTrip> {
  final String id;
  final String fromEndpoint;
  final String toEndpoint;
  final int createdAt;
  const SavedTrip({required this.id, required this.fromEndpoint, required this.toEndpoint, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_endpoint'] = Variable<String>(fromEndpoint);
    map['to_endpoint'] = Variable<String>(toEndpoint);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SavedTripsCompanion toCompanion(bool nullToAbsent) {
    return SavedTripsCompanion(
      id: Value(id),
      fromEndpoint: Value(fromEndpoint),
      toEndpoint: Value(toEndpoint),
      createdAt: Value(createdAt),
    );
  }

  factory SavedTrip.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedTrip(
      id: serializer.fromJson<String>(json['id']),
      fromEndpoint: serializer.fromJson<String>(json['fromEndpoint']),
      toEndpoint: serializer.fromJson<String>(json['toEndpoint']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromEndpoint': serializer.toJson<String>(fromEndpoint),
      'toEndpoint': serializer.toJson<String>(toEndpoint),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SavedTrip copyWith({String? id, String? fromEndpoint, String? toEndpoint, int? createdAt}) => SavedTrip(
    id: id ?? this.id,
    fromEndpoint: fromEndpoint ?? this.fromEndpoint,
    toEndpoint: toEndpoint ?? this.toEndpoint,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedTrip copyWithCompanion(SavedTripsCompanion data) {
    return SavedTrip(
      id: data.id.present ? data.id.value : this.id,
      fromEndpoint: data.fromEndpoint.present ? data.fromEndpoint.value : this.fromEndpoint,
      toEndpoint: data.toEndpoint.present ? data.toEndpoint.value : this.toEndpoint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedTrip(')
          ..write('id: $id, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromEndpoint, toEndpoint, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedTrip &&
          other.id == this.id &&
          other.fromEndpoint == this.fromEndpoint &&
          other.toEndpoint == this.toEndpoint &&
          other.createdAt == this.createdAt);
}

class SavedTripsCompanion extends UpdateCompanion<SavedTrip> {
  final Value<String> id;
  final Value<String> fromEndpoint;
  final Value<String> toEndpoint;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SavedTripsCompanion({
    this.id = const Value.absent(),
    this.fromEndpoint = const Value.absent(),
    this.toEndpoint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedTripsCompanion.insert({
    required String id,
    required String fromEndpoint,
    required String toEndpoint,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromEndpoint = Value(fromEndpoint),
       toEndpoint = Value(toEndpoint),
       createdAt = Value(createdAt);
  static Insertable<SavedTrip> custom({
    Expression<String>? id,
    Expression<String>? fromEndpoint,
    Expression<String>? toEndpoint,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromEndpoint != null) 'from_endpoint': fromEndpoint,
      if (toEndpoint != null) 'to_endpoint': toEndpoint,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedTripsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromEndpoint,
    Value<String>? toEndpoint,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SavedTripsCompanion(
      id: id ?? this.id,
      fromEndpoint: fromEndpoint ?? this.fromEndpoint,
      toEndpoint: toEndpoint ?? this.toEndpoint,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromEndpoint.present) {
      map['from_endpoint'] = Variable<String>(fromEndpoint.value);
    }
    if (toEndpoint.present) {
      map['to_endpoint'] = Variable<String>(toEndpoint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedTripsCompanion(')
          ..write('id: $id, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches with TableInfo<$RecentSearchesTable, RecentSearch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromEndpointMeta = const VerificationMeta('fromEndpoint');
  @override
  late final GeneratedColumn<String> fromEndpoint = GeneratedColumn<String>(
    'from_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toEndpointMeta = const VerificationMeta('toEndpoint');
  @override
  late final GeneratedColumn<String> toEndpoint = GeneratedColumn<String>(
    'to_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesSearchedMeta = const VerificationMeta('timesSearched');
  @override
  late final GeneratedColumn<int> timesSearched = GeneratedColumn<int>(
    'times_searched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSearchedAtMeta = const VerificationMeta('lastSearchedAt');
  @override
  late final GeneratedColumn<int> lastSearchedAt = GeneratedColumn<int>(
    'last_searched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fromEndpoint, toEndpoint, timesSearched, lastSearchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(Insertable<RecentSearch> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_endpoint')) {
      context.handle(_fromEndpointMeta, fromEndpoint.isAcceptableOrUnknown(data['from_endpoint']!, _fromEndpointMeta));
    } else if (isInserting) {
      context.missing(_fromEndpointMeta);
    }
    if (data.containsKey('to_endpoint')) {
      context.handle(_toEndpointMeta, toEndpoint.isAcceptableOrUnknown(data['to_endpoint']!, _toEndpointMeta));
    } else if (isInserting) {
      context.missing(_toEndpointMeta);
    }
    if (data.containsKey('times_searched')) {
      context.handle(
        _timesSearchedMeta,
        timesSearched.isAcceptableOrUnknown(data['times_searched']!, _timesSearchedMeta),
      );
    }
    if (data.containsKey('last_searched_at')) {
      context.handle(
        _lastSearchedAtMeta,
        lastSearchedAt.isAcceptableOrUnknown(data['last_searched_at']!, _lastSearchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSearchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentSearch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearch(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}from_endpoint'])!,
      toEndpoint: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}to_endpoint'])!,
      timesSearched: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}times_searched'])!,
      lastSearchedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_searched_at'])!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearch extends DataClass implements Insertable<RecentSearch> {
  final String id;
  final String fromEndpoint;
  final String toEndpoint;
  final int timesSearched;
  final int lastSearchedAt;
  const RecentSearch({
    required this.id,
    required this.fromEndpoint,
    required this.toEndpoint,
    required this.timesSearched,
    required this.lastSearchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_endpoint'] = Variable<String>(fromEndpoint);
    map['to_endpoint'] = Variable<String>(toEndpoint);
    map['times_searched'] = Variable<int>(timesSearched);
    map['last_searched_at'] = Variable<int>(lastSearchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      fromEndpoint: Value(fromEndpoint),
      toEndpoint: Value(toEndpoint),
      timesSearched: Value(timesSearched),
      lastSearchedAt: Value(lastSearchedAt),
    );
  }

  factory RecentSearch.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearch(
      id: serializer.fromJson<String>(json['id']),
      fromEndpoint: serializer.fromJson<String>(json['fromEndpoint']),
      toEndpoint: serializer.fromJson<String>(json['toEndpoint']),
      timesSearched: serializer.fromJson<int>(json['timesSearched']),
      lastSearchedAt: serializer.fromJson<int>(json['lastSearchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromEndpoint': serializer.toJson<String>(fromEndpoint),
      'toEndpoint': serializer.toJson<String>(toEndpoint),
      'timesSearched': serializer.toJson<int>(timesSearched),
      'lastSearchedAt': serializer.toJson<int>(lastSearchedAt),
    };
  }

  RecentSearch copyWith({
    String? id,
    String? fromEndpoint,
    String? toEndpoint,
    int? timesSearched,
    int? lastSearchedAt,
  }) => RecentSearch(
    id: id ?? this.id,
    fromEndpoint: fromEndpoint ?? this.fromEndpoint,
    toEndpoint: toEndpoint ?? this.toEndpoint,
    timesSearched: timesSearched ?? this.timesSearched,
    lastSearchedAt: lastSearchedAt ?? this.lastSearchedAt,
  );
  RecentSearch copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearch(
      id: data.id.present ? data.id.value : this.id,
      fromEndpoint: data.fromEndpoint.present ? data.fromEndpoint.value : this.fromEndpoint,
      toEndpoint: data.toEndpoint.present ? data.toEndpoint.value : this.toEndpoint,
      timesSearched: data.timesSearched.present ? data.timesSearched.value : this.timesSearched,
      lastSearchedAt: data.lastSearchedAt.present ? data.lastSearchedAt.value : this.lastSearchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearch(')
          ..write('id: $id, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('timesSearched: $timesSearched, ')
          ..write('lastSearchedAt: $lastSearchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromEndpoint, toEndpoint, timesSearched, lastSearchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearch &&
          other.id == this.id &&
          other.fromEndpoint == this.fromEndpoint &&
          other.toEndpoint == this.toEndpoint &&
          other.timesSearched == this.timesSearched &&
          other.lastSearchedAt == this.lastSearchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearch> {
  final Value<String> id;
  final Value<String> fromEndpoint;
  final Value<String> toEndpoint;
  final Value<int> timesSearched;
  final Value<int> lastSearchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.fromEndpoint = const Value.absent(),
    this.toEndpoint = const Value.absent(),
    this.timesSearched = const Value.absent(),
    this.lastSearchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String id,
    required String fromEndpoint,
    required String toEndpoint,
    this.timesSearched = const Value.absent(),
    required int lastSearchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromEndpoint = Value(fromEndpoint),
       toEndpoint = Value(toEndpoint),
       lastSearchedAt = Value(lastSearchedAt);
  static Insertable<RecentSearch> custom({
    Expression<String>? id,
    Expression<String>? fromEndpoint,
    Expression<String>? toEndpoint,
    Expression<int>? timesSearched,
    Expression<int>? lastSearchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromEndpoint != null) 'from_endpoint': fromEndpoint,
      if (toEndpoint != null) 'to_endpoint': toEndpoint,
      if (timesSearched != null) 'times_searched': timesSearched,
      if (lastSearchedAt != null) 'last_searched_at': lastSearchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<String>? id,
    Value<String>? fromEndpoint,
    Value<String>? toEndpoint,
    Value<int>? timesSearched,
    Value<int>? lastSearchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      fromEndpoint: fromEndpoint ?? this.fromEndpoint,
      toEndpoint: toEndpoint ?? this.toEndpoint,
      timesSearched: timesSearched ?? this.timesSearched,
      lastSearchedAt: lastSearchedAt ?? this.lastSearchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromEndpoint.present) {
      map['from_endpoint'] = Variable<String>(fromEndpoint.value);
    }
    if (toEndpoint.present) {
      map['to_endpoint'] = Variable<String>(toEndpoint.value);
    }
    if (timesSearched.present) {
      map['times_searched'] = Variable<int>(timesSearched.value);
    }
    if (lastSearchedAt.present) {
      map['last_searched_at'] = Variable<int>(lastSearchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('fromEndpoint: $fromEndpoint, ')
          ..write('toEndpoint: $toEndpoint, ')
          ..write('timesSearched: $timesSearched, ')
          ..write('lastSearchedAt: $lastSearchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxMessagesTable extends InboxMessages with TableInfo<$InboxMessagesTable, InboxMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, title, body, createdAt, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_messages';
  @override
  VerificationContext validateIntegrity(Insertable<InboxMessage> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta, isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxMessage(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      isRead: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $InboxMessagesTable createAlias(String alias) {
    return $InboxMessagesTable(attachedDatabase, alias);
  }
}

class InboxMessage extends DataClass implements Insertable<InboxMessage> {
  final int id;
  final String kind;
  final String title;
  final String body;
  final int createdAt;
  final bool isRead;
  const InboxMessage({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<int>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  InboxMessagesCompanion toCompanion(bool nullToAbsent) {
    return InboxMessagesCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory InboxMessage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxMessage(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  InboxMessage copyWith({int? id, String? kind, String? title, String? body, int? createdAt, bool? isRead}) =>
      InboxMessage(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );
  InboxMessage copyWithCompanion(InboxMessagesCompanion data) {
    return InboxMessage(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxMessage(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, title, body, createdAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxMessage &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class InboxMessagesCompanion extends UpdateCompanion<InboxMessage> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<int> createdAt;
  final Value<bool> isRead;
  const InboxMessagesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  InboxMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String title,
    required String body,
    required int createdAt,
    this.isRead = const Value.absent(),
  }) : kind = Value(kind),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<InboxMessage> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
    });
  }

  InboxMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<int>? createdAt,
    Value<bool>? isRead,
  }) {
    return InboxMessagesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxMessagesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues with TableInfo<$KeyValuesTable, KeyValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(Insertable<KeyValue> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValue(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValue extends DataClass implements Insertable<KeyValue> {
  final String key;
  final String value;
  const KeyValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValue.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValue(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  KeyValue copyWith({String? key, String? value}) => KeyValue(key: key ?? this.key, value: value ?? this.value);
  KeyValue copyWithCompanion(KeyValuesCompanion data) {
    return KeyValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValue(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is KeyValue && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<KeyValue> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return KeyValuesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OperatorsTable operators = $OperatorsTable(this);
  late final $StopsTable stops = $StopsTable(this);
  late final $BusRoutesTable busRoutes = $BusRoutesTable(this);
  late final $TimetablesTable timetables = $TimetablesTable(this);
  late final $TimetableNotesTable timetableNotes = $TimetableNotesTable(this);
  late final $ApiCacheTable apiCache = $ApiCacheTable(this);
  late final $SavedJourneysTable savedJourneys = $SavedJourneysTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $SavedTripsTable savedTrips = $SavedTripsTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $InboxMessagesTable inboxMessages = $InboxMessagesTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    operators,
    stops,
    busRoutes,
    timetables,
    timetableNotes,
    apiCache,
    savedJourneys,
    places,
    savedTrips,
    recentSearches,
    inboxMessages,
    keyValues,
  ];
}

typedef $$OperatorsTableCreateCompanionBuilder =
    OperatorsCompanion Function({
      required String code,
      required String name,
      required String kind,
      Value<int> routeCount,
      Value<int> rowid,
    });
typedef $$OperatorsTableUpdateCompanionBuilder =
    OperatorsCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> kind,
      Value<int> routeCount,
      Value<int> rowid,
    });

class $$OperatorsTableFilterComposer extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routeCount =>
      $composableBuilder(column: $table.routeCount, builder: (column) => ColumnFilters(column));
}

class $$OperatorsTableOrderingComposer extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routeCount =>
      $composableBuilder(column: $table.routeCount, builder: (column) => ColumnOrderings(column));
}

class $$OperatorsTableAnnotationComposer extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code => $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get routeCount => $composableBuilder(column: $table.routeCount, builder: (column) => column);
}

class $$OperatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperatorsTable,
          Operator,
          $$OperatorsTableFilterComposer,
          $$OperatorsTableOrderingComposer,
          $$OperatorsTableAnnotationComposer,
          $$OperatorsTableCreateCompanionBuilder,
          $$OperatorsTableUpdateCompanionBuilder,
          (Operator, BaseReferences<_$AppDatabase, $OperatorsTable, Operator>),
          Operator,
          PrefetchHooks Function()
        > {
  $$OperatorsTableTableManager(_$AppDatabase db, $OperatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OperatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OperatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OperatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> routeCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperatorsCompanion(code: code, name: name, kind: kind, routeCount: routeCount, rowid: rowid),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String kind,
                Value<int> routeCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperatorsCompanion.insert(code: code, name: name, kind: kind, routeCount: routeCount, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperatorsTable,
      Operator,
      $$OperatorsTableFilterComposer,
      $$OperatorsTableOrderingComposer,
      $$OperatorsTableAnnotationComposer,
      $$OperatorsTableCreateCompanionBuilder,
      $$OperatorsTableUpdateCompanionBuilder,
      (Operator, BaseReferences<_$AppDatabase, $OperatorsTable, Operator>),
      Operator,
      PrefetchHooks Function()
    >;
typedef $$StopsTableCreateCompanionBuilder =
    StopsCompanion Function({
      Value<int> id,
      required String name,
      required double lat,
      required double lon,
      Value<String> operatorCode,
      Value<String> operatorKind,
    });
typedef $$StopsTableUpdateCompanionBuilder =
    StopsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> lat,
      Value<double> lon,
      Value<String> operatorCode,
      Value<String> operatorKind,
    });

class $$StopsTableFilterComposer extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => ColumnFilters(column));
}

class $$StopsTableOrderingComposer extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => ColumnOrderings(column));
}

class $$StopsTableAnnotationComposer extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon => $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => column);

  GeneratedColumn<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => column);
}

class $$StopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StopsTable,
          Stop,
          $$StopsTableFilterComposer,
          $$StopsTableOrderingComposer,
          $$StopsTableAnnotationComposer,
          $$StopsTableCreateCompanionBuilder,
          $$StopsTableUpdateCompanionBuilder,
          (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
          Stop,
          PrefetchHooks Function()
        > {
  $$StopsTableTableManager(_$AppDatabase db, $StopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<String> operatorCode = const Value.absent(),
                Value<String> operatorKind = const Value.absent(),
              }) => StopsCompanion(
                id: id,
                name: name,
                lat: lat,
                lon: lon,
                operatorCode: operatorCode,
                operatorKind: operatorKind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double lat,
                required double lon,
                Value<String> operatorCode = const Value.absent(),
                Value<String> operatorKind = const Value.absent(),
              }) => StopsCompanion.insert(
                id: id,
                name: name,
                lat: lat,
                lon: lon,
                operatorCode: operatorCode,
                operatorKind: operatorKind,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StopsTable,
      Stop,
      $$StopsTableFilterComposer,
      $$StopsTableOrderingComposer,
      $$StopsTableAnnotationComposer,
      $$StopsTableCreateCompanionBuilder,
      $$StopsTableUpdateCompanionBuilder,
      (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
      Stop,
      PrefetchHooks Function()
    >;
typedef $$BusRoutesTableCreateCompanionBuilder =
    BusRoutesCompanion Function({
      Value<int> id,
      required String name,
      required String origin,
      required String destination,
      required String letterGroup,
      Value<int> timetableCount,
      Value<String> operatorCode,
    });
typedef $$BusRoutesTableUpdateCompanionBuilder =
    BusRoutesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> origin,
      Value<String> destination,
      Value<String> letterGroup,
      Value<int> timetableCount,
      Value<String> operatorCode,
    });

class $$BusRoutesTableFilterComposer extends Composer<_$AppDatabase, $BusRoutesTable> {
  $$BusRoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get letterGroup =>
      $composableBuilder(column: $table.letterGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timetableCount =>
      $composableBuilder(column: $table.timetableCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnFilters(column));
}

class $$BusRoutesTableOrderingComposer extends Composer<_$AppDatabase, $BusRoutesTable> {
  $$BusRoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get letterGroup =>
      $composableBuilder(column: $table.letterGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timetableCount =>
      $composableBuilder(column: $table.timetableCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnOrderings(column));
}

class $$BusRoutesTableAnnotationComposer extends Composer<_$AppDatabase, $BusRoutesTable> {
  $$BusRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get origin => $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => column);

  GeneratedColumn<String> get letterGroup =>
      $composableBuilder(column: $table.letterGroup, builder: (column) => column);

  GeneratedColumn<int> get timetableCount =>
      $composableBuilder(column: $table.timetableCount, builder: (column) => column);

  GeneratedColumn<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => column);
}

class $$BusRoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusRoutesTable,
          BusRoute,
          $$BusRoutesTableFilterComposer,
          $$BusRoutesTableOrderingComposer,
          $$BusRoutesTableAnnotationComposer,
          $$BusRoutesTableCreateCompanionBuilder,
          $$BusRoutesTableUpdateCompanionBuilder,
          (BusRoute, BaseReferences<_$AppDatabase, $BusRoutesTable, BusRoute>),
          BusRoute,
          PrefetchHooks Function()
        > {
  $$BusRoutesTableTableManager(_$AppDatabase db, $BusRoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BusRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BusRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BusRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String> letterGroup = const Value.absent(),
                Value<int> timetableCount = const Value.absent(),
                Value<String> operatorCode = const Value.absent(),
              }) => BusRoutesCompanion(
                id: id,
                name: name,
                origin: origin,
                destination: destination,
                letterGroup: letterGroup,
                timetableCount: timetableCount,
                operatorCode: operatorCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String origin,
                required String destination,
                required String letterGroup,
                Value<int> timetableCount = const Value.absent(),
                Value<String> operatorCode = const Value.absent(),
              }) => BusRoutesCompanion.insert(
                id: id,
                name: name,
                origin: origin,
                destination: destination,
                letterGroup: letterGroup,
                timetableCount: timetableCount,
                operatorCode: operatorCode,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusRoutesTable,
      BusRoute,
      $$BusRoutesTableFilterComposer,
      $$BusRoutesTableOrderingComposer,
      $$BusRoutesTableAnnotationComposer,
      $$BusRoutesTableCreateCompanionBuilder,
      $$BusRoutesTableUpdateCompanionBuilder,
      (BusRoute, BaseReferences<_$AppDatabase, $BusRoutesTable, BusRoute>),
      BusRoute,
      PrefetchHooks Function()
    >;
typedef $$TimetablesTableCreateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      required int routeId,
      required String timetableNumber,
      Value<bool> isPublicHoliday,
      Value<String?> effectiveFrom,
      Value<String?> effectiveTo,
      Value<String?> pdfUrl,
    });
typedef $$TimetablesTableUpdateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      Value<int> routeId,
      Value<String> timetableNumber,
      Value<bool> isPublicHoliday,
      Value<String?> effectiveFrom,
      Value<String?> effectiveTo,
      Value<String?> pdfUrl,
    });

class $$TimetablesTableFilterComposer extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublicHoliday =>
      $composableBuilder(column: $table.isPublicHoliday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get effectiveFrom =>
      $composableBuilder(column: $table.effectiveFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get effectiveTo =>
      $composableBuilder(column: $table.effectiveTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfUrl =>
      $composableBuilder(column: $table.pdfUrl, builder: (column) => ColumnFilters(column));
}

class $$TimetablesTableOrderingComposer extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublicHoliday =>
      $composableBuilder(column: $table.isPublicHoliday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get effectiveFrom =>
      $composableBuilder(column: $table.effectiveFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get effectiveTo =>
      $composableBuilder(column: $table.effectiveTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfUrl =>
      $composableBuilder(column: $table.pdfUrl, builder: (column) => ColumnOrderings(column));
}

class $$TimetablesTableAnnotationComposer extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routeId => $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => column);

  GeneratedColumn<bool> get isPublicHoliday =>
      $composableBuilder(column: $table.isPublicHoliday, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom =>
      $composableBuilder(column: $table.effectiveFrom, builder: (column) => column);

  GeneratedColumn<String> get effectiveTo =>
      $composableBuilder(column: $table.effectiveTo, builder: (column) => column);

  GeneratedColumn<String> get pdfUrl => $composableBuilder(column: $table.pdfUrl, builder: (column) => column);
}

class $$TimetablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetablesTable,
          Timetable,
          $$TimetablesTableFilterComposer,
          $$TimetablesTableOrderingComposer,
          $$TimetablesTableAnnotationComposer,
          $$TimetablesTableCreateCompanionBuilder,
          $$TimetablesTableUpdateCompanionBuilder,
          (Timetable, BaseReferences<_$AppDatabase, $TimetablesTable, Timetable>),
          Timetable,
          PrefetchHooks Function()
        > {
  $$TimetablesTableTableManager(_$AppDatabase db, $TimetablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TimetablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TimetablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TimetablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<String> timetableNumber = const Value.absent(),
                Value<bool> isPublicHoliday = const Value.absent(),
                Value<String?> effectiveFrom = const Value.absent(),
                Value<String?> effectiveTo = const Value.absent(),
                Value<String?> pdfUrl = const Value.absent(),
              }) => TimetablesCompanion(
                id: id,
                routeId: routeId,
                timetableNumber: timetableNumber,
                isPublicHoliday: isPublicHoliday,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                pdfUrl: pdfUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required String timetableNumber,
                Value<bool> isPublicHoliday = const Value.absent(),
                Value<String?> effectiveFrom = const Value.absent(),
                Value<String?> effectiveTo = const Value.absent(),
                Value<String?> pdfUrl = const Value.absent(),
              }) => TimetablesCompanion.insert(
                id: id,
                routeId: routeId,
                timetableNumber: timetableNumber,
                isPublicHoliday: isPublicHoliday,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                pdfUrl: pdfUrl,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetablesTable,
      Timetable,
      $$TimetablesTableFilterComposer,
      $$TimetablesTableOrderingComposer,
      $$TimetablesTableAnnotationComposer,
      $$TimetablesTableCreateCompanionBuilder,
      $$TimetablesTableUpdateCompanionBuilder,
      (Timetable, BaseReferences<_$AppDatabase, $TimetablesTable, Timetable>),
      Timetable,
      PrefetchHooks Function()
    >;
typedef $$TimetableNotesTableCreateCompanionBuilder =
    TimetableNotesCompanion Function({
      required int timetableId,
      required String code,
      required String description,
      Value<int> rowid,
    });
typedef $$TimetableNotesTableUpdateCompanionBuilder =
    TimetableNotesCompanion Function({
      Value<int> timetableId,
      Value<String> code,
      Value<String> description,
      Value<int> rowid,
    });

class $$TimetableNotesTableFilterComposer extends Composer<_$AppDatabase, $TimetableNotesTable> {
  $$TimetableNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get timetableId =>
      $composableBuilder(column: $table.timetableId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$TimetableNotesTableOrderingComposer extends Composer<_$AppDatabase, $TimetableNotesTable> {
  $$TimetableNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get timetableId =>
      $composableBuilder(column: $table.timetableId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$TimetableNotesTableAnnotationComposer extends Composer<_$AppDatabase, $TimetableNotesTable> {
  $$TimetableNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get timetableId => $composableBuilder(column: $table.timetableId, builder: (column) => column);

  GeneratedColumn<String> get code => $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);
}

class $$TimetableNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableNotesTable,
          TimetableNote,
          $$TimetableNotesTableFilterComposer,
          $$TimetableNotesTableOrderingComposer,
          $$TimetableNotesTableAnnotationComposer,
          $$TimetableNotesTableCreateCompanionBuilder,
          $$TimetableNotesTableUpdateCompanionBuilder,
          (TimetableNote, BaseReferences<_$AppDatabase, $TimetableNotesTable, TimetableNote>),
          TimetableNote,
          PrefetchHooks Function()
        > {
  $$TimetableNotesTableTableManager(_$AppDatabase db, $TimetableNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TimetableNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TimetableNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TimetableNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> timetableId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  TimetableNotesCompanion(timetableId: timetableId, code: code, description: description, rowid: rowid),
          createCompanionCallback:
              ({
                required int timetableId,
                required String code,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => TimetableNotesCompanion.insert(
                timetableId: timetableId,
                code: code,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetableNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableNotesTable,
      TimetableNote,
      $$TimetableNotesTableFilterComposer,
      $$TimetableNotesTableOrderingComposer,
      $$TimetableNotesTableAnnotationComposer,
      $$TimetableNotesTableCreateCompanionBuilder,
      $$TimetableNotesTableUpdateCompanionBuilder,
      (TimetableNote, BaseReferences<_$AppDatabase, $TimetableNotesTable, TimetableNote>),
      TimetableNote,
      PrefetchHooks Function()
    >;
typedef $$ApiCacheTableCreateCompanionBuilder =
    ApiCacheCompanion Function({
      required String cacheKey,
      required String body,
      required int fetchedAt,
      required int lastUsedAt,
      required String dataVersion,
      required int sizeBytes,
      Value<bool> pinned,
      Value<int> rowid,
    });
typedef $$ApiCacheTableUpdateCompanionBuilder =
    ApiCacheCompanion Function({
      Value<String> cacheKey,
      Value<String> body,
      Value<int> fetchedAt,
      Value<int> lastUsedAt,
      Value<String> dataVersion,
      Value<int> sizeBytes,
      Value<bool> pinned,
      Value<int> rowid,
    });

class $$ApiCacheTableFilterComposer extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUsedAt =>
      $composableBuilder(column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataVersion =>
      $composableBuilder(column: $table.dataVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => ColumnFilters(column));
}

class $$ApiCacheTableOrderingComposer extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUsedAt =>
      $composableBuilder(column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataVersion =>
      $composableBuilder(column: $table.dataVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => ColumnOrderings(column));
}

class $$ApiCacheTableAnnotationComposer extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey => $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt => $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<String> get dataVersion =>
      $composableBuilder(column: $table.dataVersion, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes => $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get pinned => $composableBuilder(column: $table.pinned, builder: (column) => column);
}

class $$ApiCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiCacheTable,
          CachedResponse,
          $$ApiCacheTableFilterComposer,
          $$ApiCacheTableOrderingComposer,
          $$ApiCacheTableAnnotationComposer,
          $$ApiCacheTableCreateCompanionBuilder,
          $$ApiCacheTableUpdateCompanionBuilder,
          (CachedResponse, BaseReferences<_$AppDatabase, $ApiCacheTable, CachedResponse>),
          CachedResponse,
          PrefetchHooks Function()
        > {
  $$ApiCacheTableTableManager(_$AppDatabase db, $ApiCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ApiCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ApiCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ApiCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> lastUsedAt = const Value.absent(),
                Value<String> dataVersion = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion(
                cacheKey: cacheKey,
                body: body,
                fetchedAt: fetchedAt,
                lastUsedAt: lastUsedAt,
                dataVersion: dataVersion,
                sizeBytes: sizeBytes,
                pinned: pinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String body,
                required int fetchedAt,
                required int lastUsedAt,
                required String dataVersion,
                required int sizeBytes,
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion.insert(
                cacheKey: cacheKey,
                body: body,
                fetchedAt: fetchedAt,
                lastUsedAt: lastUsedAt,
                dataVersion: dataVersion,
                sizeBytes: sizeBytes,
                pinned: pinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiCacheTable,
      CachedResponse,
      $$ApiCacheTableFilterComposer,
      $$ApiCacheTableOrderingComposer,
      $$ApiCacheTableAnnotationComposer,
      $$ApiCacheTableCreateCompanionBuilder,
      $$ApiCacheTableUpdateCompanionBuilder,
      (CachedResponse, BaseReferences<_$AppDatabase, $ApiCacheTable, CachedResponse>),
      CachedResponse,
      PrefetchHooks Function()
    >;
typedef $$SavedJourneysTableCreateCompanionBuilder =
    SavedJourneysCompanion Function({
      required String id,
      required String serviceDate,
      required String fromEndpoint,
      required String toEndpoint,
      required String routeLabel,
      Value<String> operatorCode,
      Value<String> operatorName,
      Value<String> operatorKind,
      Value<int?> cashFareCents,
      required String timetableNumber,
      required String dayType,
      required String dayLabel,
      required String boardRaw,
      required String arriveRaw,
      required double boardMinutes,
      Value<double?> arriveMinutes,
      required bool boardApprox,
      required bool arriveApprox,
      required int scheduleId,
      required int tripIndex,
      required int fromSeq,
      required int toSeq,
      Value<String?> tripSnapshot,
      Value<String> status,
      Value<int?> reminderLeadMinutes,
      Value<String?> groupId,
      Value<String?> boardLabel,
      Value<String?> alightLabel,
      required int createdAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });
typedef $$SavedJourneysTableUpdateCompanionBuilder =
    SavedJourneysCompanion Function({
      Value<String> id,
      Value<String> serviceDate,
      Value<String> fromEndpoint,
      Value<String> toEndpoint,
      Value<String> routeLabel,
      Value<String> operatorCode,
      Value<String> operatorName,
      Value<String> operatorKind,
      Value<int?> cashFareCents,
      Value<String> timetableNumber,
      Value<String> dayType,
      Value<String> dayLabel,
      Value<String> boardRaw,
      Value<String> arriveRaw,
      Value<double> boardMinutes,
      Value<double?> arriveMinutes,
      Value<bool> boardApprox,
      Value<bool> arriveApprox,
      Value<int> scheduleId,
      Value<int> tripIndex,
      Value<int> fromSeq,
      Value<int> toSeq,
      Value<String?> tripSnapshot,
      Value<String> status,
      Value<int?> reminderLeadMinutes,
      Value<String?> groupId,
      Value<String?> boardLabel,
      Value<String?> alightLabel,
      Value<int> createdAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });

class $$SavedJourneysTableFilterComposer extends Composer<_$AppDatabase, $SavedJourneysTable> {
  $$SavedJourneysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceDate =>
      $composableBuilder(column: $table.serviceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeLabel =>
      $composableBuilder(column: $table.routeLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorName =>
      $composableBuilder(column: $table.operatorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cashFareCents =>
      $composableBuilder(column: $table.cashFareCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayType =>
      $composableBuilder(column: $table.dayType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayLabel =>
      $composableBuilder(column: $table.dayLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boardRaw =>
      $composableBuilder(column: $table.boardRaw, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get arriveRaw =>
      $composableBuilder(column: $table.arriveRaw, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boardMinutes =>
      $composableBuilder(column: $table.boardMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get arriveMinutes =>
      $composableBuilder(column: $table.arriveMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get boardApprox =>
      $composableBuilder(column: $table.boardApprox, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get arriveApprox =>
      $composableBuilder(column: $table.arriveApprox, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduleId =>
      $composableBuilder(column: $table.scheduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tripIndex =>
      $composableBuilder(column: $table.tripIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fromSeq =>
      $composableBuilder(column: $table.fromSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toSeq => $composableBuilder(column: $table.toSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripSnapshot =>
      $composableBuilder(column: $table.tripSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderLeadMinutes =>
      $composableBuilder(column: $table.reminderLeadMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boardLabel =>
      $composableBuilder(column: $table.boardLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alightLabel =>
      $composableBuilder(column: $table.alightLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$SavedJourneysTableOrderingComposer extends Composer<_$AppDatabase, $SavedJourneysTable> {
  $$SavedJourneysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceDate =>
      $composableBuilder(column: $table.serviceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeLabel =>
      $composableBuilder(column: $table.routeLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorName =>
      $composableBuilder(column: $table.operatorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cashFareCents =>
      $composableBuilder(column: $table.cashFareCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayType =>
      $composableBuilder(column: $table.dayType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayLabel =>
      $composableBuilder(column: $table.dayLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boardRaw =>
      $composableBuilder(column: $table.boardRaw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get arriveRaw =>
      $composableBuilder(column: $table.arriveRaw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boardMinutes =>
      $composableBuilder(column: $table.boardMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get arriveMinutes =>
      $composableBuilder(column: $table.arriveMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get boardApprox =>
      $composableBuilder(column: $table.boardApprox, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get arriveApprox =>
      $composableBuilder(column: $table.arriveApprox, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduleId =>
      $composableBuilder(column: $table.scheduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tripIndex =>
      $composableBuilder(column: $table.tripIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fromSeq =>
      $composableBuilder(column: $table.fromSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toSeq =>
      $composableBuilder(column: $table.toSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripSnapshot =>
      $composableBuilder(column: $table.tripSnapshot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderLeadMinutes =>
      $composableBuilder(column: $table.reminderLeadMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boardLabel =>
      $composableBuilder(column: $table.boardLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alightLabel =>
      $composableBuilder(column: $table.alightLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedJourneysTableAnnotationComposer extends Composer<_$AppDatabase, $SavedJourneysTable> {
  $$SavedJourneysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceDate =>
      $composableBuilder(column: $table.serviceDate, builder: (column) => column);

  GeneratedColumn<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => column);

  GeneratedColumn<String> get toEndpoint => $composableBuilder(column: $table.toEndpoint, builder: (column) => column);

  GeneratedColumn<String> get routeLabel => $composableBuilder(column: $table.routeLabel, builder: (column) => column);

  GeneratedColumn<String> get operatorCode =>
      $composableBuilder(column: $table.operatorCode, builder: (column) => column);

  GeneratedColumn<String> get operatorName =>
      $composableBuilder(column: $table.operatorName, builder: (column) => column);

  GeneratedColumn<String> get operatorKind =>
      $composableBuilder(column: $table.operatorKind, builder: (column) => column);

  GeneratedColumn<int> get cashFareCents =>
      $composableBuilder(column: $table.cashFareCents, builder: (column) => column);

  GeneratedColumn<String> get timetableNumber =>
      $composableBuilder(column: $table.timetableNumber, builder: (column) => column);

  GeneratedColumn<String> get dayType => $composableBuilder(column: $table.dayType, builder: (column) => column);

  GeneratedColumn<String> get dayLabel => $composableBuilder(column: $table.dayLabel, builder: (column) => column);

  GeneratedColumn<String> get boardRaw => $composableBuilder(column: $table.boardRaw, builder: (column) => column);

  GeneratedColumn<String> get arriveRaw => $composableBuilder(column: $table.arriveRaw, builder: (column) => column);

  GeneratedColumn<double> get boardMinutes =>
      $composableBuilder(column: $table.boardMinutes, builder: (column) => column);

  GeneratedColumn<double> get arriveMinutes =>
      $composableBuilder(column: $table.arriveMinutes, builder: (column) => column);

  GeneratedColumn<bool> get boardApprox => $composableBuilder(column: $table.boardApprox, builder: (column) => column);

  GeneratedColumn<bool> get arriveApprox =>
      $composableBuilder(column: $table.arriveApprox, builder: (column) => column);

  GeneratedColumn<int> get scheduleId => $composableBuilder(column: $table.scheduleId, builder: (column) => column);

  GeneratedColumn<int> get tripIndex => $composableBuilder(column: $table.tripIndex, builder: (column) => column);

  GeneratedColumn<int> get fromSeq => $composableBuilder(column: $table.fromSeq, builder: (column) => column);

  GeneratedColumn<int> get toSeq => $composableBuilder(column: $table.toSeq, builder: (column) => column);

  GeneratedColumn<String> get tripSnapshot =>
      $composableBuilder(column: $table.tripSnapshot, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get reminderLeadMinutes =>
      $composableBuilder(column: $table.reminderLeadMinutes, builder: (column) => column);

  GeneratedColumn<String> get groupId => $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get boardLabel => $composableBuilder(column: $table.boardLabel, builder: (column) => column);

  GeneratedColumn<String> get alightLabel =>
      $composableBuilder(column: $table.alightLabel, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(column: $table.completedAt, builder: (column) => column);
}

class $$SavedJourneysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedJourneysTable,
          SavedJourney,
          $$SavedJourneysTableFilterComposer,
          $$SavedJourneysTableOrderingComposer,
          $$SavedJourneysTableAnnotationComposer,
          $$SavedJourneysTableCreateCompanionBuilder,
          $$SavedJourneysTableUpdateCompanionBuilder,
          (SavedJourney, BaseReferences<_$AppDatabase, $SavedJourneysTable, SavedJourney>),
          SavedJourney,
          PrefetchHooks Function()
        > {
  $$SavedJourneysTableTableManager(_$AppDatabase db, $SavedJourneysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavedJourneysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavedJourneysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SavedJourneysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serviceDate = const Value.absent(),
                Value<String> fromEndpoint = const Value.absent(),
                Value<String> toEndpoint = const Value.absent(),
                Value<String> routeLabel = const Value.absent(),
                Value<String> operatorCode = const Value.absent(),
                Value<String> operatorName = const Value.absent(),
                Value<String> operatorKind = const Value.absent(),
                Value<int?> cashFareCents = const Value.absent(),
                Value<String> timetableNumber = const Value.absent(),
                Value<String> dayType = const Value.absent(),
                Value<String> dayLabel = const Value.absent(),
                Value<String> boardRaw = const Value.absent(),
                Value<String> arriveRaw = const Value.absent(),
                Value<double> boardMinutes = const Value.absent(),
                Value<double?> arriveMinutes = const Value.absent(),
                Value<bool> boardApprox = const Value.absent(),
                Value<bool> arriveApprox = const Value.absent(),
                Value<int> scheduleId = const Value.absent(),
                Value<int> tripIndex = const Value.absent(),
                Value<int> fromSeq = const Value.absent(),
                Value<int> toSeq = const Value.absent(),
                Value<String?> tripSnapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> reminderLeadMinutes = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> boardLabel = const Value.absent(),
                Value<String?> alightLabel = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedJourneysCompanion(
                id: id,
                serviceDate: serviceDate,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                routeLabel: routeLabel,
                operatorCode: operatorCode,
                operatorName: operatorName,
                operatorKind: operatorKind,
                cashFareCents: cashFareCents,
                timetableNumber: timetableNumber,
                dayType: dayType,
                dayLabel: dayLabel,
                boardRaw: boardRaw,
                arriveRaw: arriveRaw,
                boardMinutes: boardMinutes,
                arriveMinutes: arriveMinutes,
                boardApprox: boardApprox,
                arriveApprox: arriveApprox,
                scheduleId: scheduleId,
                tripIndex: tripIndex,
                fromSeq: fromSeq,
                toSeq: toSeq,
                tripSnapshot: tripSnapshot,
                status: status,
                reminderLeadMinutes: reminderLeadMinutes,
                groupId: groupId,
                boardLabel: boardLabel,
                alightLabel: alightLabel,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serviceDate,
                required String fromEndpoint,
                required String toEndpoint,
                required String routeLabel,
                Value<String> operatorCode = const Value.absent(),
                Value<String> operatorName = const Value.absent(),
                Value<String> operatorKind = const Value.absent(),
                Value<int?> cashFareCents = const Value.absent(),
                required String timetableNumber,
                required String dayType,
                required String dayLabel,
                required String boardRaw,
                required String arriveRaw,
                required double boardMinutes,
                Value<double?> arriveMinutes = const Value.absent(),
                required bool boardApprox,
                required bool arriveApprox,
                required int scheduleId,
                required int tripIndex,
                required int fromSeq,
                required int toSeq,
                Value<String?> tripSnapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> reminderLeadMinutes = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> boardLabel = const Value.absent(),
                Value<String?> alightLabel = const Value.absent(),
                required int createdAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedJourneysCompanion.insert(
                id: id,
                serviceDate: serviceDate,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                routeLabel: routeLabel,
                operatorCode: operatorCode,
                operatorName: operatorName,
                operatorKind: operatorKind,
                cashFareCents: cashFareCents,
                timetableNumber: timetableNumber,
                dayType: dayType,
                dayLabel: dayLabel,
                boardRaw: boardRaw,
                arriveRaw: arriveRaw,
                boardMinutes: boardMinutes,
                arriveMinutes: arriveMinutes,
                boardApprox: boardApprox,
                arriveApprox: arriveApprox,
                scheduleId: scheduleId,
                tripIndex: tripIndex,
                fromSeq: fromSeq,
                toSeq: toSeq,
                tripSnapshot: tripSnapshot,
                status: status,
                reminderLeadMinutes: reminderLeadMinutes,
                groupId: groupId,
                boardLabel: boardLabel,
                alightLabel: alightLabel,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedJourneysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedJourneysTable,
      SavedJourney,
      $$SavedJourneysTableFilterComposer,
      $$SavedJourneysTableOrderingComposer,
      $$SavedJourneysTableAnnotationComposer,
      $$SavedJourneysTableCreateCompanionBuilder,
      $$SavedJourneysTableUpdateCompanionBuilder,
      (SavedJourney, BaseReferences<_$AppDatabase, $SavedJourneysTable, SavedJourney>),
      SavedJourney,
      PrefetchHooks Function()
    >;
typedef $$PlacesTableCreateCompanionBuilder =
    PlacesCompanion Function({
      required String id,
      required String kind,
      required String label,
      required String endpointJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$PlacesTableUpdateCompanionBuilder =
    PlacesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> label,
      Value<String> endpointJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$PlacesTableFilterComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpointJson =>
      $composableBuilder(column: $table.endpointJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PlacesTableOrderingComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpointJson =>
      $composableBuilder(column: $table.endpointJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlacesTableAnnotationComposer extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get endpointJson =>
      $composableBuilder(column: $table.endpointJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          Place,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
          Place,
          PrefetchHooks Function()
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> endpointJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                kind: kind,
                label: label,
                endpointJson: endpointJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String label,
                required String endpointJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                kind: kind,
                label: label,
                endpointJson: endpointJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      Place,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
      Place,
      PrefetchHooks Function()
    >;
typedef $$SavedTripsTableCreateCompanionBuilder =
    SavedTripsCompanion Function({
      required String id,
      required String fromEndpoint,
      required String toEndpoint,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SavedTripsTableUpdateCompanionBuilder =
    SavedTripsCompanion Function({
      Value<String> id,
      Value<String> fromEndpoint,
      Value<String> toEndpoint,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SavedTripsTableFilterComposer extends Composer<_$AppDatabase, $SavedTripsTable> {
  $$SavedTripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SavedTripsTableOrderingComposer extends Composer<_$AppDatabase, $SavedTripsTable> {
  $$SavedTripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedTripsTableAnnotationComposer extends Composer<_$AppDatabase, $SavedTripsTable> {
  $$SavedTripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => column);

  GeneratedColumn<String> get toEndpoint => $composableBuilder(column: $table.toEndpoint, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedTripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedTripsTable,
          SavedTrip,
          $$SavedTripsTableFilterComposer,
          $$SavedTripsTableOrderingComposer,
          $$SavedTripsTableAnnotationComposer,
          $$SavedTripsTableCreateCompanionBuilder,
          $$SavedTripsTableUpdateCompanionBuilder,
          (SavedTrip, BaseReferences<_$AppDatabase, $SavedTripsTable, SavedTrip>),
          SavedTrip,
          PrefetchHooks Function()
        > {
  $$SavedTripsTableTableManager(_$AppDatabase db, $SavedTripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavedTripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavedTripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SavedTripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromEndpoint = const Value.absent(),
                Value<String> toEndpoint = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedTripsCompanion(
                id: id,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromEndpoint,
                required String toEndpoint,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedTripsCompanion.insert(
                id: id,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedTripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedTripsTable,
      SavedTrip,
      $$SavedTripsTableFilterComposer,
      $$SavedTripsTableOrderingComposer,
      $$SavedTripsTableAnnotationComposer,
      $$SavedTripsTableCreateCompanionBuilder,
      $$SavedTripsTableUpdateCompanionBuilder,
      (SavedTrip, BaseReferences<_$AppDatabase, $SavedTripsTable, SavedTrip>),
      SavedTrip,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required String id,
      required String fromEndpoint,
      required String toEndpoint,
      Value<int> timesSearched,
      required int lastSearchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<String> id,
      Value<String> fromEndpoint,
      Value<String> toEndpoint,
      Value<int> timesSearched,
      Value<int> lastSearchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesSearched =>
      $composableBuilder(column: $table.timesSearched, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSearchedAt =>
      $composableBuilder(column: $table.lastSearchedAt, builder: (column) => ColumnFilters(column));
}

class $$RecentSearchesTableOrderingComposer extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toEndpoint =>
      $composableBuilder(column: $table.toEndpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesSearched =>
      $composableBuilder(column: $table.timesSearched, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSearchedAt =>
      $composableBuilder(column: $table.lastSearchedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecentSearchesTableAnnotationComposer extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromEndpoint =>
      $composableBuilder(column: $table.fromEndpoint, builder: (column) => column);

  GeneratedColumn<String> get toEndpoint => $composableBuilder(column: $table.toEndpoint, builder: (column) => column);

  GeneratedColumn<int> get timesSearched =>
      $composableBuilder(column: $table.timesSearched, builder: (column) => column);

  GeneratedColumn<int> get lastSearchedAt =>
      $composableBuilder(column: $table.lastSearchedAt, builder: (column) => column);
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearch,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (RecentSearch, BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearch>),
          RecentSearch,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(_$AppDatabase db, $RecentSearchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromEndpoint = const Value.absent(),
                Value<String> toEndpoint = const Value.absent(),
                Value<int> timesSearched = const Value.absent(),
                Value<int> lastSearchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                id: id,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                timesSearched: timesSearched,
                lastSearchedAt: lastSearchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromEndpoint,
                required String toEndpoint,
                Value<int> timesSearched = const Value.absent(),
                required int lastSearchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                id: id,
                fromEndpoint: fromEndpoint,
                toEndpoint: toEndpoint,
                timesSearched: timesSearched,
                lastSearchedAt: lastSearchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearch,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (RecentSearch, BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearch>),
      RecentSearch,
      PrefetchHooks Function()
    >;
typedef $$InboxMessagesTableCreateCompanionBuilder =
    InboxMessagesCompanion Function({
      Value<int> id,
      required String kind,
      required String title,
      required String body,
      required int createdAt,
      Value<bool> isRead,
    });
typedef $$InboxMessagesTableUpdateCompanionBuilder =
    InboxMessagesCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> title,
      Value<String> body,
      Value<int> createdAt,
      Value<bool> isRead,
    });

class $$InboxMessagesTableFilterComposer extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => ColumnFilters(column));
}

class $$InboxMessagesTableOrderingComposer extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => ColumnOrderings(column));
}

class $$InboxMessagesTableAnnotationComposer extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead => $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$InboxMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxMessagesTable,
          InboxMessage,
          $$InboxMessagesTableFilterComposer,
          $$InboxMessagesTableOrderingComposer,
          $$InboxMessagesTableAnnotationComposer,
          $$InboxMessagesTableCreateCompanionBuilder,
          $$InboxMessagesTableUpdateCompanionBuilder,
          (InboxMessage, BaseReferences<_$AppDatabase, $InboxMessagesTable, InboxMessage>),
          InboxMessage,
          PrefetchHooks Function()
        > {
  $$InboxMessagesTableTableManager(_$AppDatabase db, $InboxMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$InboxMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$InboxMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$InboxMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
              }) => InboxMessagesCompanion(
                id: id,
                kind: kind,
                title: title,
                body: body,
                createdAt: createdAt,
                isRead: isRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String title,
                required String body,
                required int createdAt,
                Value<bool> isRead = const Value.absent(),
              }) => InboxMessagesCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                body: body,
                createdAt: createdAt,
                isRead: isRead,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxMessagesTable,
      InboxMessage,
      $$InboxMessagesTableFilterComposer,
      $$InboxMessagesTableOrderingComposer,
      $$InboxMessagesTableAnnotationComposer,
      $$InboxMessagesTableCreateCompanionBuilder,
      $$InboxMessagesTableUpdateCompanionBuilder,
      (InboxMessage, BaseReferences<_$AppDatabase, $InboxMessagesTable, InboxMessage>),
      InboxMessage,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$KeyValuesTableFilterComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$KeyValuesTableOrderingComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$KeyValuesTableAnnotationComposer extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValue,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
          KeyValue,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
                  KeyValuesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValue,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
      KeyValue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OperatorsTableTableManager get operators => $$OperatorsTableTableManager(_db, _db.operators);
  $$StopsTableTableManager get stops => $$StopsTableTableManager(_db, _db.stops);
  $$BusRoutesTableTableManager get busRoutes => $$BusRoutesTableTableManager(_db, _db.busRoutes);
  $$TimetablesTableTableManager get timetables => $$TimetablesTableTableManager(_db, _db.timetables);
  $$TimetableNotesTableTableManager get timetableNotes => $$TimetableNotesTableTableManager(_db, _db.timetableNotes);
  $$ApiCacheTableTableManager get apiCache => $$ApiCacheTableTableManager(_db, _db.apiCache);
  $$SavedJourneysTableTableManager get savedJourneys => $$SavedJourneysTableTableManager(_db, _db.savedJourneys);
  $$PlacesTableTableManager get places => $$PlacesTableTableManager(_db, _db.places);
  $$SavedTripsTableTableManager get savedTrips => $$SavedTripsTableTableManager(_db, _db.savedTrips);
  $$RecentSearchesTableTableManager get recentSearches => $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$InboxMessagesTableTableManager get inboxMessages => $$InboxMessagesTableTableManager(_db, _db.inboxMessages);
  $$KeyValuesTableTableManager get keyValues => $$KeyValuesTableTableManager(_db, _db.keyValues);
}
