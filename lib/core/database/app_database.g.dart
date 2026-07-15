// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  @override
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDistanceMetersMeta =
      const VerificationMeta('totalDistanceMeters');
  @override
  late final GeneratedColumn<double> totalDistanceMeters =
      GeneratedColumn<double>(
        'total_distance_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _averageSpeedMeta = const VerificationMeta(
    'averageSpeed',
  );
  @override
  late final GeneratedColumn<double> averageSpeed = GeneratedColumn<double>(
    'average_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSpeedMeta = const VerificationMeta(
    'maxSpeed',
  );
  @override
  late final GeneratedColumn<double> maxSpeed = GeneratedColumn<double>(
    'max_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minimumAltitudeMeta = const VerificationMeta(
    'minimumAltitude',
  );
  @override
  late final GeneratedColumn<double> minimumAltitude = GeneratedColumn<double>(
    'minimum_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maximumAltitudeMeta = const VerificationMeta(
    'maximumAltitude',
  );
  @override
  late final GeneratedColumn<double> maximumAltitude = GeneratedColumn<double>(
    'maximum_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMeta = const VerificationMeta(
    'elevationGain',
  );
  @override
  late final GeneratedColumn<double> elevationGain = GeneratedColumn<double>(
    'elevation_gain',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationLossMeta = const VerificationMeta(
    'elevationLoss',
  );
  @override
  late final GeneratedColumn<double> elevationLoss = GeneratedColumn<double>(
    'elevation_loss',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _representativePhotoIdMeta =
      const VerificationMeta('representativePhotoId');
  @override
  late final GeneratedColumn<String> representativePhotoId =
      GeneratedColumn<String>(
        'representative_photo_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSequenceMeta = const VerificationMeta(
    'lastSequence',
  );
  @override
  late final GeneratedColumn<int> lastSequence = GeneratedColumn<int>(
    'last_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _lastLatitudeMeta = const VerificationMeta(
    'lastLatitude',
  );
  @override
  late final GeneratedColumn<double> lastLatitude = GeneratedColumn<double>(
    'last_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLongitudeMeta = const VerificationMeta(
    'lastLongitude',
  );
  @override
  late final GeneratedColumn<double> lastLongitude = GeneratedColumn<double>(
    'last_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    activityType,
    status,
    startedAt,
    endedAt,
    elapsedSeconds,
    activeSeconds,
    totalDistanceMeters,
    averageSpeed,
    maxSpeed,
    minimumAltitude,
    maximumAltitude,
    elevationGain,
    elevationLoss,
    calories,
    memo,
    representativePhotoId,
    lastSequence,
    lastLatitude,
    lastLongitude,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('total_distance_meters')) {
      context.handle(
        _totalDistanceMetersMeta,
        totalDistanceMeters.isAcceptableOrUnknown(
          data['total_distance_meters']!,
          _totalDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('average_speed')) {
      context.handle(
        _averageSpeedMeta,
        averageSpeed.isAcceptableOrUnknown(
          data['average_speed']!,
          _averageSpeedMeta,
        ),
      );
    }
    if (data.containsKey('max_speed')) {
      context.handle(
        _maxSpeedMeta,
        maxSpeed.isAcceptableOrUnknown(data['max_speed']!, _maxSpeedMeta),
      );
    }
    if (data.containsKey('minimum_altitude')) {
      context.handle(
        _minimumAltitudeMeta,
        minimumAltitude.isAcceptableOrUnknown(
          data['minimum_altitude']!,
          _minimumAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('maximum_altitude')) {
      context.handle(
        _maximumAltitudeMeta,
        maximumAltitude.isAcceptableOrUnknown(
          data['maximum_altitude']!,
          _maximumAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain')) {
      context.handle(
        _elevationGainMeta,
        elevationGain.isAcceptableOrUnknown(
          data['elevation_gain']!,
          _elevationGainMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss')) {
      context.handle(
        _elevationLossMeta,
        elevationLoss.isAcceptableOrUnknown(
          data['elevation_loss']!,
          _elevationLossMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('representative_photo_id')) {
      context.handle(
        _representativePhotoIdMeta,
        representativePhotoId.isAcceptableOrUnknown(
          data['representative_photo_id']!,
          _representativePhotoIdMeta,
        ),
      );
    }
    if (data.containsKey('last_sequence')) {
      context.handle(
        _lastSequenceMeta,
        lastSequence.isAcceptableOrUnknown(
          data['last_sequence']!,
          _lastSequenceMeta,
        ),
      );
    }
    if (data.containsKey('last_latitude')) {
      context.handle(
        _lastLatitudeMeta,
        lastLatitude.isAcceptableOrUnknown(
          data['last_latitude']!,
          _lastLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('last_longitude')) {
      context.handle(
        _lastLongitudeMeta,
        lastLongitude.isAcceptableOrUnknown(
          data['last_longitude']!,
          _lastLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      elapsedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_seconds'],
      )!,
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      )!,
      totalDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_meters'],
      )!,
      averageSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed'],
      )!,
      maxSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed'],
      )!,
      minimumAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_altitude'],
      ),
      maximumAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_altitude'],
      ),
      elevationGain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain'],
      )!,
      elevationLoss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      representativePhotoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}representative_photo_id'],
      ),
      lastSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sequence'],
      )!,
      lastLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_latitude'],
      ),
      lastLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;
  final String title;
  final String activityType;
  final String status;
  final int startedAt;
  final int? endedAt;
  final int elapsedSeconds;
  final int activeSeconds;
  final double totalDistanceMeters;
  final double averageSpeed;
  final double maxSpeed;
  final double? minimumAltitude;
  final double? maximumAltitude;
  final double elevationGain;
  final double elevationLoss;
  final double calories;
  final String? memo;
  final String? representativePhotoId;
  final int lastSequence;
  final double? lastLatitude;
  final double? lastLongitude;
  final int createdAt;
  final int updatedAt;
  const ActivityRow({
    required this.id,
    required this.title,
    required this.activityType,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.elapsedSeconds,
    required this.activeSeconds,
    required this.totalDistanceMeters,
    required this.averageSpeed,
    required this.maxSpeed,
    this.minimumAltitude,
    this.maximumAltitude,
    required this.elevationGain,
    required this.elevationLoss,
    required this.calories,
    this.memo,
    this.representativePhotoId,
    required this.lastSequence,
    this.lastLatitude,
    this.lastLongitude,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['activity_type'] = Variable<String>(activityType);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['active_seconds'] = Variable<int>(activeSeconds);
    map['total_distance_meters'] = Variable<double>(totalDistanceMeters);
    map['average_speed'] = Variable<double>(averageSpeed);
    map['max_speed'] = Variable<double>(maxSpeed);
    if (!nullToAbsent || minimumAltitude != null) {
      map['minimum_altitude'] = Variable<double>(minimumAltitude);
    }
    if (!nullToAbsent || maximumAltitude != null) {
      map['maximum_altitude'] = Variable<double>(maximumAltitude);
    }
    map['elevation_gain'] = Variable<double>(elevationGain);
    map['elevation_loss'] = Variable<double>(elevationLoss);
    map['calories'] = Variable<double>(calories);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || representativePhotoId != null) {
      map['representative_photo_id'] = Variable<String>(representativePhotoId);
    }
    map['last_sequence'] = Variable<int>(lastSequence);
    if (!nullToAbsent || lastLatitude != null) {
      map['last_latitude'] = Variable<double>(lastLatitude);
    }
    if (!nullToAbsent || lastLongitude != null) {
      map['last_longitude'] = Variable<double>(lastLongitude);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      title: Value(title),
      activityType: Value(activityType),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      elapsedSeconds: Value(elapsedSeconds),
      activeSeconds: Value(activeSeconds),
      totalDistanceMeters: Value(totalDistanceMeters),
      averageSpeed: Value(averageSpeed),
      maxSpeed: Value(maxSpeed),
      minimumAltitude: minimumAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumAltitude),
      maximumAltitude: maximumAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumAltitude),
      elevationGain: Value(elevationGain),
      elevationLoss: Value(elevationLoss),
      calories: Value(calories),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      representativePhotoId: representativePhotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(representativePhotoId),
      lastSequence: Value(lastSequence),
      lastLatitude: lastLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLatitude),
      lastLongitude: lastLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLongitude),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      activityType: serializer.fromJson<String>(json['activityType']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      activeSeconds: serializer.fromJson<int>(json['activeSeconds']),
      totalDistanceMeters: serializer.fromJson<double>(
        json['totalDistanceMeters'],
      ),
      averageSpeed: serializer.fromJson<double>(json['averageSpeed']),
      maxSpeed: serializer.fromJson<double>(json['maxSpeed']),
      minimumAltitude: serializer.fromJson<double?>(json['minimumAltitude']),
      maximumAltitude: serializer.fromJson<double?>(json['maximumAltitude']),
      elevationGain: serializer.fromJson<double>(json['elevationGain']),
      elevationLoss: serializer.fromJson<double>(json['elevationLoss']),
      calories: serializer.fromJson<double>(json['calories']),
      memo: serializer.fromJson<String?>(json['memo']),
      representativePhotoId: serializer.fromJson<String?>(
        json['representativePhotoId'],
      ),
      lastSequence: serializer.fromJson<int>(json['lastSequence']),
      lastLatitude: serializer.fromJson<double?>(json['lastLatitude']),
      lastLongitude: serializer.fromJson<double?>(json['lastLongitude']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'activityType': serializer.toJson<String>(activityType),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'activeSeconds': serializer.toJson<int>(activeSeconds),
      'totalDistanceMeters': serializer.toJson<double>(totalDistanceMeters),
      'averageSpeed': serializer.toJson<double>(averageSpeed),
      'maxSpeed': serializer.toJson<double>(maxSpeed),
      'minimumAltitude': serializer.toJson<double?>(minimumAltitude),
      'maximumAltitude': serializer.toJson<double?>(maximumAltitude),
      'elevationGain': serializer.toJson<double>(elevationGain),
      'elevationLoss': serializer.toJson<double>(elevationLoss),
      'calories': serializer.toJson<double>(calories),
      'memo': serializer.toJson<String?>(memo),
      'representativePhotoId': serializer.toJson<String?>(
        representativePhotoId,
      ),
      'lastSequence': serializer.toJson<int>(lastSequence),
      'lastLatitude': serializer.toJson<double?>(lastLatitude),
      'lastLongitude': serializer.toJson<double?>(lastLongitude),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? title,
    String? activityType,
    String? status,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    int? elapsedSeconds,
    int? activeSeconds,
    double? totalDistanceMeters,
    double? averageSpeed,
    double? maxSpeed,
    Value<double?> minimumAltitude = const Value.absent(),
    Value<double?> maximumAltitude = const Value.absent(),
    double? elevationGain,
    double? elevationLoss,
    double? calories,
    Value<String?> memo = const Value.absent(),
    Value<String?> representativePhotoId = const Value.absent(),
    int? lastSequence,
    Value<double?> lastLatitude = const Value.absent(),
    Value<double?> lastLongitude = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => ActivityRow(
    id: id ?? this.id,
    title: title ?? this.title,
    activityType: activityType ?? this.activityType,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
    averageSpeed: averageSpeed ?? this.averageSpeed,
    maxSpeed: maxSpeed ?? this.maxSpeed,
    minimumAltitude: minimumAltitude.present
        ? minimumAltitude.value
        : this.minimumAltitude,
    maximumAltitude: maximumAltitude.present
        ? maximumAltitude.value
        : this.maximumAltitude,
    elevationGain: elevationGain ?? this.elevationGain,
    elevationLoss: elevationLoss ?? this.elevationLoss,
    calories: calories ?? this.calories,
    memo: memo.present ? memo.value : this.memo,
    representativePhotoId: representativePhotoId.present
        ? representativePhotoId.value
        : this.representativePhotoId,
    lastSequence: lastSequence ?? this.lastSequence,
    lastLatitude: lastLatitude.present ? lastLatitude.value : this.lastLatitude,
    lastLongitude: lastLongitude.present
        ? lastLongitude.value
        : this.lastLongitude,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      totalDistanceMeters: data.totalDistanceMeters.present
          ? data.totalDistanceMeters.value
          : this.totalDistanceMeters,
      averageSpeed: data.averageSpeed.present
          ? data.averageSpeed.value
          : this.averageSpeed,
      maxSpeed: data.maxSpeed.present ? data.maxSpeed.value : this.maxSpeed,
      minimumAltitude: data.minimumAltitude.present
          ? data.minimumAltitude.value
          : this.minimumAltitude,
      maximumAltitude: data.maximumAltitude.present
          ? data.maximumAltitude.value
          : this.maximumAltitude,
      elevationGain: data.elevationGain.present
          ? data.elevationGain.value
          : this.elevationGain,
      elevationLoss: data.elevationLoss.present
          ? data.elevationLoss.value
          : this.elevationLoss,
      calories: data.calories.present ? data.calories.value : this.calories,
      memo: data.memo.present ? data.memo.value : this.memo,
      representativePhotoId: data.representativePhotoId.present
          ? data.representativePhotoId.value
          : this.representativePhotoId,
      lastSequence: data.lastSequence.present
          ? data.lastSequence.value
          : this.lastSequence,
      lastLatitude: data.lastLatitude.present
          ? data.lastLatitude.value
          : this.lastLatitude,
      lastLongitude: data.lastLongitude.present
          ? data.lastLongitude.value
          : this.lastLongitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('activityType: $activityType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('averageSpeed: $averageSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('minimumAltitude: $minimumAltitude, ')
          ..write('maximumAltitude: $maximumAltitude, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('elevationLoss: $elevationLoss, ')
          ..write('calories: $calories, ')
          ..write('memo: $memo, ')
          ..write('representativePhotoId: $representativePhotoId, ')
          ..write('lastSequence: $lastSequence, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    activityType,
    status,
    startedAt,
    endedAt,
    elapsedSeconds,
    activeSeconds,
    totalDistanceMeters,
    averageSpeed,
    maxSpeed,
    minimumAltitude,
    maximumAltitude,
    elevationGain,
    elevationLoss,
    calories,
    memo,
    representativePhotoId,
    lastSequence,
    lastLatitude,
    lastLongitude,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.activityType == this.activityType &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.activeSeconds == this.activeSeconds &&
          other.totalDistanceMeters == this.totalDistanceMeters &&
          other.averageSpeed == this.averageSpeed &&
          other.maxSpeed == this.maxSpeed &&
          other.minimumAltitude == this.minimumAltitude &&
          other.maximumAltitude == this.maximumAltitude &&
          other.elevationGain == this.elevationGain &&
          other.elevationLoss == this.elevationLoss &&
          other.calories == this.calories &&
          other.memo == this.memo &&
          other.representativePhotoId == this.representativePhotoId &&
          other.lastSequence == this.lastSequence &&
          other.lastLatitude == this.lastLatitude &&
          other.lastLongitude == this.lastLongitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> activityType;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> elapsedSeconds;
  final Value<int> activeSeconds;
  final Value<double> totalDistanceMeters;
  final Value<double> averageSpeed;
  final Value<double> maxSpeed;
  final Value<double?> minimumAltitude;
  final Value<double?> maximumAltitude;
  final Value<double> elevationGain;
  final Value<double> elevationLoss;
  final Value<double> calories;
  final Value<String?> memo;
  final Value<String?> representativePhotoId;
  final Value<int> lastSequence;
  final Value<double?> lastLatitude;
  final Value<double?> lastLongitude;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.activityType = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.averageSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.minimumAltitude = const Value.absent(),
    this.maximumAltitude = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.elevationLoss = const Value.absent(),
    this.calories = const Value.absent(),
    this.memo = const Value.absent(),
    this.representativePhotoId = const Value.absent(),
    this.lastSequence = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String activityType,
    required String status,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.averageSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.minimumAltitude = const Value.absent(),
    this.maximumAltitude = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.elevationLoss = const Value.absent(),
    this.calories = const Value.absent(),
    this.memo = const Value.absent(),
    this.representativePhotoId = const Value.absent(),
    this.lastSequence = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityType = Value(activityType),
       status = Value(status),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? activityType,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? elapsedSeconds,
    Expression<int>? activeSeconds,
    Expression<double>? totalDistanceMeters,
    Expression<double>? averageSpeed,
    Expression<double>? maxSpeed,
    Expression<double>? minimumAltitude,
    Expression<double>? maximumAltitude,
    Expression<double>? elevationGain,
    Expression<double>? elevationLoss,
    Expression<double>? calories,
    Expression<String>? memo,
    Expression<String>? representativePhotoId,
    Expression<int>? lastSequence,
    Expression<double>? lastLatitude,
    Expression<double>? lastLongitude,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (activityType != null) 'activity_type': activityType,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (totalDistanceMeters != null)
        'total_distance_meters': totalDistanceMeters,
      if (averageSpeed != null) 'average_speed': averageSpeed,
      if (maxSpeed != null) 'max_speed': maxSpeed,
      if (minimumAltitude != null) 'minimum_altitude': minimumAltitude,
      if (maximumAltitude != null) 'maximum_altitude': maximumAltitude,
      if (elevationGain != null) 'elevation_gain': elevationGain,
      if (elevationLoss != null) 'elevation_loss': elevationLoss,
      if (calories != null) 'calories': calories,
      if (memo != null) 'memo': memo,
      if (representativePhotoId != null)
        'representative_photo_id': representativePhotoId,
      if (lastSequence != null) 'last_sequence': lastSequence,
      if (lastLatitude != null) 'last_latitude': lastLatitude,
      if (lastLongitude != null) 'last_longitude': lastLongitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? activityType,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? elapsedSeconds,
    Value<int>? activeSeconds,
    Value<double>? totalDistanceMeters,
    Value<double>? averageSpeed,
    Value<double>? maxSpeed,
    Value<double?>? minimumAltitude,
    Value<double?>? maximumAltitude,
    Value<double>? elevationGain,
    Value<double>? elevationLoss,
    Value<double>? calories,
    Value<String?>? memo,
    Value<String?>? representativePhotoId,
    Value<int>? lastSequence,
    Value<double?>? lastLatitude,
    Value<double?>? lastLongitude,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      minimumAltitude: minimumAltitude ?? this.minimumAltitude,
      maximumAltitude: maximumAltitude ?? this.maximumAltitude,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      calories: calories ?? this.calories,
      memo: memo ?? this.memo,
      representativePhotoId:
          representativePhotoId ?? this.representativePhotoId,
      lastSequence: lastSequence ?? this.lastSequence,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (totalDistanceMeters.present) {
      map['total_distance_meters'] = Variable<double>(
        totalDistanceMeters.value,
      );
    }
    if (averageSpeed.present) {
      map['average_speed'] = Variable<double>(averageSpeed.value);
    }
    if (maxSpeed.present) {
      map['max_speed'] = Variable<double>(maxSpeed.value);
    }
    if (minimumAltitude.present) {
      map['minimum_altitude'] = Variable<double>(minimumAltitude.value);
    }
    if (maximumAltitude.present) {
      map['maximum_altitude'] = Variable<double>(maximumAltitude.value);
    }
    if (elevationGain.present) {
      map['elevation_gain'] = Variable<double>(elevationGain.value);
    }
    if (elevationLoss.present) {
      map['elevation_loss'] = Variable<double>(elevationLoss.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (representativePhotoId.present) {
      map['representative_photo_id'] = Variable<String>(
        representativePhotoId.value,
      );
    }
    if (lastSequence.present) {
      map['last_sequence'] = Variable<int>(lastSequence.value);
    }
    if (lastLatitude.present) {
      map['last_latitude'] = Variable<double>(lastLatitude.value);
    }
    if (lastLongitude.present) {
      map['last_longitude'] = Variable<double>(lastLongitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('activityType: $activityType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('averageSpeed: $averageSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('minimumAltitude: $minimumAltitude, ')
          ..write('maximumAltitude: $maximumAltitude, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('elevationLoss: $elevationLoss, ')
          ..write('calories: $calories, ')
          ..write('memo: $memo, ')
          ..write('representativePhotoId: $representativePhotoId, ')
          ..write('lastSequence: $lastSequence, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gpsAltitudeMeta = const VerificationMeta(
    'gpsAltitude',
  );
  @override
  late final GeneratedColumn<double> gpsAltitude = GeneratedColumn<double>(
    'gps_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _demAltitudeMeta = const VerificationMeta(
    'demAltitude',
  );
  @override
  late final GeneratedColumn<double> demAltitude = GeneratedColumn<double>(
    'dem_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headingMeta = const VerificationMeta(
    'heading',
  );
  @override
  late final GeneratedColumn<double> heading = GeneratedColumn<double>(
    'heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentIndexMeta = const VerificationMeta(
    'segmentIndex',
  );
  @override
  late final GeneratedColumn<int> segmentIndex = GeneratedColumn<int>(
    'segment_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isAcceptedMeta = const VerificationMeta(
    'isAccepted',
  );
  @override
  late final GeneratedColumn<bool> isAccepted = GeneratedColumn<bool>(
    'is_accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_accepted" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    sequence,
    latitude,
    longitude,
    gpsAltitude,
    demAltitude,
    speed,
    heading,
    accuracy,
    recordedAt,
    segmentIndex,
    isAccepted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('gps_altitude')) {
      context.handle(
        _gpsAltitudeMeta,
        gpsAltitude.isAcceptableOrUnknown(
          data['gps_altitude']!,
          _gpsAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('dem_altitude')) {
      context.handle(
        _demAltitudeMeta,
        demAltitude.isAcceptableOrUnknown(
          data['dem_altitude']!,
          _demAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('heading')) {
      context.handle(
        _headingMeta,
        heading.isAcceptableOrUnknown(data['heading']!, _headingMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('segment_index')) {
      context.handle(
        _segmentIndexMeta,
        segmentIndex.isAcceptableOrUnknown(
          data['segment_index']!,
          _segmentIndexMeta,
        ),
      );
    }
    if (data.containsKey('is_accepted')) {
      context.handle(
        _isAcceptedMeta,
        isAccepted.isAcceptableOrUnknown(data['is_accepted']!, _isAcceptedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      gpsAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_altitude'],
      ),
      demAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dem_altitude'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      heading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      segmentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_index'],
      )!,
      isAccepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_accepted'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPointRow extends DataClass implements Insertable<TrackPointRow> {
  final String id;
  final String activityId;
  final int sequence;
  final double latitude;
  final double longitude;
  final double? gpsAltitude;
  final double? demAltitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final int recordedAt;
  final int segmentIndex;
  final bool isAccepted;
  const TrackPointRow({
    required this.id,
    required this.activityId,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    this.gpsAltitude,
    this.demAltitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.recordedAt,
    required this.segmentIndex,
    required this.isAccepted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['sequence'] = Variable<int>(sequence);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || gpsAltitude != null) {
      map['gps_altitude'] = Variable<double>(gpsAltitude);
    }
    if (!nullToAbsent || demAltitude != null) {
      map['dem_altitude'] = Variable<double>(demAltitude);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || heading != null) {
      map['heading'] = Variable<double>(heading);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    map['recorded_at'] = Variable<int>(recordedAt);
    map['segment_index'] = Variable<int>(segmentIndex);
    map['is_accepted'] = Variable<bool>(isAccepted);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      sequence: Value(sequence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      gpsAltitude: gpsAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAltitude),
      demAltitude: demAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(demAltitude),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      heading: heading == null && nullToAbsent
          ? const Value.absent()
          : Value(heading),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      recordedAt: Value(recordedAt),
      segmentIndex: Value(segmentIndex),
      isAccepted: Value(isAccepted),
    );
  }

  factory TrackPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPointRow(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      gpsAltitude: serializer.fromJson<double?>(json['gpsAltitude']),
      demAltitude: serializer.fromJson<double?>(json['demAltitude']),
      speed: serializer.fromJson<double?>(json['speed']),
      heading: serializer.fromJson<double?>(json['heading']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
      segmentIndex: serializer.fromJson<int>(json['segmentIndex']),
      isAccepted: serializer.fromJson<bool>(json['isAccepted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'sequence': serializer.toJson<int>(sequence),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'gpsAltitude': serializer.toJson<double?>(gpsAltitude),
      'demAltitude': serializer.toJson<double?>(demAltitude),
      'speed': serializer.toJson<double?>(speed),
      'heading': serializer.toJson<double?>(heading),
      'accuracy': serializer.toJson<double?>(accuracy),
      'recordedAt': serializer.toJson<int>(recordedAt),
      'segmentIndex': serializer.toJson<int>(segmentIndex),
      'isAccepted': serializer.toJson<bool>(isAccepted),
    };
  }

  TrackPointRow copyWith({
    String? id,
    String? activityId,
    int? sequence,
    double? latitude,
    double? longitude,
    Value<double?> gpsAltitude = const Value.absent(),
    Value<double?> demAltitude = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<double?> heading = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    int? recordedAt,
    int? segmentIndex,
    bool? isAccepted,
  }) => TrackPointRow(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    sequence: sequence ?? this.sequence,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    gpsAltitude: gpsAltitude.present ? gpsAltitude.value : this.gpsAltitude,
    demAltitude: demAltitude.present ? demAltitude.value : this.demAltitude,
    speed: speed.present ? speed.value : this.speed,
    heading: heading.present ? heading.value : this.heading,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    recordedAt: recordedAt ?? this.recordedAt,
    segmentIndex: segmentIndex ?? this.segmentIndex,
    isAccepted: isAccepted ?? this.isAccepted,
  );
  TrackPointRow copyWithCompanion(TrackPointsCompanion data) {
    return TrackPointRow(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gpsAltitude: data.gpsAltitude.present
          ? data.gpsAltitude.value
          : this.gpsAltitude,
      demAltitude: data.demAltitude.present
          ? data.demAltitude.value
          : this.demAltitude,
      speed: data.speed.present ? data.speed.value : this.speed,
      heading: data.heading.present ? data.heading.value : this.heading,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      segmentIndex: data.segmentIndex.present
          ? data.segmentIndex.value
          : this.segmentIndex,
      isAccepted: data.isAccepted.present
          ? data.isAccepted.value
          : this.isAccepted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointRow(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('demAltitude: $demAltitude, ')
          ..write('speed: $speed, ')
          ..write('heading: $heading, ')
          ..write('accuracy: $accuracy, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('isAccepted: $isAccepted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    sequence,
    latitude,
    longitude,
    gpsAltitude,
    demAltitude,
    speed,
    heading,
    accuracy,
    recordedAt,
    segmentIndex,
    isAccepted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPointRow &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.sequence == this.sequence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gpsAltitude == this.gpsAltitude &&
          other.demAltitude == this.demAltitude &&
          other.speed == this.speed &&
          other.heading == this.heading &&
          other.accuracy == this.accuracy &&
          other.recordedAt == this.recordedAt &&
          other.segmentIndex == this.segmentIndex &&
          other.isAccepted == this.isAccepted);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPointRow> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<int> sequence;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> gpsAltitude;
  final Value<double?> demAltitude;
  final Value<double?> speed;
  final Value<double?> heading;
  final Value<double?> accuracy;
  final Value<int> recordedAt;
  final Value<int> segmentIndex;
  final Value<bool> isAccepted;
  final Value<int> rowid;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAltitude = const Value.absent(),
    this.demAltitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.heading = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.segmentIndex = const Value.absent(),
    this.isAccepted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    required String id,
    required String activityId,
    required int sequence,
    required double latitude,
    required double longitude,
    this.gpsAltitude = const Value.absent(),
    this.demAltitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.heading = const Value.absent(),
    this.accuracy = const Value.absent(),
    required int recordedAt,
    this.segmentIndex = const Value.absent(),
    this.isAccepted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       sequence = Value(sequence),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt);
  static Insertable<TrackPointRow> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<int>? sequence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? gpsAltitude,
    Expression<double>? demAltitude,
    Expression<double>? speed,
    Expression<double>? heading,
    Expression<double>? accuracy,
    Expression<int>? recordedAt,
    Expression<int>? segmentIndex,
    Expression<bool>? isAccepted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (sequence != null) 'sequence': sequence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gpsAltitude != null) 'gps_altitude': gpsAltitude,
      if (demAltitude != null) 'dem_altitude': demAltitude,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      if (accuracy != null) 'accuracy': accuracy,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (segmentIndex != null) 'segment_index': segmentIndex,
      if (isAccepted != null) 'is_accepted': isAccepted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<int>? sequence,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? gpsAltitude,
    Value<double?>? demAltitude,
    Value<double?>? speed,
    Value<double?>? heading,
    Value<double?>? accuracy,
    Value<int>? recordedAt,
    Value<int>? segmentIndex,
    Value<bool>? isAccepted,
    Value<int>? rowid,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAltitude: gpsAltitude ?? this.gpsAltitude,
      demAltitude: demAltitude ?? this.demAltitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      recordedAt: recordedAt ?? this.recordedAt,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      isAccepted: isAccepted ?? this.isAccepted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gpsAltitude.present) {
      map['gps_altitude'] = Variable<double>(gpsAltitude.value);
    }
    if (demAltitude.present) {
      map['dem_altitude'] = Variable<double>(demAltitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (heading.present) {
      map['heading'] = Variable<double>(heading.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (segmentIndex.present) {
      map['segment_index'] = Variable<int>(segmentIndex.value);
    }
    if (isAccepted.present) {
      map['is_accepted'] = Variable<bool>(isAccepted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('demAltitude: $demAltitude, ')
          ..write('speed: $speed, ')
          ..write('heading: $heading, ')
          ..write('accuracy: $accuracy, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('isAccepted: $isAccepted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityPhotosTable extends ActivityPhotos
    with TableInfo<$ActivityPhotosTable, ActivityPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAltitudeMeta = const VerificationMeta(
    'gpsAltitude',
  );
  @override
  late final GeneratedColumn<double> gpsAltitude = GeneratedColumn<double>(
    'gps_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _demAltitudeMeta = const VerificationMeta(
    'demAltitude',
  );
  @override
  late final GeneratedColumn<double> demAltitude = GeneratedColumn<double>(
    'dem_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<int> takenAt = GeneratedColumn<int>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    localPath,
    thumbnailPath,
    latitude,
    longitude,
    gpsAltitude,
    demAltitude,
    takenAt,
    elapsedSeconds,
    distanceMeters,
    caption,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailPathMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('gps_altitude')) {
      context.handle(
        _gpsAltitudeMeta,
        gpsAltitude.isAcceptableOrUnknown(
          data['gps_altitude']!,
          _gpsAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('dem_altitude')) {
      context.handle(
        _demAltitudeMeta,
        demAltitude.isAcceptableOrUnknown(
          data['dem_altitude']!,
          _demAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      gpsAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_altitude'],
      ),
      demAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dem_altitude'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taken_at'],
      )!,
      elapsedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
    );
  }

  @override
  $ActivityPhotosTable createAlias(String alias) {
    return $ActivityPhotosTable(attachedDatabase, alias);
  }
}

class ActivityPhotoRow extends DataClass
    implements Insertable<ActivityPhotoRow> {
  final String id;
  final String activityId;
  final String localPath;
  final String thumbnailPath;
  final double? latitude;
  final double? longitude;
  final double? gpsAltitude;
  final double? demAltitude;
  final int takenAt;
  final int elapsedSeconds;
  final double distanceMeters;
  final String? caption;
  const ActivityPhotoRow({
    required this.id,
    required this.activityId,
    required this.localPath,
    required this.thumbnailPath,
    this.latitude,
    this.longitude,
    this.gpsAltitude,
    this.demAltitude,
    required this.takenAt,
    required this.elapsedSeconds,
    required this.distanceMeters,
    this.caption,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['local_path'] = Variable<String>(localPath);
    map['thumbnail_path'] = Variable<String>(thumbnailPath);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || gpsAltitude != null) {
      map['gps_altitude'] = Variable<double>(gpsAltitude);
    }
    if (!nullToAbsent || demAltitude != null) {
      map['dem_altitude'] = Variable<double>(demAltitude);
    }
    map['taken_at'] = Variable<int>(takenAt);
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['distance_meters'] = Variable<double>(distanceMeters);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    return map;
  }

  ActivityPhotosCompanion toCompanion(bool nullToAbsent) {
    return ActivityPhotosCompanion(
      id: Value(id),
      activityId: Value(activityId),
      localPath: Value(localPath),
      thumbnailPath: Value(thumbnailPath),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      gpsAltitude: gpsAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAltitude),
      demAltitude: demAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(demAltitude),
      takenAt: Value(takenAt),
      elapsedSeconds: Value(elapsedSeconds),
      distanceMeters: Value(distanceMeters),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
    );
  }

  factory ActivityPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityPhotoRow(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      gpsAltitude: serializer.fromJson<double?>(json['gpsAltitude']),
      demAltitude: serializer.fromJson<double?>(json['demAltitude']),
      takenAt: serializer.fromJson<int>(json['takenAt']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      caption: serializer.fromJson<String?>(json['caption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'localPath': serializer.toJson<String>(localPath),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'gpsAltitude': serializer.toJson<double?>(gpsAltitude),
      'demAltitude': serializer.toJson<double?>(demAltitude),
      'takenAt': serializer.toJson<int>(takenAt),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'caption': serializer.toJson<String?>(caption),
    };
  }

  ActivityPhotoRow copyWith({
    String? id,
    String? activityId,
    String? localPath,
    String? thumbnailPath,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> gpsAltitude = const Value.absent(),
    Value<double?> demAltitude = const Value.absent(),
    int? takenAt,
    int? elapsedSeconds,
    double? distanceMeters,
    Value<String?> caption = const Value.absent(),
  }) => ActivityPhotoRow(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    localPath: localPath ?? this.localPath,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    gpsAltitude: gpsAltitude.present ? gpsAltitude.value : this.gpsAltitude,
    demAltitude: demAltitude.present ? demAltitude.value : this.demAltitude,
    takenAt: takenAt ?? this.takenAt,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    caption: caption.present ? caption.value : this.caption,
  );
  ActivityPhotoRow copyWithCompanion(ActivityPhotosCompanion data) {
    return ActivityPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gpsAltitude: data.gpsAltitude.present
          ? data.gpsAltitude.value
          : this.gpsAltitude,
      demAltitude: data.demAltitude.present
          ? data.demAltitude.value
          : this.demAltitude,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      caption: data.caption.present ? data.caption.value : this.caption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityPhotoRow(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('demAltitude: $demAltitude, ')
          ..write('takenAt: $takenAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    localPath,
    thumbnailPath,
    latitude,
    longitude,
    gpsAltitude,
    demAltitude,
    takenAt,
    elapsedSeconds,
    distanceMeters,
    caption,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityPhotoRow &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.localPath == this.localPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gpsAltitude == this.gpsAltitude &&
          other.demAltitude == this.demAltitude &&
          other.takenAt == this.takenAt &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.caption == this.caption);
}

class ActivityPhotosCompanion extends UpdateCompanion<ActivityPhotoRow> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> localPath;
  final Value<String> thumbnailPath;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> gpsAltitude;
  final Value<double?> demAltitude;
  final Value<int> takenAt;
  final Value<int> elapsedSeconds;
  final Value<double> distanceMeters;
  final Value<String?> caption;
  final Value<int> rowid;
  const ActivityPhotosCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAltitude = const Value.absent(),
    this.demAltitude = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.caption = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityPhotosCompanion.insert({
    required String id,
    required String activityId,
    required String localPath,
    required String thumbnailPath,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAltitude = const Value.absent(),
    this.demAltitude = const Value.absent(),
    required int takenAt,
    this.elapsedSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.caption = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       localPath = Value(localPath),
       thumbnailPath = Value(thumbnailPath),
       takenAt = Value(takenAt);
  static Insertable<ActivityPhotoRow> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? localPath,
    Expression<String>? thumbnailPath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? gpsAltitude,
    Expression<double>? demAltitude,
    Expression<int>? takenAt,
    Expression<int>? elapsedSeconds,
    Expression<double>? distanceMeters,
    Expression<String>? caption,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (localPath != null) 'local_path': localPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gpsAltitude != null) 'gps_altitude': gpsAltitude,
      if (demAltitude != null) 'dem_altitude': demAltitude,
      if (takenAt != null) 'taken_at': takenAt,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (caption != null) 'caption': caption,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? localPath,
    Value<String>? thumbnailPath,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? gpsAltitude,
    Value<double?>? demAltitude,
    Value<int>? takenAt,
    Value<int>? elapsedSeconds,
    Value<double>? distanceMeters,
    Value<String?>? caption,
    Value<int>? rowid,
  }) {
    return ActivityPhotosCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAltitude: gpsAltitude ?? this.gpsAltitude,
      demAltitude: demAltitude ?? this.demAltitude,
      takenAt: takenAt ?? this.takenAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caption: caption ?? this.caption,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gpsAltitude.present) {
      map['gps_altitude'] = Variable<double>(gpsAltitude.value);
    }
    if (demAltitude.present) {
      map['dem_altitude'] = Variable<double>(demAltitude.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityPhotosCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('demAltitude: $demAltitude, ')
          ..write('takenAt: $takenAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('caption: $caption, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupHistoryTable extends BackupHistory
    with TableInfo<$BackupHistoryTable, BackupHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _driveFileIdMeta = const VerificationMeta(
    'driveFileId',
  );
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
    'drive_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activityCountMeta = const VerificationMeta(
    'activityCount',
  );
  @override
  late final GeneratedColumn<int> activityCount = GeneratedColumn<int>(
    'activity_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _photoCountMeta = const VerificationMeta(
    'photoCount',
  );
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
    'photo_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    driveFileId,
    type,
    sizeBytes,
    activityCount,
    photoCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
        _driveFileIdMeta,
        driveFileId.isAcceptableOrUnknown(
          data['drive_file_id']!,
          _driveFileIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('activity_count')) {
      context.handle(
        _activityCountMeta,
        activityCount.isAcceptableOrUnknown(
          data['activity_count']!,
          _activityCountMeta,
        ),
      );
    }
    if (data.containsKey('photo_count')) {
      context.handle(
        _photoCountMeta,
        photoCount.isAcceptableOrUnknown(data['photo_count']!, _photoCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      driveFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_file_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      activityCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_count'],
      )!,
      photoCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $BackupHistoryTable createAlias(String alias) {
    return $BackupHistoryTable(attachedDatabase, alias);
  }
}

class BackupHistoryRow extends DataClass
    implements Insertable<BackupHistoryRow> {
  final String id;
  final int createdAt;
  final String? driveFileId;
  final String type;
  final int sizeBytes;
  final int activityCount;
  final int photoCount;
  final String status;
  const BackupHistoryRow({
    required this.id,
    required this.createdAt,
    this.driveFileId,
    required this.type,
    required this.sizeBytes,
    required this.activityCount,
    required this.photoCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || driveFileId != null) {
      map['drive_file_id'] = Variable<String>(driveFileId);
    }
    map['type'] = Variable<String>(type);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['activity_count'] = Variable<int>(activityCount);
    map['photo_count'] = Variable<int>(photoCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  BackupHistoryCompanion toCompanion(bool nullToAbsent) {
    return BackupHistoryCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      driveFileId: driveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(driveFileId),
      type: Value(type),
      sizeBytes: Value(sizeBytes),
      activityCount: Value(activityCount),
      photoCount: Value(photoCount),
      status: Value(status),
    );
  }

  factory BackupHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      driveFileId: serializer.fromJson<String?>(json['driveFileId']),
      type: serializer.fromJson<String>(json['type']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      activityCount: serializer.fromJson<int>(json['activityCount']),
      photoCount: serializer.fromJson<int>(json['photoCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'driveFileId': serializer.toJson<String?>(driveFileId),
      'type': serializer.toJson<String>(type),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'activityCount': serializer.toJson<int>(activityCount),
      'photoCount': serializer.toJson<int>(photoCount),
      'status': serializer.toJson<String>(status),
    };
  }

  BackupHistoryRow copyWith({
    String? id,
    int? createdAt,
    Value<String?> driveFileId = const Value.absent(),
    String? type,
    int? sizeBytes,
    int? activityCount,
    int? photoCount,
    String? status,
  }) => BackupHistoryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    driveFileId: driveFileId.present ? driveFileId.value : this.driveFileId,
    type: type ?? this.type,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    activityCount: activityCount ?? this.activityCount,
    photoCount: photoCount ?? this.photoCount,
    status: status ?? this.status,
  );
  BackupHistoryRow copyWithCompanion(BackupHistoryCompanion data) {
    return BackupHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      driveFileId: data.driveFileId.present
          ? data.driveFileId.value
          : this.driveFileId,
      type: data.type.present ? data.type.value : this.type,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      activityCount: data.activityCount.present
          ? data.activityCount.value
          : this.activityCount,
      photoCount: data.photoCount.present
          ? data.photoCount.value
          : this.photoCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('type: $type, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('activityCount: $activityCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    driveFileId,
    type,
    sizeBytes,
    activityCount,
    photoCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupHistoryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.driveFileId == this.driveFileId &&
          other.type == this.type &&
          other.sizeBytes == this.sizeBytes &&
          other.activityCount == this.activityCount &&
          other.photoCount == this.photoCount &&
          other.status == this.status);
}

class BackupHistoryCompanion extends UpdateCompanion<BackupHistoryRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<String?> driveFileId;
  final Value<String> type;
  final Value<int> sizeBytes;
  final Value<int> activityCount;
  final Value<int> photoCount;
  final Value<String> status;
  final Value<int> rowid;
  const BackupHistoryCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.type = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.activityCount = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupHistoryCompanion.insert({
    required String id,
    required int createdAt,
    this.driveFileId = const Value.absent(),
    required String type,
    this.sizeBytes = const Value.absent(),
    this.activityCount = const Value.absent(),
    this.photoCount = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       type = Value(type),
       status = Value(status);
  static Insertable<BackupHistoryRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<String>? driveFileId,
    Expression<String>? type,
    Expression<int>? sizeBytes,
    Expression<int>? activityCount,
    Expression<int>? photoCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (type != null) 'type': type,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (activityCount != null) 'activity_count': activityCount,
      if (photoCount != null) 'photo_count': photoCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupHistoryCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<String?>? driveFileId,
    Value<String>? type,
    Value<int>? sizeBytes,
    Value<int>? activityCount,
    Value<int>? photoCount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return BackupHistoryCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      driveFileId: driveFileId ?? this.driveFileId,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      activityCount: activityCount ?? this.activityCount,
      photoCount: photoCount ?? this.photoCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (activityCount.present) {
      map['activity_count'] = Variable<int>(activityCount.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('type: $type, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('activityCount: $activityCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $ActivityPhotosTable activityPhotos = $ActivityPhotosTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BackupHistoryTable backupHistory = $BackupHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activities,
    trackPoints,
    activityPhotos,
    appSettings,
    backupHistory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_photos', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      Value<String> title,
      required String activityType,
      required String status,
      required int startedAt,
      Value<int?> endedAt,
      Value<int> elapsedSeconds,
      Value<int> activeSeconds,
      Value<double> totalDistanceMeters,
      Value<double> averageSpeed,
      Value<double> maxSpeed,
      Value<double?> minimumAltitude,
      Value<double?> maximumAltitude,
      Value<double> elevationGain,
      Value<double> elevationLoss,
      Value<double> calories,
      Value<String?> memo,
      Value<String?> representativePhotoId,
      Value<int> lastSequence,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> activityType,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int> elapsedSeconds,
      Value<int> activeSeconds,
      Value<double> totalDistanceMeters,
      Value<double> averageSpeed,
      Value<double> maxSpeed,
      Value<double?> minimumAltitude,
      Value<double?> maximumAltitude,
      Value<double> elevationGain,
      Value<double> elevationLoss,
      Value<double> calories,
      Value<String?> memo,
      Value<String?> representativePhotoId,
      Value<int> lastSequence,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPointRow>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'activities__id__track_points__activity_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityPhotosTable, List<ActivityPhotoRow>>
  _activityPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityPhotos,
    aliasName: 'activities__id__activity_photos__activity_id',
  );

  $$ActivityPhotosTableProcessedTableManager get activityPhotosRefs {
    final manager = $$ActivityPhotosTableTableManager(
      $_db,
      $_db.activityPhotos,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeed => $composableBuilder(
    column: $table.averageSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumAltitude => $composableBuilder(
    column: $table.minimumAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumAltitude => $composableBuilder(
    column: $table.maximumAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get representativePhotoId => $composableBuilder(
    column: $table.representativePhotoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityPhotosRefs(
    Expression<bool> Function($$ActivityPhotosTableFilterComposer f) f,
  ) {
    final $$ActivityPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityPhotos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityPhotosTableFilterComposer(
            $db: $db,
            $table: $db.activityPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeed => $composableBuilder(
    column: $table.averageSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumAltitude => $composableBuilder(
    column: $table.minimumAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumAltitude => $composableBuilder(
    column: $table.maximumAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get representativePhotoId => $composableBuilder(
    column: $table.representativePhotoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeed => $composableBuilder(
    column: $table.averageSpeed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeed =>
      $composableBuilder(column: $table.maxSpeed, builder: (column) => column);

  GeneratedColumn<double> get minimumAltitude => $composableBuilder(
    column: $table.minimumAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maximumAltitude => $composableBuilder(
    column: $table.maximumAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get representativePhotoId => $composableBuilder(
    column: $table.representativePhotoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSequence => $composableBuilder(
    column: $table.lastSequence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityPhotosRefs<T extends Object>(
    Expression<T> Function($$ActivityPhotosTableAnnotationComposer a) f,
  ) {
    final $$ActivityPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityPhotos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.activityPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (ActivityRow, $$ActivitiesTableReferences),
          ActivityRow,
          PrefetchHooks Function({
            bool trackPointsRefs,
            bool activityPhotosRefs,
          })
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int> activeSeconds = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<double> averageSpeed = const Value.absent(),
                Value<double> maxSpeed = const Value.absent(),
                Value<double?> minimumAltitude = const Value.absent(),
                Value<double?> maximumAltitude = const Value.absent(),
                Value<double> elevationGain = const Value.absent(),
                Value<double> elevationLoss = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> representativePhotoId = const Value.absent(),
                Value<int> lastSequence = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                title: title,
                activityType: activityType,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                elapsedSeconds: elapsedSeconds,
                activeSeconds: activeSeconds,
                totalDistanceMeters: totalDistanceMeters,
                averageSpeed: averageSpeed,
                maxSpeed: maxSpeed,
                minimumAltitude: minimumAltitude,
                maximumAltitude: maximumAltitude,
                elevationGain: elevationGain,
                elevationLoss: elevationLoss,
                calories: calories,
                memo: memo,
                representativePhotoId: representativePhotoId,
                lastSequence: lastSequence,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                required String activityType,
                required String status,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int> activeSeconds = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<double> averageSpeed = const Value.absent(),
                Value<double> maxSpeed = const Value.absent(),
                Value<double?> minimumAltitude = const Value.absent(),
                Value<double?> maximumAltitude = const Value.absent(),
                Value<double> elevationGain = const Value.absent(),
                Value<double> elevationLoss = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> representativePhotoId = const Value.absent(),
                Value<int> lastSequence = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                title: title,
                activityType: activityType,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                elapsedSeconds: elapsedSeconds,
                activeSeconds: activeSeconds,
                totalDistanceMeters: totalDistanceMeters,
                averageSpeed: averageSpeed,
                maxSpeed: maxSpeed,
                minimumAltitude: minimumAltitude,
                maximumAltitude: maximumAltitude,
                elevationGain: elevationGain,
                elevationLoss: elevationLoss,
                calories: calories,
                memo: memo,
                representativePhotoId: representativePhotoId,
                lastSequence: lastSequence,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trackPointsRefs = false, activityPhotosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackPointsRefs) db.trackPoints,
                    if (activityPhotosRefs) db.activityPhotos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackPointsRefs)
                        await $_getPrefetchedData<
                          ActivityRow,
                          $ActivitiesTable,
                          TrackPointRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._trackPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).trackPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activityPhotosRefs)
                        await $_getPrefetchedData<
                          ActivityRow,
                          $ActivitiesTable,
                          ActivityPhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._activityPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).activityPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (ActivityRow, $$ActivitiesTableReferences),
      ActivityRow,
      PrefetchHooks Function({bool trackPointsRefs, bool activityPhotosRefs})
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      required String id,
      required String activityId,
      required int sequence,
      required double latitude,
      required double longitude,
      Value<double?> gpsAltitude,
      Value<double?> demAltitude,
      Value<double?> speed,
      Value<double?> heading,
      Value<double?> accuracy,
      required int recordedAt,
      Value<int> segmentIndex,
      Value<bool> isAccepted,
      Value<int> rowid,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<int> sequence,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> gpsAltitude,
      Value<double?> demAltitude,
      Value<double?> speed,
      Value<double?> heading,
      Value<double?> accuracy,
      Value<int> recordedAt,
      Value<int> segmentIndex,
      Value<bool> isAccepted,
      Value<int> rowid,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPointRow> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias('track_points__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAccepted => $composableBuilder(
    column: $table.isAccepted,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAccepted => $composableBuilder(
    column: $table.isAccepted,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAccepted => $composableBuilder(
    column: $table.isAccepted,
    builder: (column) => column,
  );

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPointRow,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPointRow, $$TrackPointsTableReferences),
          TrackPointRow,
          PrefetchHooks Function({bool activityId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> demAltitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int> segmentIndex = const Value.absent(),
                Value<bool> isAccepted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                activityId: activityId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                gpsAltitude: gpsAltitude,
                demAltitude: demAltitude,
                speed: speed,
                heading: heading,
                accuracy: accuracy,
                recordedAt: recordedAt,
                segmentIndex: segmentIndex,
                isAccepted: isAccepted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required int sequence,
                required double latitude,
                required double longitude,
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> demAltitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                required int recordedAt,
                Value<int> segmentIndex = const Value.absent(),
                Value<bool> isAccepted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackPointsCompanion.insert(
                id: id,
                activityId: activityId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                gpsAltitude: gpsAltitude,
                demAltitude: demAltitude,
                speed: speed,
                heading: heading,
                accuracy: accuracy,
                recordedAt: recordedAt,
                segmentIndex: segmentIndex,
                isAccepted: isAccepted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable: $$TrackPointsTableReferences
                                    ._activityIdTable(db),
                                referencedColumn: $$TrackPointsTableReferences
                                    ._activityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPointRow,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPointRow, $$TrackPointsTableReferences),
      TrackPointRow,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$ActivityPhotosTableCreateCompanionBuilder =
    ActivityPhotosCompanion Function({
      required String id,
      required String activityId,
      required String localPath,
      required String thumbnailPath,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> gpsAltitude,
      Value<double?> demAltitude,
      required int takenAt,
      Value<int> elapsedSeconds,
      Value<double> distanceMeters,
      Value<String?> caption,
      Value<int> rowid,
    });
typedef $$ActivityPhotosTableUpdateCompanionBuilder =
    ActivityPhotosCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> localPath,
      Value<String> thumbnailPath,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> gpsAltitude,
      Value<double?> demAltitude,
      Value<int> takenAt,
      Value<int> elapsedSeconds,
      Value<double> distanceMeters,
      Value<String?> caption,
      Value<int> rowid,
    });

final class $$ActivityPhotosTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActivityPhotosTable, ActivityPhotoRow> {
  $$ActivityPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias('activity_photos__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityPhotosTable> {
  $$ActivityPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityPhotosTable> {
  $$ActivityPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityPhotosTable> {
  $$ActivityPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get demAltitude => $composableBuilder(
    column: $table.demAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityPhotosTable,
          ActivityPhotoRow,
          $$ActivityPhotosTableFilterComposer,
          $$ActivityPhotosTableOrderingComposer,
          $$ActivityPhotosTableAnnotationComposer,
          $$ActivityPhotosTableCreateCompanionBuilder,
          $$ActivityPhotosTableUpdateCompanionBuilder,
          (ActivityPhotoRow, $$ActivityPhotosTableReferences),
          ActivityPhotoRow,
          PrefetchHooks Function({bool activityId})
        > {
  $$ActivityPhotosTableTableManager(
    _$AppDatabase db,
    $ActivityPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> thumbnailPath = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> demAltitude = const Value.absent(),
                Value<int> takenAt = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityPhotosCompanion(
                id: id,
                activityId: activityId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                latitude: latitude,
                longitude: longitude,
                gpsAltitude: gpsAltitude,
                demAltitude: demAltitude,
                takenAt: takenAt,
                elapsedSeconds: elapsedSeconds,
                distanceMeters: distanceMeters,
                caption: caption,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String localPath,
                required String thumbnailPath,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> demAltitude = const Value.absent(),
                required int takenAt,
                Value<int> elapsedSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityPhotosCompanion.insert(
                id: id,
                activityId: activityId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                latitude: latitude,
                longitude: longitude,
                gpsAltitude: gpsAltitude,
                demAltitude: demAltitude,
                takenAt: takenAt,
                elapsedSeconds: elapsedSeconds,
                distanceMeters: distanceMeters,
                caption: caption,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivityPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable: $$ActivityPhotosTableReferences
                                    ._activityIdTable(db),
                                referencedColumn:
                                    $$ActivityPhotosTableReferences
                                        ._activityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivityPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityPhotosTable,
      ActivityPhotoRow,
      $$ActivityPhotosTableFilterComposer,
      $$ActivityPhotosTableOrderingComposer,
      $$ActivityPhotosTableAnnotationComposer,
      $$ActivityPhotosTableCreateCompanionBuilder,
      $$ActivityPhotosTableUpdateCompanionBuilder,
      (ActivityPhotoRow, $$ActivityPhotosTableReferences),
      ActivityPhotoRow,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$BackupHistoryTableCreateCompanionBuilder =
    BackupHistoryCompanion Function({
      required String id,
      required int createdAt,
      Value<String?> driveFileId,
      required String type,
      Value<int> sizeBytes,
      Value<int> activityCount,
      Value<int> photoCount,
      required String status,
      Value<int> rowid,
    });
typedef $$BackupHistoryTableUpdateCompanionBuilder =
    BackupHistoryCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<String?> driveFileId,
      Value<String> type,
      Value<int> sizeBytes,
      Value<int> activityCount,
      Value<int> photoCount,
      Value<String> status,
      Value<int> rowid,
    });

class $$BackupHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activityCount => $composableBuilder(
    column: $table.activityCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activityCount => $composableBuilder(
    column: $table.activityCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get driveFileId => $composableBuilder(
    column: $table.driveFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get activityCount => $composableBuilder(
    column: $table.activityCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$BackupHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupHistoryTable,
          BackupHistoryRow,
          $$BackupHistoryTableFilterComposer,
          $$BackupHistoryTableOrderingComposer,
          $$BackupHistoryTableAnnotationComposer,
          $$BackupHistoryTableCreateCompanionBuilder,
          $$BackupHistoryTableUpdateCompanionBuilder,
          (
            BackupHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $BackupHistoryTable,
              BackupHistoryRow
            >,
          ),
          BackupHistoryRow,
          PrefetchHooks Function()
        > {
  $$BackupHistoryTableTableManager(_$AppDatabase db, $BackupHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> driveFileId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> activityCount = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion(
                id: id,
                createdAt: createdAt,
                driveFileId: driveFileId,
                type: type,
                sizeBytes: sizeBytes,
                activityCount: activityCount,
                photoCount: photoCount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                Value<String?> driveFileId = const Value.absent(),
                required String type,
                Value<int> sizeBytes = const Value.absent(),
                Value<int> activityCount = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion.insert(
                id: id,
                createdAt: createdAt,
                driveFileId: driveFileId,
                type: type,
                sizeBytes: sizeBytes,
                activityCount: activityCount,
                photoCount: photoCount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupHistoryTable,
      BackupHistoryRow,
      $$BackupHistoryTableFilterComposer,
      $$BackupHistoryTableOrderingComposer,
      $$BackupHistoryTableAnnotationComposer,
      $$BackupHistoryTableCreateCompanionBuilder,
      $$BackupHistoryTableUpdateCompanionBuilder,
      (
        BackupHistoryRow,
        BaseReferences<_$AppDatabase, $BackupHistoryTable, BackupHistoryRow>,
      ),
      BackupHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$ActivityPhotosTableTableManager get activityPhotos =>
      $$ActivityPhotosTableTableManager(_db, _db.activityPhotos);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BackupHistoryTableTableManager get backupHistory =>
      $$BackupHistoryTableTableManager(_db, _db.backupHistory);
}
