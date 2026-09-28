// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RulesTable extends Rules with TableInfo<$RulesTable, Rule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMinutesMeta = const VerificationMeta(
    'intervalMinutes',
  );
  @override
  late final GeneratedColumn<int> intervalMinutes = GeneratedColumn<int>(
    'interval_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    startMinute,
    endMinute,
    intervalMinutes,
    weekdayMask,
    isEnabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('interval_minutes')) {
      context.handle(
        _intervalMinutesMeta,
        intervalMinutes.isAcceptableOrUnknown(
          data['interval_minutes']!,
          _intervalMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalMinutesMeta);
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      intervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_minutes'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class Rule extends DataClass implements Insertable<Rule> {
  final String id;
  final String label;

  /// Gün başından itibaren dakika, 0-1439.
  final int startMinute;
  final int endMinute;
  final int intervalMinutes;

  /// Haftanın günleri bit maskesi: pazartesi = 1<<0 ... pazar = 1<<6.
  /// 0 ise kural tek seferliktir.
  final int weekdayMask;
  final bool isEnabled;
  final DateTime createdAt;
  const Rule({
    required this.id,
    required this.label,
    required this.startMinute,
    required this.endMinute,
    required this.intervalMinutes,
    required this.weekdayMask,
    required this.isEnabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['interval_minutes'] = Variable<int>(intervalMinutes);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      label: Value(label),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      intervalMinutes: Value(intervalMinutes),
      weekdayMask: Value(weekdayMask),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory Rule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rule(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      intervalMinutes: serializer.fromJson<int>(json['intervalMinutes']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'intervalMinutes': serializer.toJson<int>(intervalMinutes),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Rule copyWith({
    String? id,
    String? label,
    int? startMinute,
    int? endMinute,
    int? intervalMinutes,
    int? weekdayMask,
    bool? isEnabled,
    DateTime? createdAt,
  }) => Rule(
    id: id ?? this.id,
    label: label ?? this.label,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
  );
  Rule copyWithCompanion(RulesCompanion data) {
    return Rule(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      intervalMinutes: data.intervalMinutes.present
          ? data.intervalMinutes.value
          : this.intervalMinutes,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rule(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    startMinute,
    endMinute,
    intervalMinutes,
    weekdayMask,
    isEnabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rule &&
          other.id == this.id &&
          other.label == this.label &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.intervalMinutes == this.intervalMinutes &&
          other.weekdayMask == this.weekdayMask &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt);
}

class RulesCompanion extends UpdateCompanion<Rule> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<int> intervalMinutes;
  final Value<int> weekdayMask;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RulesCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    required int startMinute,
    required int endMinute,
    required int intervalMinutes,
    this.weekdayMask = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       intervalMinutes = Value(intervalMinutes),
       createdAt = Value(createdAt);
  static Insertable<Rule> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? intervalMinutes,
    Expression<int>? weekdayMask,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (intervalMinutes != null) 'interval_minutes': intervalMinutes,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RulesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<int>? intervalMinutes,
    Value<int>? weekdayMask,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      isEnabled: isEnabled ?? this.isEnabled,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (intervalMinutes.present) {
      map['interval_minutes'] = Variable<int>(intervalMinutes.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledAlarmsTable extends ScheduledAlarms
    with TableInfo<$ScheduledAlarmsTable, ScheduledAlarm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledAlarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rules (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _ranAtMeta = const VerificationMeta('ranAt');
  @override
  late final GeneratedColumn<DateTime> ranAt = GeneratedColumn<DateTime>(
    'ran_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ruleId, fireAt, status, ranAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_alarms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledAlarm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ran_at')) {
      context.handle(
        _ranAtMeta,
        ranAt.isAcceptableOrUnknown(data['ran_at']!, _ranAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledAlarm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledAlarm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      ranAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ran_at'],
      ),
    );
  }

  @override
  $ScheduledAlarmsTable createAlias(String alias) {
    return $ScheduledAlarmsTable(attachedDatabase, alias);
  }
}

class ScheduledAlarm extends DataClass implements Insertable<ScheduledAlarm> {
  /// Aynı zamanda işletim sistemine verilen alarm kimliği.
  final String id;
  final String ruleId;

  /// Alarmın çalacağı yerel zaman.
  final DateTime fireAt;

  /// pending | rang | dismissed | snoozed
  final String status;
  final DateTime? ranAt;
  const ScheduledAlarm({
    required this.id,
    required this.ruleId,
    required this.fireAt,
    required this.status,
    this.ranAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || ranAt != null) {
      map['ran_at'] = Variable<DateTime>(ranAt);
    }
    return map;
  }

  ScheduledAlarmsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledAlarmsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      fireAt: Value(fireAt),
      status: Value(status),
      ranAt: ranAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ranAt),
    );
  }

  factory ScheduledAlarm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledAlarm(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      status: serializer.fromJson<String>(json['status']),
      ranAt: serializer.fromJson<DateTime?>(json['ranAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'status': serializer.toJson<String>(status),
      'ranAt': serializer.toJson<DateTime?>(ranAt),
    };
  }

  ScheduledAlarm copyWith({
    String? id,
    String? ruleId,
    DateTime? fireAt,
    String? status,
    Value<DateTime?> ranAt = const Value.absent(),
  }) => ScheduledAlarm(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    fireAt: fireAt ?? this.fireAt,
    status: status ?? this.status,
    ranAt: ranAt.present ? ranAt.value : this.ranAt,
  );
  ScheduledAlarm copyWithCompanion(ScheduledAlarmsCompanion data) {
    return ScheduledAlarm(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      status: data.status.present ? data.status.value : this.status,
      ranAt: data.ranAt.present ? data.ranAt.value : this.ranAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledAlarm(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('ranAt: $ranAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ruleId, fireAt, status, ranAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledAlarm &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.fireAt == this.fireAt &&
          other.status == this.status &&
          other.ranAt == this.ranAt);
}

class ScheduledAlarmsCompanion extends UpdateCompanion<ScheduledAlarm> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<DateTime> fireAt;
  final Value<String> status;
  final Value<DateTime?> ranAt;
  final Value<int> rowid;
  const ScheduledAlarmsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.status = const Value.absent(),
    this.ranAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledAlarmsCompanion.insert({
    required String id,
    required String ruleId,
    required DateTime fireAt,
    this.status = const Value.absent(),
    this.ranAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       fireAt = Value(fireAt);
  static Insertable<ScheduledAlarm> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<DateTime>? fireAt,
    Expression<String>? status,
    Expression<DateTime>? ranAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (fireAt != null) 'fire_at': fireAt,
      if (status != null) 'status': status,
      if (ranAt != null) 'ran_at': ranAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledAlarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleId,
    Value<DateTime>? fireAt,
    Value<String>? status,
    Value<DateTime?>? ranAt,
    Value<int>? rowid,
  }) {
    return ScheduledAlarmsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      fireAt: fireAt ?? this.fireAt,
      status: status ?? this.status,
      ranAt: ranAt ?? this.ranAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ranAt.present) {
      map['ran_at'] = Variable<DateTime>(ranAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledAlarmsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('ranAt: $ranAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $ScheduledAlarmsTable scheduledAlarms = $ScheduledAlarmsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rules, scheduledAlarms];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scheduled_alarms', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RulesTableCreateCompanionBuilder = RulesCompanion Function({
  required String id,
  Value<String> label,
  required int startMinute,
  required int endMinute,
  required int intervalMinutes,
  Value<int> weekdayMask,
  Value<bool> isEnabled,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RulesTableUpdateCompanionBuilder = RulesCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<int> startMinute,
  Value<int> endMinute,
  Value<int> intervalMinutes,
  Value<int> weekdayMask,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$RulesTableReferences
    extends BaseReferences<_$AppDatabase, $RulesTable, Rule> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScheduledAlarmsTable, List<ScheduledAlarm>>
  _scheduledAlarmsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduledAlarms,
    aliasName: 'rules__id__scheduled_alarms__rule_id',
  );

  $$ScheduledAlarmsTableProcessedTableManager get scheduledAlarmsRefs {
    final manager = $$ScheduledAlarmsTableTableManager(
      $_db,
      $_db.scheduledAlarms,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduledAlarmsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RulesTableFilterComposer extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduledAlarmsRefs(
    Expression<bool> Function($$ScheduledAlarmsTableFilterComposer f) f,
  ) {
    final $$ScheduledAlarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduledAlarms,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduledAlarmsTableFilterComposer(
            $db: $db,
            $table: $db.scheduledAlarms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> scheduledAlarmsRefs<T extends Object>(
    Expression<T> Function($$ScheduledAlarmsTableAnnotationComposer a) f,
  ) {
    final $$ScheduledAlarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduledAlarms,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduledAlarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduledAlarms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RulesTable,
          Rule,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (Rule, $$RulesTableReferences),
          Rule,
          PrefetchHooks Function({bool scheduledAlarmsRefs})
        > {
  $$RulesTableTableManager(_$AppDatabase db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                label: label,
                startMinute: startMinute,
                endMinute: endMinute,
                intervalMinutes: intervalMinutes,
                weekdayMask: weekdayMask,
                isEnabled: isEnabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> label = const Value.absent(),
                required int startMinute,
                required int endMinute,
                required int intervalMinutes,
                Value<int> weekdayMask = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                label: label,
                startMinute: startMinute,
                endMinute: endMinute,
                intervalMinutes: intervalMinutes,
                weekdayMask: weekdayMask,
                isEnabled: isEnabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RulesTable, Rule>(table),
                  $$RulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scheduledAlarmsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scheduledAlarmsRefs) db.scheduledAlarms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scheduledAlarmsRefs)
                    await $_getPrefetchedData<
                      Rule,
                      $RulesTable,
                      ScheduledAlarm
                    >(
                      currentTable: table,
                      referencedTable: $$RulesTableReferences
                          ._scheduledAlarmsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RulesTableReferences(
                        db,
                        table,
                        p0,
                      ).scheduledAlarmsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ruleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RulesTable,
      Rule,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (Rule, $$RulesTableReferences),
      Rule,
      PrefetchHooks Function({bool scheduledAlarmsRefs})
    >;
typedef $$ScheduledAlarmsTableCreateCompanionBuilder =
    ScheduledAlarmsCompanion Function({
      required String id,
      required String ruleId,
      required DateTime fireAt,
      Value<String> status,
      Value<DateTime?> ranAt,
      Value<int> rowid,
    });
typedef $$ScheduledAlarmsTableUpdateCompanionBuilder =
    ScheduledAlarmsCompanion Function({
      Value<String> id,
      Value<String> ruleId,
      Value<DateTime> fireAt,
      Value<String> status,
      Value<DateTime?> ranAt,
      Value<int> rowid,
    });

final class $$ScheduledAlarmsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScheduledAlarmsTable, ScheduledAlarm> {
  $$ScheduledAlarmsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RulesTable _ruleIdTable(_$AppDatabase db) =>
      db.rules.createAlias('scheduled_alarms__rule_id__rules__id');

  $$RulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<String>('rule_id')!;

    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduledAlarmsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledAlarmsTable> {
  $$ScheduledAlarmsTableFilterComposer({
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

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ranAt => $composableBuilder(
    column: $table.ranAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RulesTableFilterComposer get ruleId {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledAlarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledAlarmsTable> {
  $$ScheduledAlarmsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ranAt => $composableBuilder(
    column: $table.ranAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RulesTableOrderingComposer get ruleId {
    final $$RulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableOrderingComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledAlarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledAlarmsTable> {
  $$ScheduledAlarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get ranAt =>
      $composableBuilder(column: $table.ranAt, builder: (column) => column);

  $$RulesTableAnnotationComposer get ruleId {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledAlarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledAlarmsTable,
          ScheduledAlarm,
          $$ScheduledAlarmsTableFilterComposer,
          $$ScheduledAlarmsTableOrderingComposer,
          $$ScheduledAlarmsTableAnnotationComposer,
          $$ScheduledAlarmsTableCreateCompanionBuilder,
          $$ScheduledAlarmsTableUpdateCompanionBuilder,
          (ScheduledAlarm, $$ScheduledAlarmsTableReferences),
          ScheduledAlarm,
          PrefetchHooks Function({bool ruleId})
        > {
  $$ScheduledAlarmsTableTableManager(
    _$AppDatabase db,
    $ScheduledAlarmsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledAlarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledAlarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledAlarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> ranAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduledAlarmsCompanion(
                id: id,
                ruleId: ruleId,
                fireAt: fireAt,
                status: status,
                ranAt: ranAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleId,
                required DateTime fireAt,
                Value<String> status = const Value.absent(),
                Value<DateTime?> ranAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduledAlarmsCompanion.insert(
                id: id,
                ruleId: ruleId,
                fireAt: fireAt,
                status: status,
                ranAt: ranAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduledAlarmsTable, ScheduledAlarm>(table),
                  $$ScheduledAlarmsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false}) {
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
                    if (ruleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ruleId,
                        referencedTable: $$ScheduledAlarmsTableReferences
                            ._ruleIdTable(db),
                        referencedColumn: $$ScheduledAlarmsTableReferences
                            ._ruleIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ScheduledAlarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledAlarmsTable,
      ScheduledAlarm,
      $$ScheduledAlarmsTableFilterComposer,
      $$ScheduledAlarmsTableOrderingComposer,
      $$ScheduledAlarmsTableAnnotationComposer,
      $$ScheduledAlarmsTableCreateCompanionBuilder,
      $$ScheduledAlarmsTableUpdateCompanionBuilder,
      (ScheduledAlarm, $$ScheduledAlarmsTableReferences),
      ScheduledAlarm,
      PrefetchHooks Function({bool ruleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$ScheduledAlarmsTableTableManager get scheduledAlarms =>
      $$ScheduledAlarmsTableTableManager(_db, _db.scheduledAlarms);
}
