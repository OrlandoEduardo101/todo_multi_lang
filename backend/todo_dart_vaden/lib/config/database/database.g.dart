// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<UuidValue> id = GeneratedColumn<UuidValue>(
    'id',
    aliasedName,
    false,
    type: PgTypes.uuid,
    requiredDuringInsert: false,
    defaultValue: genRandomUuid(),
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
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> roles =
      GeneratedColumn<String>(
        'roles',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($UsersTableTable.$converterroles);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> createdAt =
      GeneratedColumn<PgDateTime>(
        'created_at',
        aliasedName,
        false,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
        clientDefault: () => PgDateTime(DateTime.now()),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> updatedAt =
      GeneratedColumn<PgDateTime>(
        'updated_at',
        aliasedName,
        false,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
        clientDefault: () => PgDateTime(DateTime.now()),
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> deletedAt =
      GeneratedColumn<PgDateTime>(
        'deleted_at',
        aliasedName,
        true,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    firstName,
    lastName,
    email,
    password,
    roles,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      id: attachedDatabase.typeMapping.read(
        PgTypes.uuid,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      roles: $UsersTableTable.$converterroles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}roles'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterroles =
      const RolesConverter();
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final UuidValue id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String email;
  final String password;
  final List<String> roles;
  final PgDateTime createdAt;
  final PgDateTime updatedAt;
  final PgDateTime? deletedAt;
  const UsersTableData({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    required this.password,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<UuidValue>(id, PgTypes.uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    {
      map['roles'] = Variable<String>(
        $UsersTableTable.$converterroles.toSql(roles),
      );
    }
    map['created_at'] = Variable<PgDateTime>(
      createdAt,
      PgTypes.timestampNoTimezone,
    );
    map['updated_at'] = Variable<PgDateTime>(
      updatedAt,
      PgTypes.timestampNoTimezone,
    );
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<PgDateTime>(
        deletedAt,
        PgTypes.timestampNoTimezone,
      );
    }
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      name: Value(name),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      email: Value(email),
      password: Value(password),
      roles: Value(roles),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UsersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<UuidValue>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      roles: serializer.fromJson<List<String>>(json['roles']),
      createdAt: serializer.fromJson<PgDateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<PgDateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<PgDateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<UuidValue>(id),
      'name': serializer.toJson<String>(name),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'roles': serializer.toJson<List<String>>(roles),
      'createdAt': serializer.toJson<PgDateTime>(createdAt),
      'updatedAt': serializer.toJson<PgDateTime>(updatedAt),
      'deletedAt': serializer.toJson<PgDateTime?>(deletedAt),
    };
  }

  UsersTableData copyWith({
    UuidValue? id,
    String? name,
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    String? email,
    String? password,
    List<String>? roles,
    PgDateTime? createdAt,
    PgDateTime? updatedAt,
    Value<PgDateTime?> deletedAt = const Value.absent(),
  }) => UsersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    email: email ?? this.email,
    password: password ?? this.password,
    roles: roles ?? this.roles,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      roles: data.roles.present ? data.roles.value : this.roles,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('roles: $roles, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    firstName,
    lastName,
    email,
    password,
    roles,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.password == this.password &&
          other.roles == this.roles &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<UuidValue> id;
  final Value<String> name;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String> email;
  final Value<String> password;
  final Value<List<String>> roles;
  final Value<PgDateTime> createdAt;
  final Value<PgDateTime> updatedAt;
  final Value<PgDateTime?> deletedAt;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.roles = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    required String email,
    required String password,
    required List<String> roles,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       email = Value(email),
       password = Value(password),
       roles = Value(roles);
  static Insertable<UsersTableData> custom({
    Expression<UuidValue>? id,
    Expression<String>? name,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? roles,
    Expression<PgDateTime>? createdAt,
    Expression<PgDateTime>? updatedAt,
    Expression<PgDateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (roles != null) 'roles': roles,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<UuidValue>? id,
    Value<String>? name,
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String>? email,
    Value<String>? password,
    Value<List<String>>? roles,
    Value<PgDateTime>? createdAt,
    Value<PgDateTime>? updatedAt,
    Value<PgDateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<UuidValue>(id.value, PgTypes.uuid);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (roles.present) {
      map['roles'] = Variable<String>(
        $UsersTableTable.$converterroles.toSql(roles.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<PgDateTime>(
        createdAt.value,
        PgTypes.timestampNoTimezone,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<PgDateTime>(
        updatedAt.value,
        PgTypes.timestampNoTimezone,
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<PgDateTime>(
        deletedAt.value,
        PgTypes.timestampNoTimezone,
      );
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
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('roles: $roles, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTableTable extends TodosTable
    with TableInfo<$TodosTableTable, TodosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<UuidValue> id = GeneratedColumn<UuidValue>(
    'id',
    aliasedName,
    false,
    type: PgTypes.uuid,
    requiredDuringInsert: false,
    defaultValue: genRandomUuid(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<UuidValue> userId = GeneratedColumn<UuidValue>(
    'user_id',
    aliasedName,
    false,
    type: PgTypes.uuid,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> createdAt =
      GeneratedColumn<PgDateTime>(
        'created_at',
        aliasedName,
        false,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
        clientDefault: () => PgDateTime(DateTime.now()),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> updatedAt =
      GeneratedColumn<PgDateTime>(
        'updated_at',
        aliasedName,
        false,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
        clientDefault: () => PgDateTime(DateTime.now()),
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<PgDateTime> deletedAt =
      GeneratedColumn<PgDateTime>(
        'deleted_at',
        aliasedName,
        true,
        type: PgTypes.timestampNoTimezone,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    description,
    completed,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodosTableData(
      id: attachedDatabase.typeMapping.read(
        PgTypes.uuid,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        PgTypes.uuid,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        PgTypes.timestampNoTimezone,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TodosTableTable createAlias(String alias) {
    return $TodosTableTable(attachedDatabase, alias);
  }
}

class TodosTableData extends DataClass implements Insertable<TodosTableData> {
  final UuidValue id;
  final UuidValue userId;
  final String title;
  final String? description;
  final bool completed;
  final PgDateTime createdAt;
  final PgDateTime updatedAt;
  final PgDateTime? deletedAt;
  const TodosTableData({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<UuidValue>(id, PgTypes.uuid);
    map['user_id'] = Variable<UuidValue>(userId, PgTypes.uuid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['completed'] = Variable<bool>(completed);
    map['created_at'] = Variable<PgDateTime>(
      createdAt,
      PgTypes.timestampNoTimezone,
    );
    map['updated_at'] = Variable<PgDateTime>(
      updatedAt,
      PgTypes.timestampNoTimezone,
    );
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<PgDateTime>(
        deletedAt,
        PgTypes.timestampNoTimezone,
      );
    }
    return map;
  }

  TodosTableCompanion toCompanion(bool nullToAbsent) {
    return TodosTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      completed: Value(completed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TodosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodosTableData(
      id: serializer.fromJson<UuidValue>(json['id']),
      userId: serializer.fromJson<UuidValue>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      completed: serializer.fromJson<bool>(json['completed']),
      createdAt: serializer.fromJson<PgDateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<PgDateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<PgDateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<UuidValue>(id),
      'userId': serializer.toJson<UuidValue>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'completed': serializer.toJson<bool>(completed),
      'createdAt': serializer.toJson<PgDateTime>(createdAt),
      'updatedAt': serializer.toJson<PgDateTime>(updatedAt),
      'deletedAt': serializer.toJson<PgDateTime?>(deletedAt),
    };
  }

  TodosTableData copyWith({
    UuidValue? id,
    UuidValue? userId,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? completed,
    PgDateTime? createdAt,
    PgDateTime? updatedAt,
    Value<PgDateTime?> deletedAt = const Value.absent(),
  }) => TodosTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    completed: completed ?? this.completed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TodosTableData copyWithCompanion(TodosTableCompanion data) {
    return TodosTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      completed: data.completed.present ? data.completed.value : this.completed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodosTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    description,
    completed,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodosTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.completed == this.completed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TodosTableCompanion extends UpdateCompanion<TodosTableData> {
  final Value<UuidValue> id;
  final Value<UuidValue> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> completed;
  final Value<PgDateTime> createdAt;
  final Value<PgDateTime> updatedAt;
  final Value<PgDateTime?> deletedAt;
  final Value<int> rowid;
  const TodosTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosTableCompanion.insert({
    this.id = const Value.absent(),
    required UuidValue userId,
    required String title,
    this.description = const Value.absent(),
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       title = Value(title);
  static Insertable<TodosTableData> custom({
    Expression<UuidValue>? id,
    Expression<UuidValue>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? completed,
    Expression<PgDateTime>? createdAt,
    Expression<PgDateTime>? updatedAt,
    Expression<PgDateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (completed != null) 'completed': completed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosTableCompanion copyWith({
    Value<UuidValue>? id,
    Value<UuidValue>? userId,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? completed,
    Value<PgDateTime>? createdAt,
    Value<PgDateTime>? updatedAt,
    Value<PgDateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TodosTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<UuidValue>(id.value, PgTypes.uuid);
    }
    if (userId.present) {
      map['user_id'] = Variable<UuidValue>(userId.value, PgTypes.uuid);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<PgDateTime>(
        createdAt.value,
        PgTypes.timestampNoTimezone,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<PgDateTime>(
        updatedAt.value,
        PgTypes.timestampNoTimezone,
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<PgDateTime>(
        deletedAt.value,
        PgTypes.timestampNoTimezone,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $TodosTableTable todosTable = $TodosTableTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final TodoDao todoDao = TodoDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [usersTable, todosTable];
}

typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      Value<UuidValue> id,
      required String name,
      Value<String?> firstName,
      Value<String?> lastName,
      required String email,
      required String password,
      required List<String> roles,
      Value<PgDateTime> createdAt,
      Value<PgDateTime> updatedAt,
      Value<PgDateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<UuidValue> id,
      Value<String> name,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String> email,
      Value<String> password,
      Value<List<String>> roles,
      Value<PgDateTime> createdAt,
      Value<PgDateTime> updatedAt,
      Value<PgDateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$UsersTableTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData> {
  $$UsersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TodosTableTable, List<TodosTableData>>
  _todosTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.todosTable,
    aliasName: $_aliasNameGenerator(db.usersTable.id, db.todosTable.userId),
  );

  $$TodosTableTableProcessedTableManager get todosTableRefs {
    final manager = $$TodosTableTableTableManager(
      $_db,
      $_db.todosTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<UuidValue>('id')!));

    final cache = $_typedResult.readTableOrNull(_todosTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<UuidValue> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<PgDateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<PgDateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<PgDateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> todosTableRefs(
    Expression<bool> Function($$TodosTableTableFilterComposer f) f,
  ) {
    final $$TodosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todosTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableTableFilterComposer(
            $db: $db,
            $table: $db.todosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<UuidValue> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<UuidValue> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get roles =>
      $composableBuilder(column: $table.roles, builder: (column) => column);

  GeneratedColumn<PgDateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<PgDateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<PgDateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> todosTableRefs<T extends Object>(
    Expression<T> Function($$TodosTableTableAnnotationComposer a) f,
  ) {
    final $$TodosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todosTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.todosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UsersTableData,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (UsersTableData, $$UsersTableTableReferences),
          UsersTableData,
          PrefetchHooks Function({bool todosTableRefs})
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<UuidValue> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<List<String>> roles = const Value.absent(),
                Value<PgDateTime> createdAt = const Value.absent(),
                Value<PgDateTime> updatedAt = const Value.absent(),
                Value<PgDateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                name: name,
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                roles: roles,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<UuidValue> id = const Value.absent(),
                required String name,
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                required String email,
                required String password,
                required List<String> roles,
                Value<PgDateTime> createdAt = const Value.absent(),
                Value<PgDateTime> updatedAt = const Value.absent(),
                Value<PgDateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                id: id,
                name: name,
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                roles: roles,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UsersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todosTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (todosTableRefs) db.todosTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (todosTableRefs)
                    await $_getPrefetchedData<
                      UsersTableData,
                      $UsersTableTable,
                      TodosTableData
                    >(
                      currentTable: table,
                      referencedTable: $$UsersTableTableReferences
                          ._todosTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableTableReferences(
                            db,
                            table,
                            p0,
                          ).todosTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UsersTableData,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (UsersTableData, $$UsersTableTableReferences),
      UsersTableData,
      PrefetchHooks Function({bool todosTableRefs})
    >;
typedef $$TodosTableTableCreateCompanionBuilder =
    TodosTableCompanion Function({
      Value<UuidValue> id,
      required UuidValue userId,
      required String title,
      Value<String?> description,
      Value<bool> completed,
      Value<PgDateTime> createdAt,
      Value<PgDateTime> updatedAt,
      Value<PgDateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TodosTableTableUpdateCompanionBuilder =
    TodosTableCompanion Function({
      Value<UuidValue> id,
      Value<UuidValue> userId,
      Value<String> title,
      Value<String?> description,
      Value<bool> completed,
      Value<PgDateTime> createdAt,
      Value<PgDateTime> updatedAt,
      Value<PgDateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TodosTableTableReferences
    extends BaseReferences<_$AppDatabase, $TodosTableTable, TodosTableData> {
  $$TodosTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTableTable _userIdTable(_$AppDatabase db) =>
      db.usersTable.createAlias(
        $_aliasNameGenerator(db.todosTable.userId, db.usersTable.id),
      );

  $$UsersTableTableProcessedTableManager get userId {
    final $_column = $_itemColumn<UuidValue>('user_id')!;

    final manager = $$UsersTableTableTableManager(
      $_db,
      $_db.usersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TodosTableTableFilterComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<UuidValue> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<PgDateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<PgDateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<PgDateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableTableFilterComposer get userId {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<UuidValue> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<PgDateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableTableOrderingComposer get userId {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableOrderingComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<UuidValue> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<PgDateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<PgDateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<PgDateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableTableAnnotationComposer get userId {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTableTable,
          TodosTableData,
          $$TodosTableTableFilterComposer,
          $$TodosTableTableOrderingComposer,
          $$TodosTableTableAnnotationComposer,
          $$TodosTableTableCreateCompanionBuilder,
          $$TodosTableTableUpdateCompanionBuilder,
          (TodosTableData, $$TodosTableTableReferences),
          TodosTableData,
          PrefetchHooks Function({bool userId})
        > {
  $$TodosTableTableTableManager(_$AppDatabase db, $TodosTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<UuidValue> id = const Value.absent(),
                Value<UuidValue> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<PgDateTime> createdAt = const Value.absent(),
                Value<PgDateTime> updatedAt = const Value.absent(),
                Value<PgDateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosTableCompanion(
                id: id,
                userId: userId,
                title: title,
                description: description,
                completed: completed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<UuidValue> id = const Value.absent(),
                required UuidValue userId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<PgDateTime> createdAt = const Value.absent(),
                Value<PgDateTime> updatedAt = const Value.absent(),
                Value<PgDateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosTableCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                description: description,
                completed: completed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TodosTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$TodosTableTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$TodosTableTableReferences
                                    ._userIdTable(db)
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

typedef $$TodosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTableTable,
      TodosTableData,
      $$TodosTableTableFilterComposer,
      $$TodosTableTableOrderingComposer,
      $$TodosTableTableAnnotationComposer,
      $$TodosTableTableCreateCompanionBuilder,
      $$TodosTableTableUpdateCompanionBuilder,
      (TodosTableData, $$TodosTableTableReferences),
      TodosTableData,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$TodosTableTableTableManager get todosTable =>
      $$TodosTableTableTableManager(_db, _db.todosTable);
}
