// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CallHistoryTableTable extends CallHistoryTable
    with TableInfo<$CallHistoryTableTable, CallHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactNameMeta =
      const VerificationMeta('contactName');
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
      'contact_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 150),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _callTypeMeta =
      const VerificationMeta('callType');
  @override
  late final GeneratedColumn<String> callType = GeneratedColumn<String>(
      'call_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggeredByMeta =
      const VerificationMeta('triggeredBy');
  @override
  late final GeneratedColumn<String> triggeredBy = GeneratedColumn<String>(
      'triggered_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _calledAtMeta =
      const VerificationMeta('calledAt');
  @override
  late final GeneratedColumn<DateTime> calledAt = GeneratedColumn<DateTime>(
      'called_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactName,
        phoneNumber,
        callType,
        triggeredBy,
        durationSeconds,
        calledAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<CallHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_name')) {
      context.handle(
          _contactNameMeta,
          contactName.isAcceptableOrUnknown(
              data['contact_name']!, _contactNameMeta));
    } else if (isInserting) {
      context.missing(_contactNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('call_type')) {
      context.handle(_callTypeMeta,
          callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta));
    } else if (isInserting) {
      context.missing(_callTypeMeta);
    }
    if (data.containsKey('triggered_by')) {
      context.handle(
          _triggeredByMeta,
          triggeredBy.isAcceptableOrUnknown(
              data['triggered_by']!, _triggeredByMeta));
    } else if (isInserting) {
      context.missing(_triggeredByMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('called_at')) {
      context.handle(_calledAtMeta,
          calledAt.isAcceptableOrUnknown(data['called_at']!, _calledAtMeta));
    } else if (isInserting) {
      context.missing(_calledAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      callType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}call_type'])!,
      triggeredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triggered_by'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      calledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}called_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $CallHistoryTableTable createAlias(String alias) {
    return $CallHistoryTableTable(attachedDatabase, alias);
  }
}

class CallHistoryTableData extends DataClass
    implements Insertable<CallHistoryTableData> {
  final int id;
  final String contactName;
  final String phoneNumber;
  final String callType;
  final String triggeredBy;
  final int durationSeconds;
  final DateTime calledAt;
  final bool synced;
  const CallHistoryTableData(
      {required this.id,
      required this.contactName,
      required this.phoneNumber,
      required this.callType,
      required this.triggeredBy,
      required this.durationSeconds,
      required this.calledAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_name'] = Variable<String>(contactName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['call_type'] = Variable<String>(callType);
    map['triggered_by'] = Variable<String>(triggeredBy);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['called_at'] = Variable<DateTime>(calledAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  CallHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return CallHistoryTableCompanion(
      id: Value(id),
      contactName: Value(contactName),
      phoneNumber: Value(phoneNumber),
      callType: Value(callType),
      triggeredBy: Value(triggeredBy),
      durationSeconds: Value(durationSeconds),
      calledAt: Value(calledAt),
      synced: Value(synced),
    );
  }

  factory CallHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      contactName: serializer.fromJson<String>(json['contactName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      callType: serializer.fromJson<String>(json['callType']),
      triggeredBy: serializer.fromJson<String>(json['triggeredBy']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      calledAt: serializer.fromJson<DateTime>(json['calledAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactName': serializer.toJson<String>(contactName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'callType': serializer.toJson<String>(callType),
      'triggeredBy': serializer.toJson<String>(triggeredBy),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'calledAt': serializer.toJson<DateTime>(calledAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  CallHistoryTableData copyWith(
          {int? id,
          String? contactName,
          String? phoneNumber,
          String? callType,
          String? triggeredBy,
          int? durationSeconds,
          DateTime? calledAt,
          bool? synced}) =>
      CallHistoryTableData(
        id: id ?? this.id,
        contactName: contactName ?? this.contactName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        callType: callType ?? this.callType,
        triggeredBy: triggeredBy ?? this.triggeredBy,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        calledAt: calledAt ?? this.calledAt,
        synced: synced ?? this.synced,
      );
  CallHistoryTableData copyWithCompanion(CallHistoryTableCompanion data) {
    return CallHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      contactName:
          data.contactName.present ? data.contactName.value : this.contactName,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      callType: data.callType.present ? data.callType.value : this.callType,
      triggeredBy:
          data.triggeredBy.present ? data.triggeredBy.value : this.triggeredBy,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      calledAt: data.calledAt.present ? data.calledAt.value : this.calledAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryTableData(')
          ..write('id: $id, ')
          ..write('contactName: $contactName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callType: $callType, ')
          ..write('triggeredBy: $triggeredBy, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('calledAt: $calledAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactName, phoneNumber, callType,
      triggeredBy, durationSeconds, calledAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallHistoryTableData &&
          other.id == this.id &&
          other.contactName == this.contactName &&
          other.phoneNumber == this.phoneNumber &&
          other.callType == this.callType &&
          other.triggeredBy == this.triggeredBy &&
          other.durationSeconds == this.durationSeconds &&
          other.calledAt == this.calledAt &&
          other.synced == this.synced);
}

class CallHistoryTableCompanion extends UpdateCompanion<CallHistoryTableData> {
  final Value<int> id;
  final Value<String> contactName;
  final Value<String> phoneNumber;
  final Value<String> callType;
  final Value<String> triggeredBy;
  final Value<int> durationSeconds;
  final Value<DateTime> calledAt;
  final Value<bool> synced;
  const CallHistoryTableCompanion({
    this.id = const Value.absent(),
    this.contactName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.callType = const Value.absent(),
    this.triggeredBy = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.calledAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  CallHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String contactName,
    required String phoneNumber,
    required String callType,
    required String triggeredBy,
    this.durationSeconds = const Value.absent(),
    required DateTime calledAt,
    this.synced = const Value.absent(),
  })  : contactName = Value(contactName),
        phoneNumber = Value(phoneNumber),
        callType = Value(callType),
        triggeredBy = Value(triggeredBy),
        calledAt = Value(calledAt);
  static Insertable<CallHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? contactName,
    Expression<String>? phoneNumber,
    Expression<String>? callType,
    Expression<String>? triggeredBy,
    Expression<int>? durationSeconds,
    Expression<DateTime>? calledAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactName != null) 'contact_name': contactName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (callType != null) 'call_type': callType,
      if (triggeredBy != null) 'triggered_by': triggeredBy,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (calledAt != null) 'called_at': calledAt,
      if (synced != null) 'synced': synced,
    });
  }

  CallHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactName,
      Value<String>? phoneNumber,
      Value<String>? callType,
      Value<String>? triggeredBy,
      Value<int>? durationSeconds,
      Value<DateTime>? calledAt,
      Value<bool>? synced}) {
    return CallHistoryTableCompanion(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      callType: callType ?? this.callType,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      calledAt: calledAt ?? this.calledAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<String>(callType.value);
    }
    if (triggeredBy.present) {
      map['triggered_by'] = Variable<String>(triggeredBy.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (calledAt.present) {
      map['called_at'] = Variable<DateTime>(calledAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('contactName: $contactName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callType: $callType, ')
          ..write('triggeredBy: $triggeredBy, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('calledAt: $calledAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $ContactsCacheTableTable extends ContactsCacheTable
    with TableInfo<$ContactsCacheTableTable, ContactsCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 150),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _normalizedNameMeta =
      const VerificationMeta('normalizedName');
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
      'normalized_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneLabelMeta =
      const VerificationMeta('phoneLabel');
  @override
  late final GeneratedColumn<String> phoneLabel = GeneratedColumn<String>(
      'phone_label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mobile'));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactId,
        displayName,
        normalizedName,
        phoneNumber,
        phoneLabel,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ContactsCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
          _normalizedNameMeta,
          normalizedName.isAcceptableOrUnknown(
              data['normalized_name']!, _normalizedNameMeta));
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('phone_label')) {
      context.handle(
          _phoneLabelMeta,
          phoneLabel.isAcceptableOrUnknown(
              data['phone_label']!, _phoneLabelMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactsCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactsCacheTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      normalizedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      phoneLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_label'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $ContactsCacheTableTable createAlias(String alias) {
    return $ContactsCacheTableTable(attachedDatabase, alias);
  }
}

class ContactsCacheTableData extends DataClass
    implements Insertable<ContactsCacheTableData> {
  final int id;
  final String contactId;
  final String displayName;
  final String normalizedName;
  final String phoneNumber;
  final String phoneLabel;
  final DateTime cachedAt;
  const ContactsCacheTableData(
      {required this.id,
      required this.contactId,
      required this.displayName,
      required this.normalizedName,
      required this.phoneNumber,
      required this.phoneLabel,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['display_name'] = Variable<String>(displayName);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['phone_label'] = Variable<String>(phoneLabel);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  ContactsCacheTableCompanion toCompanion(bool nullToAbsent) {
    return ContactsCacheTableCompanion(
      id: Value(id),
      contactId: Value(contactId),
      displayName: Value(displayName),
      normalizedName: Value(normalizedName),
      phoneNumber: Value(phoneNumber),
      phoneLabel: Value(phoneLabel),
      cachedAt: Value(cachedAt),
    );
  }

  factory ContactsCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactsCacheTableData(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      phoneLabel: serializer.fromJson<String>(json['phoneLabel']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<String>(contactId),
      'displayName': serializer.toJson<String>(displayName),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'phoneLabel': serializer.toJson<String>(phoneLabel),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  ContactsCacheTableData copyWith(
          {int? id,
          String? contactId,
          String? displayName,
          String? normalizedName,
          String? phoneNumber,
          String? phoneLabel,
          DateTime? cachedAt}) =>
      ContactsCacheTableData(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        displayName: displayName ?? this.displayName,
        normalizedName: normalizedName ?? this.normalizedName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        phoneLabel: phoneLabel ?? this.phoneLabel,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  ContactsCacheTableData copyWithCompanion(ContactsCacheTableCompanion data) {
    return ContactsCacheTableData(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      phoneLabel:
          data.phoneLabel.present ? data.phoneLabel.value : this.phoneLabel,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCacheTableData(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('phoneLabel: $phoneLabel, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, displayName, normalizedName,
      phoneNumber, phoneLabel, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactsCacheTableData &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.displayName == this.displayName &&
          other.normalizedName == this.normalizedName &&
          other.phoneNumber == this.phoneNumber &&
          other.phoneLabel == this.phoneLabel &&
          other.cachedAt == this.cachedAt);
}

class ContactsCacheTableCompanion
    extends UpdateCompanion<ContactsCacheTableData> {
  final Value<int> id;
  final Value<String> contactId;
  final Value<String> displayName;
  final Value<String> normalizedName;
  final Value<String> phoneNumber;
  final Value<String> phoneLabel;
  final Value<DateTime> cachedAt;
  const ContactsCacheTableCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.phoneLabel = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  ContactsCacheTableCompanion.insert({
    this.id = const Value.absent(),
    required String contactId,
    required String displayName,
    required String normalizedName,
    required String phoneNumber,
    this.phoneLabel = const Value.absent(),
    required DateTime cachedAt,
  })  : contactId = Value(contactId),
        displayName = Value(displayName),
        normalizedName = Value(normalizedName),
        phoneNumber = Value(phoneNumber),
        cachedAt = Value(cachedAt);
  static Insertable<ContactsCacheTableData> custom({
    Expression<int>? id,
    Expression<String>? contactId,
    Expression<String>? displayName,
    Expression<String>? normalizedName,
    Expression<String>? phoneNumber,
    Expression<String>? phoneLabel,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (displayName != null) 'display_name': displayName,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (phoneLabel != null) 'phone_label': phoneLabel,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  ContactsCacheTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactId,
      Value<String>? displayName,
      Value<String>? normalizedName,
      Value<String>? phoneNumber,
      Value<String>? phoneLabel,
      Value<DateTime>? cachedAt}) {
    return ContactsCacheTableCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      displayName: displayName ?? this.displayName,
      normalizedName: normalizedName ?? this.normalizedName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneLabel: phoneLabel ?? this.phoneLabel,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (phoneLabel.present) {
      map['phone_label'] = Variable<String>(phoneLabel.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('phoneLabel: $phoneLabel, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CallHistoryTableTable callHistoryTable =
      $CallHistoryTableTable(this);
  late final $ContactsCacheTableTable contactsCacheTable =
      $ContactsCacheTableTable(this);
  late final CallHistoryDao callHistoryDao =
      CallHistoryDao(this as AppDatabase);
  late final ContactsDao contactsDao = ContactsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [callHistoryTable, contactsCacheTable];
}

typedef $$CallHistoryTableTableCreateCompanionBuilder
    = CallHistoryTableCompanion Function({
  Value<int> id,
  required String contactName,
  required String phoneNumber,
  required String callType,
  required String triggeredBy,
  Value<int> durationSeconds,
  required DateTime calledAt,
  Value<bool> synced,
});
typedef $$CallHistoryTableTableUpdateCompanionBuilder
    = CallHistoryTableCompanion Function({
  Value<int> id,
  Value<String> contactName,
  Value<String> phoneNumber,
  Value<String> callType,
  Value<String> triggeredBy,
  Value<int> durationSeconds,
  Value<DateTime> calledAt,
  Value<bool> synced,
});

class $$CallHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $CallHistoryTableTable> {
  $$CallHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactName => $composableBuilder(
      column: $table.contactName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get callType => $composableBuilder(
      column: $table.callType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggeredBy => $composableBuilder(
      column: $table.triggeredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get calledAt => $composableBuilder(
      column: $table.calledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$CallHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CallHistoryTableTable> {
  $$CallHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactName => $composableBuilder(
      column: $table.contactName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get callType => $composableBuilder(
      column: $table.callType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggeredBy => $composableBuilder(
      column: $table.triggeredBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get calledAt => $composableBuilder(
      column: $table.calledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$CallHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallHistoryTableTable> {
  $$CallHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contactName => $composableBuilder(
      column: $table.contactName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get triggeredBy => $composableBuilder(
      column: $table.triggeredBy, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get calledAt =>
      $composableBuilder(column: $table.calledAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$CallHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CallHistoryTableTable,
    CallHistoryTableData,
    $$CallHistoryTableTableFilterComposer,
    $$CallHistoryTableTableOrderingComposer,
    $$CallHistoryTableTableAnnotationComposer,
    $$CallHistoryTableTableCreateCompanionBuilder,
    $$CallHistoryTableTableUpdateCompanionBuilder,
    (
      CallHistoryTableData,
      BaseReferences<_$AppDatabase, $CallHistoryTableTable,
          CallHistoryTableData>
    ),
    CallHistoryTableData,
    PrefetchHooks Function()> {
  $$CallHistoryTableTableTableManager(
      _$AppDatabase db, $CallHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> callType = const Value.absent(),
            Value<String> triggeredBy = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<DateTime> calledAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              CallHistoryTableCompanion(
            id: id,
            contactName: contactName,
            phoneNumber: phoneNumber,
            callType: callType,
            triggeredBy: triggeredBy,
            durationSeconds: durationSeconds,
            calledAt: calledAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactName,
            required String phoneNumber,
            required String callType,
            required String triggeredBy,
            Value<int> durationSeconds = const Value.absent(),
            required DateTime calledAt,
            Value<bool> synced = const Value.absent(),
          }) =>
              CallHistoryTableCompanion.insert(
            id: id,
            contactName: contactName,
            phoneNumber: phoneNumber,
            callType: callType,
            triggeredBy: triggeredBy,
            durationSeconds: durationSeconds,
            calledAt: calledAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CallHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CallHistoryTableTable,
    CallHistoryTableData,
    $$CallHistoryTableTableFilterComposer,
    $$CallHistoryTableTableOrderingComposer,
    $$CallHistoryTableTableAnnotationComposer,
    $$CallHistoryTableTableCreateCompanionBuilder,
    $$CallHistoryTableTableUpdateCompanionBuilder,
    (
      CallHistoryTableData,
      BaseReferences<_$AppDatabase, $CallHistoryTableTable,
          CallHistoryTableData>
    ),
    CallHistoryTableData,
    PrefetchHooks Function()>;
typedef $$ContactsCacheTableTableCreateCompanionBuilder
    = ContactsCacheTableCompanion Function({
  Value<int> id,
  required String contactId,
  required String displayName,
  required String normalizedName,
  required String phoneNumber,
  Value<String> phoneLabel,
  required DateTime cachedAt,
});
typedef $$ContactsCacheTableTableUpdateCompanionBuilder
    = ContactsCacheTableCompanion Function({
  Value<int> id,
  Value<String> contactId,
  Value<String> displayName,
  Value<String> normalizedName,
  Value<String> phoneNumber,
  Value<String> phoneLabel,
  Value<DateTime> cachedAt,
});

class $$ContactsCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsCacheTableTable> {
  $$ContactsCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneLabel => $composableBuilder(
      column: $table.phoneLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$ContactsCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsCacheTableTable> {
  $$ContactsCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneLabel => $composableBuilder(
      column: $table.phoneLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$ContactsCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsCacheTableTable> {
  $$ContactsCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get phoneLabel => $composableBuilder(
      column: $table.phoneLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$ContactsCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsCacheTableTable,
    ContactsCacheTableData,
    $$ContactsCacheTableTableFilterComposer,
    $$ContactsCacheTableTableOrderingComposer,
    $$ContactsCacheTableTableAnnotationComposer,
    $$ContactsCacheTableTableCreateCompanionBuilder,
    $$ContactsCacheTableTableUpdateCompanionBuilder,
    (
      ContactsCacheTableData,
      BaseReferences<_$AppDatabase, $ContactsCacheTableTable,
          ContactsCacheTableData>
    ),
    ContactsCacheTableData,
    PrefetchHooks Function()> {
  $$ContactsCacheTableTableTableManager(
      _$AppDatabase db, $ContactsCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsCacheTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> normalizedName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> phoneLabel = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              ContactsCacheTableCompanion(
            id: id,
            contactId: contactId,
            displayName: displayName,
            normalizedName: normalizedName,
            phoneNumber: phoneNumber,
            phoneLabel: phoneLabel,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactId,
            required String displayName,
            required String normalizedName,
            required String phoneNumber,
            Value<String> phoneLabel = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              ContactsCacheTableCompanion.insert(
            id: id,
            contactId: contactId,
            displayName: displayName,
            normalizedName: normalizedName,
            phoneNumber: phoneNumber,
            phoneLabel: phoneLabel,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContactsCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsCacheTableTable,
    ContactsCacheTableData,
    $$ContactsCacheTableTableFilterComposer,
    $$ContactsCacheTableTableOrderingComposer,
    $$ContactsCacheTableTableAnnotationComposer,
    $$ContactsCacheTableTableCreateCompanionBuilder,
    $$ContactsCacheTableTableUpdateCompanionBuilder,
    (
      ContactsCacheTableData,
      BaseReferences<_$AppDatabase, $ContactsCacheTableTable,
          ContactsCacheTableData>
    ),
    ContactsCacheTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CallHistoryTableTableTableManager get callHistoryTable =>
      $$CallHistoryTableTableTableManager(_db, _db.callHistoryTable);
  $$ContactsCacheTableTableTableManager get contactsCacheTable =>
      $$ContactsCacheTableTableTableManager(_db, _db.contactsCacheTable);
}
