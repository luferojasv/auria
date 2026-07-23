// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SesionesTable extends Sesiones with TableInfo<$SesionesTable, Sesion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  @override
  late final GeneratedColumn<DateTime> fin = GeneratedColumn<DateTime>(
    'fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lugarMeta = const VerificationMeta('lugar');
  @override
  late final GeneratedColumn<String> lugar = GeneratedColumn<String>(
    'lugar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Animo?, int> animoAntes =
      GeneratedColumn<int>(
        'animo_antes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Animo?>($SesionesTable.$converteranimoAntesn);
  static const VerificationMeta _energiaMeta = const VerificationMeta(
    'energia',
  );
  @override
  late final GeneratedColumn<int> energia = GeneratedColumn<int>(
    'energia',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dolorMeta = const VerificationMeta('dolor');
  @override
  late final GeneratedColumn<int> dolor = GeneratedColumn<int>(
    'dolor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    inicio,
    fin,
    notas,
    lugar,
    animoAntes,
    energia,
    dolor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sesion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('lugar')) {
      context.handle(
        _lugarMeta,
        lugar.isAcceptableOrUnknown(data['lugar']!, _lugarMeta),
      );
    }
    if (data.containsKey('energia')) {
      context.handle(
        _energiaMeta,
        energia.isAcceptableOrUnknown(data['energia']!, _energiaMeta),
      );
    }
    if (data.containsKey('dolor')) {
      context.handle(
        _dolorMeta,
        dolor.isAcceptableOrUnknown(data['dolor']!, _dolorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sesion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sesion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fin'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      lugar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lugar'],
      ),
      animoAntes: $SesionesTable.$converteranimoAntesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}animo_antes'],
        ),
      ),
      energia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energia'],
      ),
      dolor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dolor'],
      ),
    );
  }

  @override
  $SesionesTable createAlias(String alias) {
    return $SesionesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Animo, int, int> $converteranimoAntes =
      const EnumIndexConverter<Animo>(Animo.values);
  static JsonTypeConverter2<Animo?, int?, int?> $converteranimoAntesn =
      JsonTypeConverter2.asNullable($converteranimoAntes);
}

class Sesion extends DataClass implements Insertable<Sesion> {
  final int id;
  final String nombre;
  final DateTime inicio;
  final DateTime? fin;
  final String? notas;
  final String? lugar;
  final Animo? animoAntes;

  /// Energía y dolor muscular percibidos antes de empezar, escala 1-10.
  final int? energia;
  final int? dolor;
  const Sesion({
    required this.id,
    required this.nombre,
    required this.inicio,
    this.fin,
    this.notas,
    this.lugar,
    this.animoAntes,
    this.energia,
    this.dolor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['inicio'] = Variable<DateTime>(inicio);
    if (!nullToAbsent || fin != null) {
      map['fin'] = Variable<DateTime>(fin);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    if (!nullToAbsent || lugar != null) {
      map['lugar'] = Variable<String>(lugar);
    }
    if (!nullToAbsent || animoAntes != null) {
      map['animo_antes'] = Variable<int>(
        $SesionesTable.$converteranimoAntesn.toSql(animoAntes),
      );
    }
    if (!nullToAbsent || energia != null) {
      map['energia'] = Variable<int>(energia);
    }
    if (!nullToAbsent || dolor != null) {
      map['dolor'] = Variable<int>(dolor);
    }
    return map;
  }

  SesionesCompanion toCompanion(bool nullToAbsent) {
    return SesionesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      inicio: Value(inicio),
      fin: fin == null && nullToAbsent ? const Value.absent() : Value(fin),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      lugar: lugar == null && nullToAbsent
          ? const Value.absent()
          : Value(lugar),
      animoAntes: animoAntes == null && nullToAbsent
          ? const Value.absent()
          : Value(animoAntes),
      energia: energia == null && nullToAbsent
          ? const Value.absent()
          : Value(energia),
      dolor: dolor == null && nullToAbsent
          ? const Value.absent()
          : Value(dolor),
    );
  }

  factory Sesion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sesion(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fin: serializer.fromJson<DateTime?>(json['fin']),
      notas: serializer.fromJson<String?>(json['notas']),
      lugar: serializer.fromJson<String?>(json['lugar']),
      animoAntes: $SesionesTable.$converteranimoAntesn.fromJson(
        serializer.fromJson<int?>(json['animoAntes']),
      ),
      energia: serializer.fromJson<int?>(json['energia']),
      dolor: serializer.fromJson<int?>(json['dolor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fin': serializer.toJson<DateTime?>(fin),
      'notas': serializer.toJson<String?>(notas),
      'lugar': serializer.toJson<String?>(lugar),
      'animoAntes': serializer.toJson<int?>(
        $SesionesTable.$converteranimoAntesn.toJson(animoAntes),
      ),
      'energia': serializer.toJson<int?>(energia),
      'dolor': serializer.toJson<int?>(dolor),
    };
  }

  Sesion copyWith({
    int? id,
    String? nombre,
    DateTime? inicio,
    Value<DateTime?> fin = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    Value<String?> lugar = const Value.absent(),
    Value<Animo?> animoAntes = const Value.absent(),
    Value<int?> energia = const Value.absent(),
    Value<int?> dolor = const Value.absent(),
  }) => Sesion(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    inicio: inicio ?? this.inicio,
    fin: fin.present ? fin.value : this.fin,
    notas: notas.present ? notas.value : this.notas,
    lugar: lugar.present ? lugar.value : this.lugar,
    animoAntes: animoAntes.present ? animoAntes.value : this.animoAntes,
    energia: energia.present ? energia.value : this.energia,
    dolor: dolor.present ? dolor.value : this.dolor,
  );
  Sesion copyWithCompanion(SesionesCompanion data) {
    return Sesion(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fin: data.fin.present ? data.fin.value : this.fin,
      notas: data.notas.present ? data.notas.value : this.notas,
      lugar: data.lugar.present ? data.lugar.value : this.lugar,
      animoAntes: data.animoAntes.present
          ? data.animoAntes.value
          : this.animoAntes,
      energia: data.energia.present ? data.energia.value : this.energia,
      dolor: data.dolor.present ? data.dolor.value : this.dolor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sesion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('notas: $notas, ')
          ..write('lugar: $lugar, ')
          ..write('animoAntes: $animoAntes, ')
          ..write('energia: $energia, ')
          ..write('dolor: $dolor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    inicio,
    fin,
    notas,
    lugar,
    animoAntes,
    energia,
    dolor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sesion &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.inicio == this.inicio &&
          other.fin == this.fin &&
          other.notas == this.notas &&
          other.lugar == this.lugar &&
          other.animoAntes == this.animoAntes &&
          other.energia == this.energia &&
          other.dolor == this.dolor);
}

class SesionesCompanion extends UpdateCompanion<Sesion> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<DateTime> inicio;
  final Value<DateTime?> fin;
  final Value<String?> notas;
  final Value<String?> lugar;
  final Value<Animo?> animoAntes;
  final Value<int?> energia;
  final Value<int?> dolor;
  const SesionesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fin = const Value.absent(),
    this.notas = const Value.absent(),
    this.lugar = const Value.absent(),
    this.animoAntes = const Value.absent(),
    this.energia = const Value.absent(),
    this.dolor = const Value.absent(),
  });
  SesionesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required DateTime inicio,
    this.fin = const Value.absent(),
    this.notas = const Value.absent(),
    this.lugar = const Value.absent(),
    this.animoAntes = const Value.absent(),
    this.energia = const Value.absent(),
    this.dolor = const Value.absent(),
  }) : nombre = Value(nombre),
       inicio = Value(inicio);
  static Insertable<Sesion> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fin,
    Expression<String>? notas,
    Expression<String>? lugar,
    Expression<int>? animoAntes,
    Expression<int>? energia,
    Expression<int>? dolor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
      if (notas != null) 'notas': notas,
      if (lugar != null) 'lugar': lugar,
      if (animoAntes != null) 'animo_antes': animoAntes,
      if (energia != null) 'energia': energia,
      if (dolor != null) 'dolor': dolor,
    });
  }

  SesionesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<DateTime>? inicio,
    Value<DateTime?>? fin,
    Value<String?>? notas,
    Value<String?>? lugar,
    Value<Animo?>? animoAntes,
    Value<int?>? energia,
    Value<int?>? dolor,
  }) {
    return SesionesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      notas: notas ?? this.notas,
      lugar: lugar ?? this.lugar,
      animoAntes: animoAntes ?? this.animoAntes,
      energia: energia ?? this.energia,
      dolor: dolor ?? this.dolor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fin.present) {
      map['fin'] = Variable<DateTime>(fin.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (lugar.present) {
      map['lugar'] = Variable<String>(lugar.value);
    }
    if (animoAntes.present) {
      map['animo_antes'] = Variable<int>(
        $SesionesTable.$converteranimoAntesn.toSql(animoAntes.value),
      );
    }
    if (energia.present) {
      map['energia'] = Variable<int>(energia.value);
    }
    if (dolor.present) {
      map['dolor'] = Variable<int>(dolor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('notas: $notas, ')
          ..write('lugar: $lugar, ')
          ..write('animoAntes: $animoAntes, ')
          ..write('energia: $energia, ')
          ..write('dolor: $dolor')
          ..write(')'))
        .toString();
  }
}

class $SeriesTable extends Series with TableInfo<$SeriesTable, Serie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sesionIdMeta = const VerificationMeta(
    'sesionId',
  );
  @override
  late final GeneratedColumn<int> sesionId = GeneratedColumn<int>(
    'sesion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sesiones (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ejercicioIdMeta = const VerificationMeta(
    'ejercicioId',
  );
  @override
  late final GeneratedColumn<String> ejercicioId = GeneratedColumn<String>(
    'ejercicio_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeticionesMeta = const VerificationMeta(
    'repeticiones',
  );
  @override
  late final GeneratedColumn<int> repeticiones = GeneratedColumn<int>(
    'repeticiones',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoKgMeta = const VerificationMeta('pesoKg');
  @override
  late final GeneratedColumn<double> pesoKg = GeneratedColumn<double>(
    'peso_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hechaMeta = const VerificationMeta('hecha');
  @override
  late final GeneratedColumn<bool> hecha = GeneratedColumn<bool>(
    'hecha',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hecha" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoSerie, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<TipoSerie>($SeriesTable.$convertertipo);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descansoSegMeta = const VerificationMeta(
    'descansoSeg',
  );
  @override
  late final GeneratedColumn<int> descansoSeg = GeneratedColumn<int>(
    'descanso_seg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sesionId,
    ejercicioId,
    orden,
    repeticiones,
    pesoKg,
    hecha,
    tipo,
    rpe,
    descansoSeg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<Serie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sesion_id')) {
      context.handle(
        _sesionIdMeta,
        sesionId.isAcceptableOrUnknown(data['sesion_id']!, _sesionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sesionIdMeta);
    }
    if (data.containsKey('ejercicio_id')) {
      context.handle(
        _ejercicioIdMeta,
        ejercicioId.isAcceptableOrUnknown(
          data['ejercicio_id']!,
          _ejercicioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ejercicioIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('repeticiones')) {
      context.handle(
        _repeticionesMeta,
        repeticiones.isAcceptableOrUnknown(
          data['repeticiones']!,
          _repeticionesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repeticionesMeta);
    }
    if (data.containsKey('peso_kg')) {
      context.handle(
        _pesoKgMeta,
        pesoKg.isAcceptableOrUnknown(data['peso_kg']!, _pesoKgMeta),
      );
    }
    if (data.containsKey('hecha')) {
      context.handle(
        _hechaMeta,
        hecha.isAcceptableOrUnknown(data['hecha']!, _hechaMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('descanso_seg')) {
      context.handle(
        _descansoSegMeta,
        descansoSeg.isAcceptableOrUnknown(
          data['descanso_seg']!,
          _descansoSegMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Serie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Serie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sesion_id'],
      )!,
      ejercicioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ejercicio_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      repeticiones: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeticiones'],
      )!,
      pesoKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_kg'],
      )!,
      hecha: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hecha'],
      )!,
      tipo: $SeriesTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      descansoSeg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}descanso_seg'],
      ),
    );
  }

  @override
  $SeriesTable createAlias(String alias) {
    return $SeriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoSerie, int, int> $convertertipo =
      const EnumIndexConverter<TipoSerie>(TipoSerie.values);
}

class Serie extends DataClass implements Insertable<Serie> {
  final int id;
  final int sesionId;
  final String ejercicioId;

  /// Orden dentro de la sesion; permite reordenar sin tocar los ids.
  final int orden;
  final int repeticiones;
  final double pesoKg;
  final bool hecha;
  final TipoSerie tipo;

  /// Esfuerzo percibido 1-10, opcional.
  final int? rpe;

  /// Descanso real tras la serie, en segundos (lo aporta el cronómetro). v2.
  final int? descansoSeg;
  const Serie({
    required this.id,
    required this.sesionId,
    required this.ejercicioId,
    required this.orden,
    required this.repeticiones,
    required this.pesoKg,
    required this.hecha,
    required this.tipo,
    this.rpe,
    this.descansoSeg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sesion_id'] = Variable<int>(sesionId);
    map['ejercicio_id'] = Variable<String>(ejercicioId);
    map['orden'] = Variable<int>(orden);
    map['repeticiones'] = Variable<int>(repeticiones);
    map['peso_kg'] = Variable<double>(pesoKg);
    map['hecha'] = Variable<bool>(hecha);
    {
      map['tipo'] = Variable<int>($SeriesTable.$convertertipo.toSql(tipo));
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || descansoSeg != null) {
      map['descanso_seg'] = Variable<int>(descansoSeg);
    }
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(
      id: Value(id),
      sesionId: Value(sesionId),
      ejercicioId: Value(ejercicioId),
      orden: Value(orden),
      repeticiones: Value(repeticiones),
      pesoKg: Value(pesoKg),
      hecha: Value(hecha),
      tipo: Value(tipo),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      descansoSeg: descansoSeg == null && nullToAbsent
          ? const Value.absent()
          : Value(descansoSeg),
    );
  }

  factory Serie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Serie(
      id: serializer.fromJson<int>(json['id']),
      sesionId: serializer.fromJson<int>(json['sesionId']),
      ejercicioId: serializer.fromJson<String>(json['ejercicioId']),
      orden: serializer.fromJson<int>(json['orden']),
      repeticiones: serializer.fromJson<int>(json['repeticiones']),
      pesoKg: serializer.fromJson<double>(json['pesoKg']),
      hecha: serializer.fromJson<bool>(json['hecha']),
      tipo: $SeriesTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      rpe: serializer.fromJson<int?>(json['rpe']),
      descansoSeg: serializer.fromJson<int?>(json['descansoSeg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sesionId': serializer.toJson<int>(sesionId),
      'ejercicioId': serializer.toJson<String>(ejercicioId),
      'orden': serializer.toJson<int>(orden),
      'repeticiones': serializer.toJson<int>(repeticiones),
      'pesoKg': serializer.toJson<double>(pesoKg),
      'hecha': serializer.toJson<bool>(hecha),
      'tipo': serializer.toJson<int>($SeriesTable.$convertertipo.toJson(tipo)),
      'rpe': serializer.toJson<int?>(rpe),
      'descansoSeg': serializer.toJson<int?>(descansoSeg),
    };
  }

  Serie copyWith({
    int? id,
    int? sesionId,
    String? ejercicioId,
    int? orden,
    int? repeticiones,
    double? pesoKg,
    bool? hecha,
    TipoSerie? tipo,
    Value<int?> rpe = const Value.absent(),
    Value<int?> descansoSeg = const Value.absent(),
  }) => Serie(
    id: id ?? this.id,
    sesionId: sesionId ?? this.sesionId,
    ejercicioId: ejercicioId ?? this.ejercicioId,
    orden: orden ?? this.orden,
    repeticiones: repeticiones ?? this.repeticiones,
    pesoKg: pesoKg ?? this.pesoKg,
    hecha: hecha ?? this.hecha,
    tipo: tipo ?? this.tipo,
    rpe: rpe.present ? rpe.value : this.rpe,
    descansoSeg: descansoSeg.present ? descansoSeg.value : this.descansoSeg,
  );
  Serie copyWithCompanion(SeriesCompanion data) {
    return Serie(
      id: data.id.present ? data.id.value : this.id,
      sesionId: data.sesionId.present ? data.sesionId.value : this.sesionId,
      ejercicioId: data.ejercicioId.present
          ? data.ejercicioId.value
          : this.ejercicioId,
      orden: data.orden.present ? data.orden.value : this.orden,
      repeticiones: data.repeticiones.present
          ? data.repeticiones.value
          : this.repeticiones,
      pesoKg: data.pesoKg.present ? data.pesoKg.value : this.pesoKg,
      hecha: data.hecha.present ? data.hecha.value : this.hecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      descansoSeg: data.descansoSeg.present
          ? data.descansoSeg.value
          : this.descansoSeg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Serie(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('repeticiones: $repeticiones, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('hecha: $hecha, ')
          ..write('tipo: $tipo, ')
          ..write('rpe: $rpe, ')
          ..write('descansoSeg: $descansoSeg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sesionId,
    ejercicioId,
    orden,
    repeticiones,
    pesoKg,
    hecha,
    tipo,
    rpe,
    descansoSeg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Serie &&
          other.id == this.id &&
          other.sesionId == this.sesionId &&
          other.ejercicioId == this.ejercicioId &&
          other.orden == this.orden &&
          other.repeticiones == this.repeticiones &&
          other.pesoKg == this.pesoKg &&
          other.hecha == this.hecha &&
          other.tipo == this.tipo &&
          other.rpe == this.rpe &&
          other.descansoSeg == this.descansoSeg);
}

class SeriesCompanion extends UpdateCompanion<Serie> {
  final Value<int> id;
  final Value<int> sesionId;
  final Value<String> ejercicioId;
  final Value<int> orden;
  final Value<int> repeticiones;
  final Value<double> pesoKg;
  final Value<bool> hecha;
  final Value<TipoSerie> tipo;
  final Value<int?> rpe;
  final Value<int?> descansoSeg;
  const SeriesCompanion({
    this.id = const Value.absent(),
    this.sesionId = const Value.absent(),
    this.ejercicioId = const Value.absent(),
    this.orden = const Value.absent(),
    this.repeticiones = const Value.absent(),
    this.pesoKg = const Value.absent(),
    this.hecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.rpe = const Value.absent(),
    this.descansoSeg = const Value.absent(),
  });
  SeriesCompanion.insert({
    this.id = const Value.absent(),
    required int sesionId,
    required String ejercicioId,
    required int orden,
    required int repeticiones,
    this.pesoKg = const Value.absent(),
    this.hecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.rpe = const Value.absent(),
    this.descansoSeg = const Value.absent(),
  }) : sesionId = Value(sesionId),
       ejercicioId = Value(ejercicioId),
       orden = Value(orden),
       repeticiones = Value(repeticiones);
  static Insertable<Serie> custom({
    Expression<int>? id,
    Expression<int>? sesionId,
    Expression<String>? ejercicioId,
    Expression<int>? orden,
    Expression<int>? repeticiones,
    Expression<double>? pesoKg,
    Expression<bool>? hecha,
    Expression<int>? tipo,
    Expression<int>? rpe,
    Expression<int>? descansoSeg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sesionId != null) 'sesion_id': sesionId,
      if (ejercicioId != null) 'ejercicio_id': ejercicioId,
      if (orden != null) 'orden': orden,
      if (repeticiones != null) 'repeticiones': repeticiones,
      if (pesoKg != null) 'peso_kg': pesoKg,
      if (hecha != null) 'hecha': hecha,
      if (tipo != null) 'tipo': tipo,
      if (rpe != null) 'rpe': rpe,
      if (descansoSeg != null) 'descanso_seg': descansoSeg,
    });
  }

  SeriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sesionId,
    Value<String>? ejercicioId,
    Value<int>? orden,
    Value<int>? repeticiones,
    Value<double>? pesoKg,
    Value<bool>? hecha,
    Value<TipoSerie>? tipo,
    Value<int?>? rpe,
    Value<int?>? descansoSeg,
  }) {
    return SeriesCompanion(
      id: id ?? this.id,
      sesionId: sesionId ?? this.sesionId,
      ejercicioId: ejercicioId ?? this.ejercicioId,
      orden: orden ?? this.orden,
      repeticiones: repeticiones ?? this.repeticiones,
      pesoKg: pesoKg ?? this.pesoKg,
      hecha: hecha ?? this.hecha,
      tipo: tipo ?? this.tipo,
      rpe: rpe ?? this.rpe,
      descansoSeg: descansoSeg ?? this.descansoSeg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sesionId.present) {
      map['sesion_id'] = Variable<int>(sesionId.value);
    }
    if (ejercicioId.present) {
      map['ejercicio_id'] = Variable<String>(ejercicioId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (repeticiones.present) {
      map['repeticiones'] = Variable<int>(repeticiones.value);
    }
    if (pesoKg.present) {
      map['peso_kg'] = Variable<double>(pesoKg.value);
    }
    if (hecha.present) {
      map['hecha'] = Variable<bool>(hecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $SeriesTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (descansoSeg.present) {
      map['descanso_seg'] = Variable<int>(descansoSeg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('id: $id, ')
          ..write('sesionId: $sesionId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('repeticiones: $repeticiones, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('hecha: $hecha, ')
          ..write('tipo: $tipo, ')
          ..write('rpe: $rpe, ')
          ..write('descansoSeg: $descansoSeg')
          ..write(')'))
        .toString();
  }
}

class $RutinasTable extends Rutinas with TableInfo<$RutinasTable, Rutina> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadaMeta = const VerificationMeta('creada');
  @override
  late final GeneratedColumn<DateTime> creada = GeneratedColumn<DateTime>(
    'creada',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, notas, creada];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutinas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rutina> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creada')) {
      context.handle(
        _creadaMeta,
        creada.isAcceptableOrUnknown(data['creada']!, _creadaMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rutina map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rutina(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creada'],
      )!,
    );
  }

  @override
  $RutinasTable createAlias(String alias) {
    return $RutinasTable(attachedDatabase, alias);
  }
}

class Rutina extends DataClass implements Insertable<Rutina> {
  final int id;
  final String nombre;
  final String? notas;
  final DateTime creada;
  const Rutina({
    required this.id,
    required this.nombre,
    this.notas,
    required this.creada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creada'] = Variable<DateTime>(creada);
    return map;
  }

  RutinasCompanion toCompanion(bool nullToAbsent) {
    return RutinasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creada: Value(creada),
    );
  }

  factory Rutina.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rutina(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      notas: serializer.fromJson<String?>(json['notas']),
      creada: serializer.fromJson<DateTime>(json['creada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'notas': serializer.toJson<String?>(notas),
      'creada': serializer.toJson<DateTime>(creada),
    };
  }

  Rutina copyWith({
    int? id,
    String? nombre,
    Value<String?> notas = const Value.absent(),
    DateTime? creada,
  }) => Rutina(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    notas: notas.present ? notas.value : this.notas,
    creada: creada ?? this.creada,
  );
  Rutina copyWithCompanion(RutinasCompanion data) {
    return Rutina(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      notas: data.notas.present ? data.notas.value : this.notas,
      creada: data.creada.present ? data.creada.value : this.creada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rutina(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('notas: $notas, ')
          ..write('creada: $creada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, notas, creada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rutina &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.notas == this.notas &&
          other.creada == this.creada);
}

class RutinasCompanion extends UpdateCompanion<Rutina> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> notas;
  final Value<DateTime> creada;
  const RutinasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.notas = const Value.absent(),
    this.creada = const Value.absent(),
  });
  RutinasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.notas = const Value.absent(),
    required DateTime creada,
  }) : nombre = Value(nombre),
       creada = Value(creada);
  static Insertable<Rutina> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? notas,
    Expression<DateTime>? creada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (notas != null) 'notas': notas,
      if (creada != null) 'creada': creada,
    });
  }

  RutinasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? notas,
    Value<DateTime>? creada,
  }) {
    return RutinasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      notas: notas ?? this.notas,
      creada: creada ?? this.creada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creada.present) {
      map['creada'] = Variable<DateTime>(creada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('notas: $notas, ')
          ..write('creada: $creada')
          ..write(')'))
        .toString();
  }
}

class $RutinaEjerciciosTable extends RutinaEjercicios
    with TableInfo<$RutinaEjerciciosTable, RutinaEjercicio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RutinaEjerciciosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rutinaIdMeta = const VerificationMeta(
    'rutinaId',
  );
  @override
  late final GeneratedColumn<int> rutinaId = GeneratedColumn<int>(
    'rutina_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rutinas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ejercicioIdMeta = const VerificationMeta(
    'ejercicioId',
  );
  @override
  late final GeneratedColumn<String> ejercicioId = GeneratedColumn<String>(
    'ejercicio_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesObjetivoMeta = const VerificationMeta(
    'seriesObjetivo',
  );
  @override
  late final GeneratedColumn<int> seriesObjetivo = GeneratedColumn<int>(
    'series_objetivo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _repsObjetivoMeta = const VerificationMeta(
    'repsObjetivo',
  );
  @override
  late final GeneratedColumn<int> repsObjetivo = GeneratedColumn<int>(
    'reps_objetivo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rutinaId,
    ejercicioId,
    orden,
    seriesObjetivo,
    repsObjetivo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rutina_ejercicios';
  @override
  VerificationContext validateIntegrity(
    Insertable<RutinaEjercicio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rutina_id')) {
      context.handle(
        _rutinaIdMeta,
        rutinaId.isAcceptableOrUnknown(data['rutina_id']!, _rutinaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rutinaIdMeta);
    }
    if (data.containsKey('ejercicio_id')) {
      context.handle(
        _ejercicioIdMeta,
        ejercicioId.isAcceptableOrUnknown(
          data['ejercicio_id']!,
          _ejercicioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ejercicioIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('series_objetivo')) {
      context.handle(
        _seriesObjetivoMeta,
        seriesObjetivo.isAcceptableOrUnknown(
          data['series_objetivo']!,
          _seriesObjetivoMeta,
        ),
      );
    }
    if (data.containsKey('reps_objetivo')) {
      context.handle(
        _repsObjetivoMeta,
        repsObjetivo.isAcceptableOrUnknown(
          data['reps_objetivo']!,
          _repsObjetivoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RutinaEjercicio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RutinaEjercicio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rutinaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rutina_id'],
      )!,
      ejercicioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ejercicio_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      seriesObjetivo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_objetivo'],
      )!,
      repsObjetivo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_objetivo'],
      )!,
    );
  }

  @override
  $RutinaEjerciciosTable createAlias(String alias) {
    return $RutinaEjerciciosTable(attachedDatabase, alias);
  }
}

class RutinaEjercicio extends DataClass implements Insertable<RutinaEjercicio> {
  final int id;
  final int rutinaId;
  final String ejercicioId;
  final int orden;
  final int seriesObjetivo;
  final int repsObjetivo;
  const RutinaEjercicio({
    required this.id,
    required this.rutinaId,
    required this.ejercicioId,
    required this.orden,
    required this.seriesObjetivo,
    required this.repsObjetivo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rutina_id'] = Variable<int>(rutinaId);
    map['ejercicio_id'] = Variable<String>(ejercicioId);
    map['orden'] = Variable<int>(orden);
    map['series_objetivo'] = Variable<int>(seriesObjetivo);
    map['reps_objetivo'] = Variable<int>(repsObjetivo);
    return map;
  }

  RutinaEjerciciosCompanion toCompanion(bool nullToAbsent) {
    return RutinaEjerciciosCompanion(
      id: Value(id),
      rutinaId: Value(rutinaId),
      ejercicioId: Value(ejercicioId),
      orden: Value(orden),
      seriesObjetivo: Value(seriesObjetivo),
      repsObjetivo: Value(repsObjetivo),
    );
  }

  factory RutinaEjercicio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RutinaEjercicio(
      id: serializer.fromJson<int>(json['id']),
      rutinaId: serializer.fromJson<int>(json['rutinaId']),
      ejercicioId: serializer.fromJson<String>(json['ejercicioId']),
      orden: serializer.fromJson<int>(json['orden']),
      seriesObjetivo: serializer.fromJson<int>(json['seriesObjetivo']),
      repsObjetivo: serializer.fromJson<int>(json['repsObjetivo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutinaId': serializer.toJson<int>(rutinaId),
      'ejercicioId': serializer.toJson<String>(ejercicioId),
      'orden': serializer.toJson<int>(orden),
      'seriesObjetivo': serializer.toJson<int>(seriesObjetivo),
      'repsObjetivo': serializer.toJson<int>(repsObjetivo),
    };
  }

  RutinaEjercicio copyWith({
    int? id,
    int? rutinaId,
    String? ejercicioId,
    int? orden,
    int? seriesObjetivo,
    int? repsObjetivo,
  }) => RutinaEjercicio(
    id: id ?? this.id,
    rutinaId: rutinaId ?? this.rutinaId,
    ejercicioId: ejercicioId ?? this.ejercicioId,
    orden: orden ?? this.orden,
    seriesObjetivo: seriesObjetivo ?? this.seriesObjetivo,
    repsObjetivo: repsObjetivo ?? this.repsObjetivo,
  );
  RutinaEjercicio copyWithCompanion(RutinaEjerciciosCompanion data) {
    return RutinaEjercicio(
      id: data.id.present ? data.id.value : this.id,
      rutinaId: data.rutinaId.present ? data.rutinaId.value : this.rutinaId,
      ejercicioId: data.ejercicioId.present
          ? data.ejercicioId.value
          : this.ejercicioId,
      orden: data.orden.present ? data.orden.value : this.orden,
      seriesObjetivo: data.seriesObjetivo.present
          ? data.seriesObjetivo.value
          : this.seriesObjetivo,
      repsObjetivo: data.repsObjetivo.present
          ? data.repsObjetivo.value
          : this.repsObjetivo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RutinaEjercicio(')
          ..write('id: $id, ')
          ..write('rutinaId: $rutinaId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('seriesObjetivo: $seriesObjetivo, ')
          ..write('repsObjetivo: $repsObjetivo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rutinaId,
    ejercicioId,
    orden,
    seriesObjetivo,
    repsObjetivo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RutinaEjercicio &&
          other.id == this.id &&
          other.rutinaId == this.rutinaId &&
          other.ejercicioId == this.ejercicioId &&
          other.orden == this.orden &&
          other.seriesObjetivo == this.seriesObjetivo &&
          other.repsObjetivo == this.repsObjetivo);
}

class RutinaEjerciciosCompanion extends UpdateCompanion<RutinaEjercicio> {
  final Value<int> id;
  final Value<int> rutinaId;
  final Value<String> ejercicioId;
  final Value<int> orden;
  final Value<int> seriesObjetivo;
  final Value<int> repsObjetivo;
  const RutinaEjerciciosCompanion({
    this.id = const Value.absent(),
    this.rutinaId = const Value.absent(),
    this.ejercicioId = const Value.absent(),
    this.orden = const Value.absent(),
    this.seriesObjetivo = const Value.absent(),
    this.repsObjetivo = const Value.absent(),
  });
  RutinaEjerciciosCompanion.insert({
    this.id = const Value.absent(),
    required int rutinaId,
    required String ejercicioId,
    required int orden,
    this.seriesObjetivo = const Value.absent(),
    this.repsObjetivo = const Value.absent(),
  }) : rutinaId = Value(rutinaId),
       ejercicioId = Value(ejercicioId),
       orden = Value(orden);
  static Insertable<RutinaEjercicio> custom({
    Expression<int>? id,
    Expression<int>? rutinaId,
    Expression<String>? ejercicioId,
    Expression<int>? orden,
    Expression<int>? seriesObjetivo,
    Expression<int>? repsObjetivo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutinaId != null) 'rutina_id': rutinaId,
      if (ejercicioId != null) 'ejercicio_id': ejercicioId,
      if (orden != null) 'orden': orden,
      if (seriesObjetivo != null) 'series_objetivo': seriesObjetivo,
      if (repsObjetivo != null) 'reps_objetivo': repsObjetivo,
    });
  }

  RutinaEjerciciosCompanion copyWith({
    Value<int>? id,
    Value<int>? rutinaId,
    Value<String>? ejercicioId,
    Value<int>? orden,
    Value<int>? seriesObjetivo,
    Value<int>? repsObjetivo,
  }) {
    return RutinaEjerciciosCompanion(
      id: id ?? this.id,
      rutinaId: rutinaId ?? this.rutinaId,
      ejercicioId: ejercicioId ?? this.ejercicioId,
      orden: orden ?? this.orden,
      seriesObjetivo: seriesObjetivo ?? this.seriesObjetivo,
      repsObjetivo: repsObjetivo ?? this.repsObjetivo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutinaId.present) {
      map['rutina_id'] = Variable<int>(rutinaId.value);
    }
    if (ejercicioId.present) {
      map['ejercicio_id'] = Variable<String>(ejercicioId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (seriesObjetivo.present) {
      map['series_objetivo'] = Variable<int>(seriesObjetivo.value);
    }
    if (repsObjetivo.present) {
      map['reps_objetivo'] = Variable<int>(repsObjetivo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RutinaEjerciciosCompanion(')
          ..write('id: $id, ')
          ..write('rutinaId: $rutinaId, ')
          ..write('ejercicioId: $ejercicioId, ')
          ..write('orden: $orden, ')
          ..write('seriesObjetivo: $seriesObjetivo, ')
          ..write('repsObjetivo: $repsObjetivo')
          ..write(')'))
        .toString();
  }
}

class $PlanSemanalTable extends PlanSemanal
    with TableInfo<$PlanSemanalTable, DiaPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanSemanalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<int> dia = GeneratedColumn<int>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruposMeta = const VerificationMeta('grupos');
  @override
  late final GeneratedColumn<String> grupos = GeneratedColumn<String>(
    'grupos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descansoMeta = const VerificationMeta(
    'descanso',
  );
  @override
  late final GeneratedColumn<bool> descanso = GeneratedColumn<bool>(
    'descanso',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("descanso" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [dia, titulo, grupos, descanso];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_semanal';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('grupos')) {
      context.handle(
        _gruposMeta,
        grupos.isAcceptableOrUnknown(data['grupos']!, _gruposMeta),
      );
    }
    if (data.containsKey('descanso')) {
      context.handle(
        _descansoMeta,
        descanso.isAcceptableOrUnknown(data['descanso']!, _descansoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dia};
  @override
  DiaPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaPlan(
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      grupos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grupos'],
      )!,
      descanso: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}descanso'],
      )!,
    );
  }

  @override
  $PlanSemanalTable createAlias(String alias) {
    return $PlanSemanalTable(attachedDatabase, alias);
  }
}

class DiaPlan extends DataClass implements Insertable<DiaPlan> {
  /// 1 = lunes … 7 = domingo (ISO, igual que DateTime.weekday).
  final int dia;
  final String titulo;

  /// Grupos musculares separados por coma ("Glúteos, Piernas"). Texto plano y
  /// no una tabla aparte: es una etiqueta editable, no una entidad con vida
  /// propia.
  final String grupos;
  final bool descanso;
  const DiaPlan({
    required this.dia,
    required this.titulo,
    required this.grupos,
    required this.descanso,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dia'] = Variable<int>(dia);
    map['titulo'] = Variable<String>(titulo);
    map['grupos'] = Variable<String>(grupos);
    map['descanso'] = Variable<bool>(descanso);
    return map;
  }

  PlanSemanalCompanion toCompanion(bool nullToAbsent) {
    return PlanSemanalCompanion(
      dia: Value(dia),
      titulo: Value(titulo),
      grupos: Value(grupos),
      descanso: Value(descanso),
    );
  }

  factory DiaPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaPlan(
      dia: serializer.fromJson<int>(json['dia']),
      titulo: serializer.fromJson<String>(json['titulo']),
      grupos: serializer.fromJson<String>(json['grupos']),
      descanso: serializer.fromJson<bool>(json['descanso']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dia': serializer.toJson<int>(dia),
      'titulo': serializer.toJson<String>(titulo),
      'grupos': serializer.toJson<String>(grupos),
      'descanso': serializer.toJson<bool>(descanso),
    };
  }

  DiaPlan copyWith({
    int? dia,
    String? titulo,
    String? grupos,
    bool? descanso,
  }) => DiaPlan(
    dia: dia ?? this.dia,
    titulo: titulo ?? this.titulo,
    grupos: grupos ?? this.grupos,
    descanso: descanso ?? this.descanso,
  );
  DiaPlan copyWithCompanion(PlanSemanalCompanion data) {
    return DiaPlan(
      dia: data.dia.present ? data.dia.value : this.dia,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      grupos: data.grupos.present ? data.grupos.value : this.grupos,
      descanso: data.descanso.present ? data.descanso.value : this.descanso,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaPlan(')
          ..write('dia: $dia, ')
          ..write('titulo: $titulo, ')
          ..write('grupos: $grupos, ')
          ..write('descanso: $descanso')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dia, titulo, grupos, descanso);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaPlan &&
          other.dia == this.dia &&
          other.titulo == this.titulo &&
          other.grupos == this.grupos &&
          other.descanso == this.descanso);
}

class PlanSemanalCompanion extends UpdateCompanion<DiaPlan> {
  final Value<int> dia;
  final Value<String> titulo;
  final Value<String> grupos;
  final Value<bool> descanso;
  const PlanSemanalCompanion({
    this.dia = const Value.absent(),
    this.titulo = const Value.absent(),
    this.grupos = const Value.absent(),
    this.descanso = const Value.absent(),
  });
  PlanSemanalCompanion.insert({
    this.dia = const Value.absent(),
    required String titulo,
    this.grupos = const Value.absent(),
    this.descanso = const Value.absent(),
  }) : titulo = Value(titulo);
  static Insertable<DiaPlan> custom({
    Expression<int>? dia,
    Expression<String>? titulo,
    Expression<String>? grupos,
    Expression<bool>? descanso,
  }) {
    return RawValuesInsertable({
      if (dia != null) 'dia': dia,
      if (titulo != null) 'titulo': titulo,
      if (grupos != null) 'grupos': grupos,
      if (descanso != null) 'descanso': descanso,
    });
  }

  PlanSemanalCompanion copyWith({
    Value<int>? dia,
    Value<String>? titulo,
    Value<String>? grupos,
    Value<bool>? descanso,
  }) {
    return PlanSemanalCompanion(
      dia: dia ?? this.dia,
      titulo: titulo ?? this.titulo,
      grupos: grupos ?? this.grupos,
      descanso: descanso ?? this.descanso,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dia.present) {
      map['dia'] = Variable<int>(dia.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (grupos.present) {
      map['grupos'] = Variable<String>(grupos.value);
    }
    if (descanso.present) {
      map['descanso'] = Variable<bool>(descanso.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanSemanalCompanion(')
          ..write('dia: $dia, ')
          ..write('titulo: $titulo, ')
          ..write('grupos: $grupos, ')
          ..write('descanso: $descanso')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _momentoMeta = const VerificationMeta(
    'momento',
  );
  @override
  late final GeneratedColumn<DateTime> momento = GeneratedColumn<DateTime>(
    'momento',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoEvento, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoEvento>($EventosTable.$convertertipo);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detalleMeta = const VerificationMeta(
    'detalle',
  );
  @override
  late final GeneratedColumn<String> detalle = GeneratedColumn<String>(
    'detalle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbosMeta = const VerificationMeta('carbos');
  @override
  late final GeneratedColumn<double> carbos = GeneratedColumn<double>(
    'carbos',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinaMeta = const VerificationMeta(
    'proteina',
  );
  @override
  late final GeneratedColumn<double> proteina = GeneratedColumn<double>(
    'proteina',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grasaMeta = const VerificationMeta('grasa');
  @override
  late final GeneratedColumn<double> grasa = GeneratedColumn<double>(
    'grasa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fibraMeta = const VerificationMeta('fibra');
  @override
  late final GeneratedColumn<double> fibra = GeneratedColumn<double>(
    'fibra',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriasMeta = const VerificationMeta(
    'calorias',
  );
  @override
  late final GeneratedColumn<double> calorias = GeneratedColumn<double>(
    'calorias',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<int> nivel = GeneratedColumn<int>(
    'nivel',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosisMeta = const VerificationMeta('dosis');
  @override
  late final GeneratedColumn<String> dosis = GeneratedColumn<String>(
    'dosis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    momento,
    tipo,
    titulo,
    detalle,
    carbos,
    proteina,
    grasa,
    fibra,
    calorias,
    nivel,
    dosis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('momento')) {
      context.handle(
        _momentoMeta,
        momento.isAcceptableOrUnknown(data['momento']!, _momentoMeta),
      );
    } else if (isInserting) {
      context.missing(_momentoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('detalle')) {
      context.handle(
        _detalleMeta,
        detalle.isAcceptableOrUnknown(data['detalle']!, _detalleMeta),
      );
    }
    if (data.containsKey('carbos')) {
      context.handle(
        _carbosMeta,
        carbos.isAcceptableOrUnknown(data['carbos']!, _carbosMeta),
      );
    }
    if (data.containsKey('proteina')) {
      context.handle(
        _proteinaMeta,
        proteina.isAcceptableOrUnknown(data['proteina']!, _proteinaMeta),
      );
    }
    if (data.containsKey('grasa')) {
      context.handle(
        _grasaMeta,
        grasa.isAcceptableOrUnknown(data['grasa']!, _grasaMeta),
      );
    }
    if (data.containsKey('fibra')) {
      context.handle(
        _fibraMeta,
        fibra.isAcceptableOrUnknown(data['fibra']!, _fibraMeta),
      );
    }
    if (data.containsKey('calorias')) {
      context.handle(
        _caloriasMeta,
        calorias.isAcceptableOrUnknown(data['calorias']!, _caloriasMeta),
      );
    }
    if (data.containsKey('nivel')) {
      context.handle(
        _nivelMeta,
        nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta),
      );
    }
    if (data.containsKey('dosis')) {
      context.handle(
        _dosisMeta,
        dosis.isAcceptableOrUnknown(data['dosis']!, _dosisMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      momento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}momento'],
      )!,
      tipo: $EventosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      detalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle'],
      ),
      carbos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbos'],
      ),
      proteina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proteina'],
      ),
      grasa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grasa'],
      ),
      fibra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fibra'],
      ),
      calorias: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calorias'],
      ),
      nivel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nivel'],
      ),
      dosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosis'],
      ),
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoEvento, int, int> $convertertipo =
      const EnumIndexConverter<TipoEvento>(TipoEvento.values);
}

class Evento extends DataClass implements Insertable<Evento> {
  final int id;
  final DateTime momento;
  final TipoEvento tipo;

  /// Alimento, nombre del medicamento/suplemento, o descripción de la actividad.
  final String titulo;
  final String? detalle;
  final double? carbos;
  final double? proteina;
  final double? grasa;
  final double? fibra;
  final double? calorias;

  /// Intensidad/nivel 1-10 (estrés, o intensidad de ejercicio).
  final int? nivel;

  /// Dosis de medicamento o suplemento, como texto ("500 mg", "1 cápsula").
  final String? dosis;
  const Evento({
    required this.id,
    required this.momento,
    required this.tipo,
    required this.titulo,
    this.detalle,
    this.carbos,
    this.proteina,
    this.grasa,
    this.fibra,
    this.calorias,
    this.nivel,
    this.dosis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['momento'] = Variable<DateTime>(momento);
    {
      map['tipo'] = Variable<int>($EventosTable.$convertertipo.toSql(tipo));
    }
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || detalle != null) {
      map['detalle'] = Variable<String>(detalle);
    }
    if (!nullToAbsent || carbos != null) {
      map['carbos'] = Variable<double>(carbos);
    }
    if (!nullToAbsent || proteina != null) {
      map['proteina'] = Variable<double>(proteina);
    }
    if (!nullToAbsent || grasa != null) {
      map['grasa'] = Variable<double>(grasa);
    }
    if (!nullToAbsent || fibra != null) {
      map['fibra'] = Variable<double>(fibra);
    }
    if (!nullToAbsent || calorias != null) {
      map['calorias'] = Variable<double>(calorias);
    }
    if (!nullToAbsent || nivel != null) {
      map['nivel'] = Variable<int>(nivel);
    }
    if (!nullToAbsent || dosis != null) {
      map['dosis'] = Variable<String>(dosis);
    }
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      id: Value(id),
      momento: Value(momento),
      tipo: Value(tipo),
      titulo: Value(titulo),
      detalle: detalle == null && nullToAbsent
          ? const Value.absent()
          : Value(detalle),
      carbos: carbos == null && nullToAbsent
          ? const Value.absent()
          : Value(carbos),
      proteina: proteina == null && nullToAbsent
          ? const Value.absent()
          : Value(proteina),
      grasa: grasa == null && nullToAbsent
          ? const Value.absent()
          : Value(grasa),
      fibra: fibra == null && nullToAbsent
          ? const Value.absent()
          : Value(fibra),
      calorias: calorias == null && nullToAbsent
          ? const Value.absent()
          : Value(calorias),
      nivel: nivel == null && nullToAbsent
          ? const Value.absent()
          : Value(nivel),
      dosis: dosis == null && nullToAbsent
          ? const Value.absent()
          : Value(dosis),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      id: serializer.fromJson<int>(json['id']),
      momento: serializer.fromJson<DateTime>(json['momento']),
      tipo: $EventosTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      titulo: serializer.fromJson<String>(json['titulo']),
      detalle: serializer.fromJson<String?>(json['detalle']),
      carbos: serializer.fromJson<double?>(json['carbos']),
      proteina: serializer.fromJson<double?>(json['proteina']),
      grasa: serializer.fromJson<double?>(json['grasa']),
      fibra: serializer.fromJson<double?>(json['fibra']),
      calorias: serializer.fromJson<double?>(json['calorias']),
      nivel: serializer.fromJson<int?>(json['nivel']),
      dosis: serializer.fromJson<String?>(json['dosis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'momento': serializer.toJson<DateTime>(momento),
      'tipo': serializer.toJson<int>($EventosTable.$convertertipo.toJson(tipo)),
      'titulo': serializer.toJson<String>(titulo),
      'detalle': serializer.toJson<String?>(detalle),
      'carbos': serializer.toJson<double?>(carbos),
      'proteina': serializer.toJson<double?>(proteina),
      'grasa': serializer.toJson<double?>(grasa),
      'fibra': serializer.toJson<double?>(fibra),
      'calorias': serializer.toJson<double?>(calorias),
      'nivel': serializer.toJson<int?>(nivel),
      'dosis': serializer.toJson<String?>(dosis),
    };
  }

  Evento copyWith({
    int? id,
    DateTime? momento,
    TipoEvento? tipo,
    String? titulo,
    Value<String?> detalle = const Value.absent(),
    Value<double?> carbos = const Value.absent(),
    Value<double?> proteina = const Value.absent(),
    Value<double?> grasa = const Value.absent(),
    Value<double?> fibra = const Value.absent(),
    Value<double?> calorias = const Value.absent(),
    Value<int?> nivel = const Value.absent(),
    Value<String?> dosis = const Value.absent(),
  }) => Evento(
    id: id ?? this.id,
    momento: momento ?? this.momento,
    tipo: tipo ?? this.tipo,
    titulo: titulo ?? this.titulo,
    detalle: detalle.present ? detalle.value : this.detalle,
    carbos: carbos.present ? carbos.value : this.carbos,
    proteina: proteina.present ? proteina.value : this.proteina,
    grasa: grasa.present ? grasa.value : this.grasa,
    fibra: fibra.present ? fibra.value : this.fibra,
    calorias: calorias.present ? calorias.value : this.calorias,
    nivel: nivel.present ? nivel.value : this.nivel,
    dosis: dosis.present ? dosis.value : this.dosis,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      momento: data.momento.present ? data.momento.value : this.momento,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      detalle: data.detalle.present ? data.detalle.value : this.detalle,
      carbos: data.carbos.present ? data.carbos.value : this.carbos,
      proteina: data.proteina.present ? data.proteina.value : this.proteina,
      grasa: data.grasa.present ? data.grasa.value : this.grasa,
      fibra: data.fibra.present ? data.fibra.value : this.fibra,
      calorias: data.calorias.present ? data.calorias.value : this.calorias,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      dosis: data.dosis.present ? data.dosis.value : this.dosis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('id: $id, ')
          ..write('momento: $momento, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('detalle: $detalle, ')
          ..write('carbos: $carbos, ')
          ..write('proteina: $proteina, ')
          ..write('grasa: $grasa, ')
          ..write('fibra: $fibra, ')
          ..write('calorias: $calorias, ')
          ..write('nivel: $nivel, ')
          ..write('dosis: $dosis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    momento,
    tipo,
    titulo,
    detalle,
    carbos,
    proteina,
    grasa,
    fibra,
    calorias,
    nivel,
    dosis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.momento == this.momento &&
          other.tipo == this.tipo &&
          other.titulo == this.titulo &&
          other.detalle == this.detalle &&
          other.carbos == this.carbos &&
          other.proteina == this.proteina &&
          other.grasa == this.grasa &&
          other.fibra == this.fibra &&
          other.calorias == this.calorias &&
          other.nivel == this.nivel &&
          other.dosis == this.dosis);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<int> id;
  final Value<DateTime> momento;
  final Value<TipoEvento> tipo;
  final Value<String> titulo;
  final Value<String?> detalle;
  final Value<double?> carbos;
  final Value<double?> proteina;
  final Value<double?> grasa;
  final Value<double?> fibra;
  final Value<double?> calorias;
  final Value<int?> nivel;
  final Value<String?> dosis;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.momento = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.detalle = const Value.absent(),
    this.carbos = const Value.absent(),
    this.proteina = const Value.absent(),
    this.grasa = const Value.absent(),
    this.fibra = const Value.absent(),
    this.calorias = const Value.absent(),
    this.nivel = const Value.absent(),
    this.dosis = const Value.absent(),
  });
  EventosCompanion.insert({
    this.id = const Value.absent(),
    required DateTime momento,
    required TipoEvento tipo,
    required String titulo,
    this.detalle = const Value.absent(),
    this.carbos = const Value.absent(),
    this.proteina = const Value.absent(),
    this.grasa = const Value.absent(),
    this.fibra = const Value.absent(),
    this.calorias = const Value.absent(),
    this.nivel = const Value.absent(),
    this.dosis = const Value.absent(),
  }) : momento = Value(momento),
       tipo = Value(tipo),
       titulo = Value(titulo);
  static Insertable<Evento> custom({
    Expression<int>? id,
    Expression<DateTime>? momento,
    Expression<int>? tipo,
    Expression<String>? titulo,
    Expression<String>? detalle,
    Expression<double>? carbos,
    Expression<double>? proteina,
    Expression<double>? grasa,
    Expression<double>? fibra,
    Expression<double>? calorias,
    Expression<int>? nivel,
    Expression<String>? dosis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (momento != null) 'momento': momento,
      if (tipo != null) 'tipo': tipo,
      if (titulo != null) 'titulo': titulo,
      if (detalle != null) 'detalle': detalle,
      if (carbos != null) 'carbos': carbos,
      if (proteina != null) 'proteina': proteina,
      if (grasa != null) 'grasa': grasa,
      if (fibra != null) 'fibra': fibra,
      if (calorias != null) 'calorias': calorias,
      if (nivel != null) 'nivel': nivel,
      if (dosis != null) 'dosis': dosis,
    });
  }

  EventosCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? momento,
    Value<TipoEvento>? tipo,
    Value<String>? titulo,
    Value<String?>? detalle,
    Value<double?>? carbos,
    Value<double?>? proteina,
    Value<double?>? grasa,
    Value<double?>? fibra,
    Value<double?>? calorias,
    Value<int?>? nivel,
    Value<String?>? dosis,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      momento: momento ?? this.momento,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      detalle: detalle ?? this.detalle,
      carbos: carbos ?? this.carbos,
      proteina: proteina ?? this.proteina,
      grasa: grasa ?? this.grasa,
      fibra: fibra ?? this.fibra,
      calorias: calorias ?? this.calorias,
      nivel: nivel ?? this.nivel,
      dosis: dosis ?? this.dosis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (momento.present) {
      map['momento'] = Variable<DateTime>(momento.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $EventosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (detalle.present) {
      map['detalle'] = Variable<String>(detalle.value);
    }
    if (carbos.present) {
      map['carbos'] = Variable<double>(carbos.value);
    }
    if (proteina.present) {
      map['proteina'] = Variable<double>(proteina.value);
    }
    if (grasa.present) {
      map['grasa'] = Variable<double>(grasa.value);
    }
    if (fibra.present) {
      map['fibra'] = Variable<double>(fibra.value);
    }
    if (calorias.present) {
      map['calorias'] = Variable<double>(calorias.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<int>(nivel.value);
    }
    if (dosis.present) {
      map['dosis'] = Variable<String>(dosis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('id: $id, ')
          ..write('momento: $momento, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('detalle: $detalle, ')
          ..write('carbos: $carbos, ')
          ..write('proteina: $proteina, ')
          ..write('grasa: $grasa, ')
          ..write('fibra: $fibra, ')
          ..write('calorias: $calorias, ')
          ..write('nivel: $nivel, ')
          ..write('dosis: $dosis')
          ..write(')'))
        .toString();
  }
}

class $PesosCorporalesTable extends PesosCorporales
    with TableInfo<$PesosCorporalesTable, PesoCorporal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesosCorporalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<DateTime> dia = GeneratedColumn<DateTime>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dia, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesos_corporales';
  @override
  VerificationContext validateIntegrity(
    Insertable<PesoCorporal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dia};
  @override
  PesoCorporal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PesoCorporal(
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dia'],
      )!,
      kg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kg'],
      )!,
    );
  }

  @override
  $PesosCorporalesTable createAlias(String alias) {
    return $PesosCorporalesTable(attachedDatabase, alias);
  }
}

class PesoCorporal extends DataClass implements Insertable<PesoCorporal> {
  final DateTime dia;
  final double kg;
  const PesoCorporal({required this.dia, required this.kg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dia'] = Variable<DateTime>(dia);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  PesosCorporalesCompanion toCompanion(bool nullToAbsent) {
    return PesosCorporalesCompanion(dia: Value(dia), kg: Value(kg));
  }

  factory PesoCorporal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PesoCorporal(
      dia: serializer.fromJson<DateTime>(json['dia']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dia': serializer.toJson<DateTime>(dia),
      'kg': serializer.toJson<double>(kg),
    };
  }

  PesoCorporal copyWith({DateTime? dia, double? kg}) =>
      PesoCorporal(dia: dia ?? this.dia, kg: kg ?? this.kg);
  PesoCorporal copyWithCompanion(PesosCorporalesCompanion data) {
    return PesoCorporal(
      dia: data.dia.present ? data.dia.value : this.dia,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PesoCorporal(')
          ..write('dia: $dia, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dia, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PesoCorporal && other.dia == this.dia && other.kg == this.kg);
}

class PesosCorporalesCompanion extends UpdateCompanion<PesoCorporal> {
  final Value<DateTime> dia;
  final Value<double> kg;
  final Value<int> rowid;
  const PesosCorporalesCompanion({
    this.dia = const Value.absent(),
    this.kg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PesosCorporalesCompanion.insert({
    required DateTime dia,
    required double kg,
    this.rowid = const Value.absent(),
  }) : dia = Value(dia),
       kg = Value(kg);
  static Insertable<PesoCorporal> custom({
    Expression<DateTime>? dia,
    Expression<double>? kg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dia != null) 'dia': dia,
      if (kg != null) 'kg': kg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PesosCorporalesCompanion copyWith({
    Value<DateTime>? dia,
    Value<double>? kg,
    Value<int>? rowid,
  }) {
    return PesosCorporalesCompanion(
      dia: dia ?? this.dia,
      kg: kg ?? this.kg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dia.present) {
      map['dia'] = Variable<DateTime>(dia.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesosCorporalesCompanion(')
          ..write('dia: $dia, ')
          ..write('kg: $kg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatos extends GeneratedDatabase {
  _$BaseDatos(QueryExecutor e) : super(e);
  $BaseDatosManager get managers => $BaseDatosManager(this);
  late final $SesionesTable sesiones = $SesionesTable(this);
  late final $SeriesTable series = $SeriesTable(this);
  late final $RutinasTable rutinas = $RutinasTable(this);
  late final $RutinaEjerciciosTable rutinaEjercicios = $RutinaEjerciciosTable(
    this,
  );
  late final $PlanSemanalTable planSemanal = $PlanSemanalTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $PesosCorporalesTable pesosCorporales = $PesosCorporalesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sesiones,
    series,
    rutinas,
    rutinaEjercicios,
    planSemanal,
    eventos,
    pesosCorporales,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sesiones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('series', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rutinas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rutina_ejercicios', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SesionesTableCreateCompanionBuilder =
    SesionesCompanion Function({
      Value<int> id,
      required String nombre,
      required DateTime inicio,
      Value<DateTime?> fin,
      Value<String?> notas,
      Value<String?> lugar,
      Value<Animo?> animoAntes,
      Value<int?> energia,
      Value<int?> dolor,
    });
typedef $$SesionesTableUpdateCompanionBuilder =
    SesionesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<DateTime> inicio,
      Value<DateTime?> fin,
      Value<String?> notas,
      Value<String?> lugar,
      Value<Animo?> animoAntes,
      Value<int?> energia,
      Value<int?> dolor,
    });

final class $$SesionesTableReferences
    extends BaseReferences<_$BaseDatos, $SesionesTable, Sesion> {
  $$SesionesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeriesTable, List<Serie>> _seriesRefsTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.series,
    aliasName: 'sesiones__id__series__sesion_id',
  );

  $$SeriesTableProcessedTableManager get seriesRefs {
    final manager = $$SeriesTableTableManager(
      $_db,
      $_db.series,
    ).filter((f) => f.sesionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SesionesTableFilterComposer
    extends Composer<_$BaseDatos, $SesionesTable> {
  $$SesionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Animo?, Animo, int> get animoAntes =>
      $composableBuilder(
        column: $table.animoAntes,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get energia => $composableBuilder(
    column: $table.energia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dolor => $composableBuilder(
    column: $table.dolor,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seriesRefs(
    Expression<bool> Function($$SeriesTableFilterComposer f) f,
  ) {
    final $$SeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.sesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableFilterComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SesionesTableOrderingComposer
    extends Composer<_$BaseDatos, $SesionesTable> {
  $$SesionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get animoAntes => $composableBuilder(
    column: $table.animoAntes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energia => $composableBuilder(
    column: $table.energia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dolor => $composableBuilder(
    column: $table.dolor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SesionesTableAnnotationComposer
    extends Composer<_$BaseDatos, $SesionesTable> {
  $$SesionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<String> get lugar =>
      $composableBuilder(column: $table.lugar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Animo?, int> get animoAntes =>
      $composableBuilder(
        column: $table.animoAntes,
        builder: (column) => column,
      );

  GeneratedColumn<int> get energia =>
      $composableBuilder(column: $table.energia, builder: (column) => column);

  GeneratedColumn<int> get dolor =>
      $composableBuilder(column: $table.dolor, builder: (column) => column);

  Expression<T> seriesRefs<T extends Object>(
    Expression<T> Function($$SeriesTableAnnotationComposer a) f,
  ) {
    final $$SeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.sesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SesionesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $SesionesTable,
          Sesion,
          $$SesionesTableFilterComposer,
          $$SesionesTableOrderingComposer,
          $$SesionesTableAnnotationComposer,
          $$SesionesTableCreateCompanionBuilder,
          $$SesionesTableUpdateCompanionBuilder,
          (Sesion, $$SesionesTableReferences),
          Sesion,
          PrefetchHooks Function({bool seriesRefs})
        > {
  $$SesionesTableTableManager(_$BaseDatos db, $SesionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime?> fin = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> lugar = const Value.absent(),
                Value<Animo?> animoAntes = const Value.absent(),
                Value<int?> energia = const Value.absent(),
                Value<int?> dolor = const Value.absent(),
              }) => SesionesCompanion(
                id: id,
                nombre: nombre,
                inicio: inicio,
                fin: fin,
                notas: notas,
                lugar: lugar,
                animoAntes: animoAntes,
                energia: energia,
                dolor: dolor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required DateTime inicio,
                Value<DateTime?> fin = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> lugar = const Value.absent(),
                Value<Animo?> animoAntes = const Value.absent(),
                Value<int?> energia = const Value.absent(),
                Value<int?> dolor = const Value.absent(),
              }) => SesionesCompanion.insert(
                id: id,
                nombre: nombre,
                inicio: inicio,
                fin: fin,
                notas: notas,
                lugar: lugar,
                animoAntes: animoAntes,
                energia: energia,
                dolor: dolor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SesionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (seriesRefs) db.series],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seriesRefs)
                    await $_getPrefetchedData<Sesion, $SesionesTable, Serie>(
                      currentTable: table,
                      referencedTable: $$SesionesTableReferences
                          ._seriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SesionesTableReferences(db, table, p0).seriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sesionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SesionesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $SesionesTable,
      Sesion,
      $$SesionesTableFilterComposer,
      $$SesionesTableOrderingComposer,
      $$SesionesTableAnnotationComposer,
      $$SesionesTableCreateCompanionBuilder,
      $$SesionesTableUpdateCompanionBuilder,
      (Sesion, $$SesionesTableReferences),
      Sesion,
      PrefetchHooks Function({bool seriesRefs})
    >;
typedef $$SeriesTableCreateCompanionBuilder =
    SeriesCompanion Function({
      Value<int> id,
      required int sesionId,
      required String ejercicioId,
      required int orden,
      required int repeticiones,
      Value<double> pesoKg,
      Value<bool> hecha,
      Value<TipoSerie> tipo,
      Value<int?> rpe,
      Value<int?> descansoSeg,
    });
typedef $$SeriesTableUpdateCompanionBuilder =
    SeriesCompanion Function({
      Value<int> id,
      Value<int> sesionId,
      Value<String> ejercicioId,
      Value<int> orden,
      Value<int> repeticiones,
      Value<double> pesoKg,
      Value<bool> hecha,
      Value<TipoSerie> tipo,
      Value<int?> rpe,
      Value<int?> descansoSeg,
    });

final class $$SeriesTableReferences
    extends BaseReferences<_$BaseDatos, $SeriesTable, Serie> {
  $$SeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SesionesTable _sesionIdTable(_$BaseDatos db) =>
      db.sesiones.createAlias('series__sesion_id__sesiones__id');

  $$SesionesTableProcessedTableManager get sesionId {
    final $_column = $_itemColumn<int>('sesion_id')!;

    final manager = $$SesionesTableTableManager(
      $_db,
      $_db.sesiones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesTableFilterComposer extends Composer<_$BaseDatos, $SeriesTable> {
  $$SeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeticiones => $composableBuilder(
    column: $table.repeticiones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoKg => $composableBuilder(
    column: $table.pesoKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hecha => $composableBuilder(
    column: $table.hecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoSerie, TipoSerie, int> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get descansoSeg => $composableBuilder(
    column: $table.descansoSeg,
    builder: (column) => ColumnFilters(column),
  );

  $$SesionesTableFilterComposer get sesionId {
    final $$SesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sesionId,
      referencedTable: $db.sesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SesionesTableFilterComposer(
            $db: $db,
            $table: $db.sesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableOrderingComposer
    extends Composer<_$BaseDatos, $SeriesTable> {
  $$SeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeticiones => $composableBuilder(
    column: $table.repeticiones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoKg => $composableBuilder(
    column: $table.pesoKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hecha => $composableBuilder(
    column: $table.hecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get descansoSeg => $composableBuilder(
    column: $table.descansoSeg,
    builder: (column) => ColumnOrderings(column),
  );

  $$SesionesTableOrderingComposer get sesionId {
    final $$SesionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sesionId,
      referencedTable: $db.sesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SesionesTableOrderingComposer(
            $db: $db,
            $table: $db.sesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableAnnotationComposer
    extends Composer<_$BaseDatos, $SeriesTable> {
  $$SeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<int> get repeticiones => $composableBuilder(
    column: $table.repeticiones,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoKg =>
      $composableBuilder(column: $table.pesoKg, builder: (column) => column);

  GeneratedColumn<bool> get hecha =>
      $composableBuilder(column: $table.hecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoSerie, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get descansoSeg => $composableBuilder(
    column: $table.descansoSeg,
    builder: (column) => column,
  );

  $$SesionesTableAnnotationComposer get sesionId {
    final $$SesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sesionId,
      referencedTable: $db.sesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.sesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $SeriesTable,
          Serie,
          $$SeriesTableFilterComposer,
          $$SeriesTableOrderingComposer,
          $$SeriesTableAnnotationComposer,
          $$SeriesTableCreateCompanionBuilder,
          $$SeriesTableUpdateCompanionBuilder,
          (Serie, $$SeriesTableReferences),
          Serie,
          PrefetchHooks Function({bool sesionId})
        > {
  $$SeriesTableTableManager(_$BaseDatos db, $SeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sesionId = const Value.absent(),
                Value<String> ejercicioId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<int> repeticiones = const Value.absent(),
                Value<double> pesoKg = const Value.absent(),
                Value<bool> hecha = const Value.absent(),
                Value<TipoSerie> tipo = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int?> descansoSeg = const Value.absent(),
              }) => SeriesCompanion(
                id: id,
                sesionId: sesionId,
                ejercicioId: ejercicioId,
                orden: orden,
                repeticiones: repeticiones,
                pesoKg: pesoKg,
                hecha: hecha,
                tipo: tipo,
                rpe: rpe,
                descansoSeg: descansoSeg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sesionId,
                required String ejercicioId,
                required int orden,
                required int repeticiones,
                Value<double> pesoKg = const Value.absent(),
                Value<bool> hecha = const Value.absent(),
                Value<TipoSerie> tipo = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int?> descansoSeg = const Value.absent(),
              }) => SeriesCompanion.insert(
                id: id,
                sesionId: sesionId,
                ejercicioId: ejercicioId,
                orden: orden,
                repeticiones: repeticiones,
                pesoKg: pesoKg,
                hecha: hecha,
                tipo: tipo,
                rpe: rpe,
                descansoSeg: descansoSeg,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SeriesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sesionId = false}) {
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
                    if (sesionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sesionId,
                                referencedTable: $$SeriesTableReferences
                                    ._sesionIdTable(db),
                                referencedColumn: $$SeriesTableReferences
                                    ._sesionIdTable(db)
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

typedef $$SeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $SeriesTable,
      Serie,
      $$SeriesTableFilterComposer,
      $$SeriesTableOrderingComposer,
      $$SeriesTableAnnotationComposer,
      $$SeriesTableCreateCompanionBuilder,
      $$SeriesTableUpdateCompanionBuilder,
      (Serie, $$SeriesTableReferences),
      Serie,
      PrefetchHooks Function({bool sesionId})
    >;
typedef $$RutinasTableCreateCompanionBuilder =
    RutinasCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> notas,
      required DateTime creada,
    });
typedef $$RutinasTableUpdateCompanionBuilder =
    RutinasCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> notas,
      Value<DateTime> creada,
    });

final class $$RutinasTableReferences
    extends BaseReferences<_$BaseDatos, $RutinasTable, Rutina> {
  $$RutinasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RutinaEjerciciosTable, List<RutinaEjercicio>>
  _rutinaEjerciciosRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.rutinaEjercicios,
    aliasName: 'rutinas__id__rutina_ejercicios__rutina_id',
  );

  $$RutinaEjerciciosTableProcessedTableManager get rutinaEjerciciosRefs {
    final manager = $$RutinaEjerciciosTableTableManager(
      $_db,
      $_db.rutinaEjercicios,
    ).filter((f) => f.rutinaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rutinaEjerciciosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RutinasTableFilterComposer
    extends Composer<_$BaseDatos, $RutinasTable> {
  $$RutinasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creada => $composableBuilder(
    column: $table.creada,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rutinaEjerciciosRefs(
    Expression<bool> Function($$RutinaEjerciciosTableFilterComposer f) f,
  ) {
    final $$RutinaEjerciciosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rutinaEjercicios,
      getReferencedColumn: (t) => t.rutinaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinaEjerciciosTableFilterComposer(
            $db: $db,
            $table: $db.rutinaEjercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RutinasTableOrderingComposer
    extends Composer<_$BaseDatos, $RutinasTable> {
  $$RutinasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creada => $composableBuilder(
    column: $table.creada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RutinasTableAnnotationComposer
    extends Composer<_$BaseDatos, $RutinasTable> {
  $$RutinasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creada =>
      $composableBuilder(column: $table.creada, builder: (column) => column);

  Expression<T> rutinaEjerciciosRefs<T extends Object>(
    Expression<T> Function($$RutinaEjerciciosTableAnnotationComposer a) f,
  ) {
    final $$RutinaEjerciciosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rutinaEjercicios,
      getReferencedColumn: (t) => t.rutinaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinaEjerciciosTableAnnotationComposer(
            $db: $db,
            $table: $db.rutinaEjercicios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RutinasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $RutinasTable,
          Rutina,
          $$RutinasTableFilterComposer,
          $$RutinasTableOrderingComposer,
          $$RutinasTableAnnotationComposer,
          $$RutinasTableCreateCompanionBuilder,
          $$RutinasTableUpdateCompanionBuilder,
          (Rutina, $$RutinasTableReferences),
          Rutina,
          PrefetchHooks Function({bool rutinaEjerciciosRefs})
        > {
  $$RutinasTableTableManager(_$BaseDatos db, $RutinasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creada = const Value.absent(),
              }) => RutinasCompanion(
                id: id,
                nombre: nombre,
                notas: notas,
                creada: creada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> notas = const Value.absent(),
                required DateTime creada,
              }) => RutinasCompanion.insert(
                id: id,
                nombre: nombre,
                notas: notas,
                creada: creada,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RutinasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rutinaEjerciciosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rutinaEjerciciosRefs) db.rutinaEjercicios,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rutinaEjerciciosRefs)
                    await $_getPrefetchedData<
                      Rutina,
                      $RutinasTable,
                      RutinaEjercicio
                    >(
                      currentTable: table,
                      referencedTable: $$RutinasTableReferences
                          ._rutinaEjerciciosRefsTable(db),
                      managerFromTypedResult: (p0) => $$RutinasTableReferences(
                        db,
                        table,
                        p0,
                      ).rutinaEjerciciosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rutinaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RutinasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $RutinasTable,
      Rutina,
      $$RutinasTableFilterComposer,
      $$RutinasTableOrderingComposer,
      $$RutinasTableAnnotationComposer,
      $$RutinasTableCreateCompanionBuilder,
      $$RutinasTableUpdateCompanionBuilder,
      (Rutina, $$RutinasTableReferences),
      Rutina,
      PrefetchHooks Function({bool rutinaEjerciciosRefs})
    >;
typedef $$RutinaEjerciciosTableCreateCompanionBuilder =
    RutinaEjerciciosCompanion Function({
      Value<int> id,
      required int rutinaId,
      required String ejercicioId,
      required int orden,
      Value<int> seriesObjetivo,
      Value<int> repsObjetivo,
    });
typedef $$RutinaEjerciciosTableUpdateCompanionBuilder =
    RutinaEjerciciosCompanion Function({
      Value<int> id,
      Value<int> rutinaId,
      Value<String> ejercicioId,
      Value<int> orden,
      Value<int> seriesObjetivo,
      Value<int> repsObjetivo,
    });

final class $$RutinaEjerciciosTableReferences
    extends
        BaseReferences<_$BaseDatos, $RutinaEjerciciosTable, RutinaEjercicio> {
  $$RutinaEjerciciosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RutinasTable _rutinaIdTable(_$BaseDatos db) =>
      db.rutinas.createAlias('rutina_ejercicios__rutina_id__rutinas__id');

  $$RutinasTableProcessedTableManager get rutinaId {
    final $_column = $_itemColumn<int>('rutina_id')!;

    final manager = $$RutinasTableTableManager(
      $_db,
      $_db.rutinas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rutinaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RutinaEjerciciosTableFilterComposer
    extends Composer<_$BaseDatos, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesObjetivo => $composableBuilder(
    column: $table.seriesObjetivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repsObjetivo => $composableBuilder(
    column: $table.repsObjetivo,
    builder: (column) => ColumnFilters(column),
  );

  $$RutinasTableFilterComposer get rutinaId {
    final $$RutinasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinaId,
      referencedTable: $db.rutinas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinasTableFilterComposer(
            $db: $db,
            $table: $db.rutinas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinaEjerciciosTableOrderingComposer
    extends Composer<_$BaseDatos, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesObjetivo => $composableBuilder(
    column: $table.seriesObjetivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repsObjetivo => $composableBuilder(
    column: $table.repsObjetivo,
    builder: (column) => ColumnOrderings(column),
  );

  $$RutinasTableOrderingComposer get rutinaId {
    final $$RutinasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinaId,
      referencedTable: $db.rutinas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinasTableOrderingComposer(
            $db: $db,
            $table: $db.rutinas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinaEjerciciosTableAnnotationComposer
    extends Composer<_$BaseDatos, $RutinaEjerciciosTable> {
  $$RutinaEjerciciosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ejercicioId => $composableBuilder(
    column: $table.ejercicioId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<int> get seriesObjetivo => $composableBuilder(
    column: $table.seriesObjetivo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repsObjetivo => $composableBuilder(
    column: $table.repsObjetivo,
    builder: (column) => column,
  );

  $$RutinasTableAnnotationComposer get rutinaId {
    final $$RutinasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rutinaId,
      referencedTable: $db.rutinas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RutinasTableAnnotationComposer(
            $db: $db,
            $table: $db.rutinas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RutinaEjerciciosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $RutinaEjerciciosTable,
          RutinaEjercicio,
          $$RutinaEjerciciosTableFilterComposer,
          $$RutinaEjerciciosTableOrderingComposer,
          $$RutinaEjerciciosTableAnnotationComposer,
          $$RutinaEjerciciosTableCreateCompanionBuilder,
          $$RutinaEjerciciosTableUpdateCompanionBuilder,
          (RutinaEjercicio, $$RutinaEjerciciosTableReferences),
          RutinaEjercicio,
          PrefetchHooks Function({bool rutinaId})
        > {
  $$RutinaEjerciciosTableTableManager(
    _$BaseDatos db,
    $RutinaEjerciciosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RutinaEjerciciosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RutinaEjerciciosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RutinaEjerciciosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rutinaId = const Value.absent(),
                Value<String> ejercicioId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<int> seriesObjetivo = const Value.absent(),
                Value<int> repsObjetivo = const Value.absent(),
              }) => RutinaEjerciciosCompanion(
                id: id,
                rutinaId: rutinaId,
                ejercicioId: ejercicioId,
                orden: orden,
                seriesObjetivo: seriesObjetivo,
                repsObjetivo: repsObjetivo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rutinaId,
                required String ejercicioId,
                required int orden,
                Value<int> seriesObjetivo = const Value.absent(),
                Value<int> repsObjetivo = const Value.absent(),
              }) => RutinaEjerciciosCompanion.insert(
                id: id,
                rutinaId: rutinaId,
                ejercicioId: ejercicioId,
                orden: orden,
                seriesObjetivo: seriesObjetivo,
                repsObjetivo: repsObjetivo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RutinaEjerciciosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rutinaId = false}) {
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
                    if (rutinaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rutinaId,
                                referencedTable:
                                    $$RutinaEjerciciosTableReferences
                                        ._rutinaIdTable(db),
                                referencedColumn:
                                    $$RutinaEjerciciosTableReferences
                                        ._rutinaIdTable(db)
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

typedef $$RutinaEjerciciosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $RutinaEjerciciosTable,
      RutinaEjercicio,
      $$RutinaEjerciciosTableFilterComposer,
      $$RutinaEjerciciosTableOrderingComposer,
      $$RutinaEjerciciosTableAnnotationComposer,
      $$RutinaEjerciciosTableCreateCompanionBuilder,
      $$RutinaEjerciciosTableUpdateCompanionBuilder,
      (RutinaEjercicio, $$RutinaEjerciciosTableReferences),
      RutinaEjercicio,
      PrefetchHooks Function({bool rutinaId})
    >;
typedef $$PlanSemanalTableCreateCompanionBuilder =
    PlanSemanalCompanion Function({
      Value<int> dia,
      required String titulo,
      Value<String> grupos,
      Value<bool> descanso,
    });
typedef $$PlanSemanalTableUpdateCompanionBuilder =
    PlanSemanalCompanion Function({
      Value<int> dia,
      Value<String> titulo,
      Value<String> grupos,
      Value<bool> descanso,
    });

class $$PlanSemanalTableFilterComposer
    extends Composer<_$BaseDatos, $PlanSemanalTable> {
  $$PlanSemanalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grupos => $composableBuilder(
    column: $table.grupos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get descanso => $composableBuilder(
    column: $table.descanso,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanSemanalTableOrderingComposer
    extends Composer<_$BaseDatos, $PlanSemanalTable> {
  $$PlanSemanalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grupos => $composableBuilder(
    column: $table.grupos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get descanso => $composableBuilder(
    column: $table.descanso,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanSemanalTableAnnotationComposer
    extends Composer<_$BaseDatos, $PlanSemanalTable> {
  $$PlanSemanalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get grupos =>
      $composableBuilder(column: $table.grupos, builder: (column) => column);

  GeneratedColumn<bool> get descanso =>
      $composableBuilder(column: $table.descanso, builder: (column) => column);
}

class $$PlanSemanalTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PlanSemanalTable,
          DiaPlan,
          $$PlanSemanalTableFilterComposer,
          $$PlanSemanalTableOrderingComposer,
          $$PlanSemanalTableAnnotationComposer,
          $$PlanSemanalTableCreateCompanionBuilder,
          $$PlanSemanalTableUpdateCompanionBuilder,
          (DiaPlan, BaseReferences<_$BaseDatos, $PlanSemanalTable, DiaPlan>),
          DiaPlan,
          PrefetchHooks Function()
        > {
  $$PlanSemanalTableTableManager(_$BaseDatos db, $PlanSemanalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanSemanalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanSemanalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanSemanalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dia = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String> grupos = const Value.absent(),
                Value<bool> descanso = const Value.absent(),
              }) => PlanSemanalCompanion(
                dia: dia,
                titulo: titulo,
                grupos: grupos,
                descanso: descanso,
              ),
          createCompanionCallback:
              ({
                Value<int> dia = const Value.absent(),
                required String titulo,
                Value<String> grupos = const Value.absent(),
                Value<bool> descanso = const Value.absent(),
              }) => PlanSemanalCompanion.insert(
                dia: dia,
                titulo: titulo,
                grupos: grupos,
                descanso: descanso,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanSemanalTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PlanSemanalTable,
      DiaPlan,
      $$PlanSemanalTableFilterComposer,
      $$PlanSemanalTableOrderingComposer,
      $$PlanSemanalTableAnnotationComposer,
      $$PlanSemanalTableCreateCompanionBuilder,
      $$PlanSemanalTableUpdateCompanionBuilder,
      (DiaPlan, BaseReferences<_$BaseDatos, $PlanSemanalTable, DiaPlan>),
      DiaPlan,
      PrefetchHooks Function()
    >;
typedef $$EventosTableCreateCompanionBuilder =
    EventosCompanion Function({
      Value<int> id,
      required DateTime momento,
      required TipoEvento tipo,
      required String titulo,
      Value<String?> detalle,
      Value<double?> carbos,
      Value<double?> proteina,
      Value<double?> grasa,
      Value<double?> fibra,
      Value<double?> calorias,
      Value<int?> nivel,
      Value<String?> dosis,
    });
typedef $$EventosTableUpdateCompanionBuilder =
    EventosCompanion Function({
      Value<int> id,
      Value<DateTime> momento,
      Value<TipoEvento> tipo,
      Value<String> titulo,
      Value<String?> detalle,
      Value<double?> carbos,
      Value<double?> proteina,
      Value<double?> grasa,
      Value<double?> fibra,
      Value<double?> calorias,
      Value<int?> nivel,
      Value<String?> dosis,
    });

class $$EventosTableFilterComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get momento => $composableBuilder(
    column: $table.momento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoEvento, TipoEvento, int> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbos => $composableBuilder(
    column: $table.carbos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grasa => $composableBuilder(
    column: $table.grasa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fibra => $composableBuilder(
    column: $table.fibra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calorias => $composableBuilder(
    column: $table.calorias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventosTableOrderingComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get momento => $composableBuilder(
    column: $table.momento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbos => $composableBuilder(
    column: $table.carbos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteina => $composableBuilder(
    column: $table.proteina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grasa => $composableBuilder(
    column: $table.grasa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fibra => $composableBuilder(
    column: $table.fibra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calorias => $composableBuilder(
    column: $table.calorias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventosTableAnnotationComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get momento =>
      $composableBuilder(column: $table.momento, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoEvento, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get detalle =>
      $composableBuilder(column: $table.detalle, builder: (column) => column);

  GeneratedColumn<double> get carbos =>
      $composableBuilder(column: $table.carbos, builder: (column) => column);

  GeneratedColumn<double> get proteina =>
      $composableBuilder(column: $table.proteina, builder: (column) => column);

  GeneratedColumn<double> get grasa =>
      $composableBuilder(column: $table.grasa, builder: (column) => column);

  GeneratedColumn<double> get fibra =>
      $composableBuilder(column: $table.fibra, builder: (column) => column);

  GeneratedColumn<double> get calorias =>
      $composableBuilder(column: $table.calorias, builder: (column) => column);

  GeneratedColumn<int> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<String> get dosis =>
      $composableBuilder(column: $table.dosis, builder: (column) => column);
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, BaseReferences<_$BaseDatos, $EventosTable, Evento>),
          Evento,
          PrefetchHooks Function()
        > {
  $$EventosTableTableManager(_$BaseDatos db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> momento = const Value.absent(),
                Value<TipoEvento> tipo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> detalle = const Value.absent(),
                Value<double?> carbos = const Value.absent(),
                Value<double?> proteina = const Value.absent(),
                Value<double?> grasa = const Value.absent(),
                Value<double?> fibra = const Value.absent(),
                Value<double?> calorias = const Value.absent(),
                Value<int?> nivel = const Value.absent(),
                Value<String?> dosis = const Value.absent(),
              }) => EventosCompanion(
                id: id,
                momento: momento,
                tipo: tipo,
                titulo: titulo,
                detalle: detalle,
                carbos: carbos,
                proteina: proteina,
                grasa: grasa,
                fibra: fibra,
                calorias: calorias,
                nivel: nivel,
                dosis: dosis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime momento,
                required TipoEvento tipo,
                required String titulo,
                Value<String?> detalle = const Value.absent(),
                Value<double?> carbos = const Value.absent(),
                Value<double?> proteina = const Value.absent(),
                Value<double?> grasa = const Value.absent(),
                Value<double?> fibra = const Value.absent(),
                Value<double?> calorias = const Value.absent(),
                Value<int?> nivel = const Value.absent(),
                Value<String?> dosis = const Value.absent(),
              }) => EventosCompanion.insert(
                id: id,
                momento: momento,
                tipo: tipo,
                titulo: titulo,
                detalle: detalle,
                carbos: carbos,
                proteina: proteina,
                grasa: grasa,
                fibra: fibra,
                calorias: calorias,
                nivel: nivel,
                dosis: dosis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, BaseReferences<_$BaseDatos, $EventosTable, Evento>),
      Evento,
      PrefetchHooks Function()
    >;
typedef $$PesosCorporalesTableCreateCompanionBuilder =
    PesosCorporalesCompanion Function({
      required DateTime dia,
      required double kg,
      Value<int> rowid,
    });
typedef $$PesosCorporalesTableUpdateCompanionBuilder =
    PesosCorporalesCompanion Function({
      Value<DateTime> dia,
      Value<double> kg,
      Value<int> rowid,
    });

class $$PesosCorporalesTableFilterComposer
    extends Composer<_$BaseDatos, $PesosCorporalesTable> {
  $$PesosCorporalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PesosCorporalesTableOrderingComposer
    extends Composer<_$BaseDatos, $PesosCorporalesTable> {
  $$PesosCorporalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PesosCorporalesTableAnnotationComposer
    extends Composer<_$BaseDatos, $PesosCorporalesTable> {
  $$PesosCorporalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$PesosCorporalesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PesosCorporalesTable,
          PesoCorporal,
          $$PesosCorporalesTableFilterComposer,
          $$PesosCorporalesTableOrderingComposer,
          $$PesosCorporalesTableAnnotationComposer,
          $$PesosCorporalesTableCreateCompanionBuilder,
          $$PesosCorporalesTableUpdateCompanionBuilder,
          (
            PesoCorporal,
            BaseReferences<_$BaseDatos, $PesosCorporalesTable, PesoCorporal>,
          ),
          PesoCorporal,
          PrefetchHooks Function()
        > {
  $$PesosCorporalesTableTableManager(
    _$BaseDatos db,
    $PesosCorporalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesosCorporalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesosCorporalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesosCorporalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> dia = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PesosCorporalesCompanion(dia: dia, kg: kg, rowid: rowid),
          createCompanionCallback:
              ({
                required DateTime dia,
                required double kg,
                Value<int> rowid = const Value.absent(),
              }) => PesosCorporalesCompanion.insert(
                dia: dia,
                kg: kg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PesosCorporalesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PesosCorporalesTable,
      PesoCorporal,
      $$PesosCorporalesTableFilterComposer,
      $$PesosCorporalesTableOrderingComposer,
      $$PesosCorporalesTableAnnotationComposer,
      $$PesosCorporalesTableCreateCompanionBuilder,
      $$PesosCorporalesTableUpdateCompanionBuilder,
      (
        PesoCorporal,
        BaseReferences<_$BaseDatos, $PesosCorporalesTable, PesoCorporal>,
      ),
      PesoCorporal,
      PrefetchHooks Function()
    >;

class $BaseDatosManager {
  final _$BaseDatos _db;
  $BaseDatosManager(this._db);
  $$SesionesTableTableManager get sesiones =>
      $$SesionesTableTableManager(_db, _db.sesiones);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$RutinasTableTableManager get rutinas =>
      $$RutinasTableTableManager(_db, _db.rutinas);
  $$RutinaEjerciciosTableTableManager get rutinaEjercicios =>
      $$RutinaEjerciciosTableTableManager(_db, _db.rutinaEjercicios);
  $$PlanSemanalTableTableManager get planSemanal =>
      $$PlanSemanalTableTableManager(_db, _db.planSemanal);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$PesosCorporalesTableTableManager get pesosCorporales =>
      $$PesosCorporalesTableTableManager(_db, _db.pesosCorporales);
}
