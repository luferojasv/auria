import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Una sesion de entrenamiento. [fin] nulo significa "en curso".
///
/// `@DataClassName` es necesario en varias tablas porque el singularizador
/// automatico de drift se equivoca con los plurales en espanol: de `Series`
/// deduce `Sery`, y de `Sesiones`, `Sesione`.
/// Centinela para columnas nullable: distingue "no tocar este campo" (dejar el
/// valor actual) de "ponerlo a null". Un `String? = null` no puede expresar esa
/// diferencia por sí solo.
const Object _sinCambio = Object();

/// Estado de ánimo, escala corta y ordenable para poder graficarla.
enum Animo { genial, bien, normal, bajo, mal }

extension AnimoEs on Animo {
  String get etiqueta => switch (this) {
        Animo.genial => 'Genial',
        Animo.bien => 'Bien',
        Animo.normal => 'Normal',
        Animo.bajo => 'Bajo',
        Animo.mal => 'Mal',
      };
}

@DataClassName('Sesion')
class Sesiones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fin => dateTime().nullable()();
  TextColumn get notas => text().nullable()();

  // --- Contexto previo al entrenamiento (esquema v2) ---
  TextColumn get lugar => text().nullable()();
  IntColumn get animoAntes => intEnum<Animo>().nullable()();

  /// Energía y dolor muscular percibidos antes de empezar, escala 1-10.
  IntColumn get energia => integer().nullable()();
  IntColumn get dolor => integer().nullable()();

  /// Rutina de la que salió esta sesión, si vino de una. Enlaza el plan → la
  /// sesión registrada. setNull para conservar la sesión aunque borres la
  /// rutina. v5.
  IntColumn get rutinaId =>
      integer().nullable().references(Rutinas, #id, onDelete: KeyAction.setNull)();
}

/// Tipo de serie. Afecta a las estadisticas: el calentamiento no suma volumen.
enum TipoSerie { normal, calentamiento, fallo }

/// Una serie concreta dentro de una sesion.
///
/// `ejercicioId` referencia el catalogo en assets, que no es una tabla. No hay
/// clave foranea a proposito: el catalogo es de solo lectura y versionado
/// aparte, y una FK obligaria a duplicar 1.324 filas en SQLite para nada.
@DataClassName('Serie')
class Series extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sesionId =>
      integer().references(Sesiones, #id, onDelete: KeyAction.cascade)();
  TextColumn get ejercicioId => text().withLength(min: 1, max: 16)();

  /// Orden dentro de la sesion; permite reordenar sin tocar los ids.
  IntColumn get orden => integer()();

  IntColumn get repeticiones => integer()();
  RealColumn get pesoKg => real().withDefault(const Constant(0))();
  BoolColumn get hecha => boolean().withDefault(const Constant(false))();
  IntColumn get tipo => intEnum<TipoSerie>().withDefault(const Constant(0))();

  /// Esfuerzo percibido 1-10, opcional.
  IntColumn get rpe => integer().nullable()();

  /// Descanso real tras la serie, en segundos (lo aporta el cronómetro). v2.
  IntColumn get descansoSeg => integer().nullable()();
}

/// Plantilla de rutina reutilizable.
class Rutinas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creada => dateTime()();
}

class RutinaEjercicios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rutinaId =>
      integer().references(Rutinas, #id, onDelete: KeyAction.cascade)();
  TextColumn get ejercicioId => text().withLength(min: 1, max: 16)();
  IntColumn get orden => integer()();
  IntColumn get seriesObjetivo => integer().withDefault(const Constant(3))();
  IntColumn get repsObjetivo => integer().withDefault(const Constant(10))();
}

/// Tipo de evento sobre la línea de tiempo metabólica.
enum TipoEvento { comida, ejercicio, estres, medicamento, suplemento }

extension TipoEventoVista on TipoEvento {
  String get etiqueta => switch (this) {
        TipoEvento.comida => 'Comida',
        TipoEvento.ejercicio => 'Ejercicio',
        TipoEvento.estres => 'Estrés',
        TipoEvento.medicamento => 'Medicamento',
        TipoEvento.suplemento => 'Suplemento',
      };
}

/// Eventos que marcan la línea de tiempo y se cruzan con la glucosa. Un solo
/// esquema con columnas opcionales por tipo, en vez de una tabla por tipo:
/// comparten momento y título, y solo difieren en unos pocos campos. v3.
@DataClassName('Evento')
class Eventos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get momento => dateTime()();
  IntColumn get tipo => intEnum<TipoEvento>()();

  /// Alimento, nombre del medicamento/suplemento, o descripción de la actividad.
  TextColumn get titulo => text().withLength(min: 1, max: 120)();
  TextColumn get detalle => text().nullable()(); // motivo del estrés, notas

  // --- Nutrición (comida). En Fase 3 los rellenará la estimación por foto. ---
  RealColumn get carbos => real().nullable()();
  RealColumn get proteina => real().nullable()();
  RealColumn get grasa => real().nullable()();
  RealColumn get fibra => real().nullable()();
  RealColumn get calorias => real().nullable()();

  /// Intensidad/nivel 1-10 (estrés, o intensidad de ejercicio).
  IntColumn get nivel => integer().nullable()();

  /// Dosis de medicamento o suplemento, como texto ("500 mg", "1 cápsula").
  TextColumn get dosis => text().nullable()();
}

/// Plan semanal: qué toca cada día. Siete filas fijas (lunes=1 … domingo=7),
/// editables. Es una plantilla ligera, no genera sesiones por sí sola. v2.
@DataClassName('DiaPlan')
class PlanSemanal extends Table {
  /// 1 = lunes … 7 = domingo (ISO, igual que DateTime.weekday).
  IntColumn get dia => integer()();
  TextColumn get titulo => text().withLength(max: 60)();

  /// Grupos musculares separados por coma ("Glúteos, Piernas"). Texto plano y
  /// no una tabla aparte: es una etiqueta editable, no una entidad con vida
  /// propia.
  TextColumn get grupos => text().withDefault(const Constant(''))();
  BoolColumn get descanso => boolean().withDefault(const Constant(false))();

  /// Rutina reutilizable asignada a este día, si la hay. Al borrar la rutina el
  /// día se queda sin ella (setNull), no se borra el día. v4.
  IntColumn get rutinaId =>
      integer().nullable().references(Rutinas, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {dia};
}

/// Registro de peso corporal, para cruzarlo con el progreso de fuerza.
@DataClassName('PesoCorporal')
class PesosCorporales extends Table {
  DateTimeColumn get dia => dateTime()();
  RealColumn get kg => real()();

  @override
  Set<Column> get primaryKey => {dia};
}

/// Volumen levantado en un dia (kg x repeticiones).
class VolumenDiario {
  const VolumenDiario({required this.dia, required this.volumen, required this.series});
  final DateTime dia;
  final double volumen;
  final int series;
}

/// Mejor marca historica de un ejercicio.
class MejorMarca {
  const MejorMarca({
    required this.ejercicioId,
    required this.pesoKg,
    required this.repeticiones,
    required this.fecha,
  });

  final String ejercicioId;
  final double pesoKg;
  final int repeticiones;
  final DateTime fecha;

  /// 1RM estimado por la formula de Epley. Es una estimacion, no una medicion:
  /// se desvia bastante por encima de ~10 repeticiones.
  double get unaRepMax => pesoKg * (1 + repeticiones / 30.0);
}

@DriftDatabase(
  tables: [
    Sesiones,
    Series,
    Rutinas,
    RutinaEjercicios,
    PlanSemanal,
    Eventos,
    PesosCorporales,
  ],
)
class BaseDatos extends _$BaseDatos {
  BaseDatos() : super(driftDatabase(name: 'appluisa'));

  /// Para tests: base en memoria.
  BaseDatos.conEjecutor(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // SQLite NO aplica claves foráneas si no se le pide expresamente. Sin
        // este PRAGMA, el `onDelete: cascade` de las series queda decorativo y
        // borrar una sesión deja sus series huérfanas en la base.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _sembrarPlan();
        },
        onUpgrade: (m, desde, hasta) async {
          // v1 -> v2: metadatos de sesión y serie, y el plan semanal.
          if (desde < 2) {
            await m.addColumn(sesiones, sesiones.lugar);
            await m.addColumn(sesiones, sesiones.animoAntes);
            await m.addColumn(sesiones, sesiones.energia);
            await m.addColumn(sesiones, sesiones.dolor);
            await m.addColumn(series, series.descansoSeg);
            await m.createTable(planSemanal);
            await _sembrarPlan();
          }
          // v2 -> v3: eventos de la línea de tiempo metabólica.
          if (desde < 3) {
            await m.createTable(eventos);
          }
          // v3 -> v4: rutina asignada a cada día del plan.
          if (desde < 4) {
            await m.addColumn(planSemanal, planSemanal.rutinaId);
          }
          // v4 -> v5: la sesión recuerda de qué rutina salió.
          if (desde < 5) {
            await m.addColumn(sesiones, sesiones.rutinaId);
          }
        },
      );

  /// Siembra el plan semanal con la rutina de partida. Se ejecuta una sola vez
  /// (al crear o al migrar); luego es editable y no se vuelve a tocar.
  Future<void> _sembrarPlan() async {
    const inicial = [
      (1, 'Glúteos + Piernas', 'Glúteos, Piernas', false),
      (2, 'Abdomen', 'Abdomen', false),
      (3, 'Glúteos + Piernas + Cuerda', 'Glúteos, Piernas, Cardio', false),
      (4, 'Descanso activo', '', true),
      (5, 'Glúteos + Piernas', 'Glúteos, Piernas', false),
      (6, 'Brazos + Hombros + Cuerda', 'Brazos, Hombros, Cardio', false),
      (7, 'Cardio / Caminata', 'Cardio', false),
    ];
    await batch((b) {
      b.insertAll(
        planSemanal,
        [
          for (final (dia, titulo, grupos, descanso) in inicial)
            PlanSemanalCompanion.insert(
              dia: Value(dia),
              titulo: titulo,
              grupos: Value(grupos),
              descanso: Value(descanso),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  // ------------------------------------------------------------- sesiones ---

  /// La sesion abierta, si la hay. Solo deberia existir una a la vez.
  Stream<Sesion?> verSesionEnCurso() {
    return (select(sesiones)
          ..where((s) => s.fin.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.inicio)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<Sesion>> verHistorial({int limite = 60}) {
    return (select(sesiones)
          ..where((s) => s.fin.isNotNull())
          ..orderBy([(s) => OrderingTerm.desc(s.inicio)])
          ..limit(limite))
        .watch();
  }

  Future<int> crearSesion(String nombre, {int? rutinaId}) =>
      into(sesiones).insert(
        SesionesCompanion.insert(
          nombre: nombre,
          inicio: DateTime.now(),
          rutinaId: Value(rutinaId),
        ),
      );

  /// Sesiones terminadas en un rango de fechas (para la semana / historial).
  Future<List<Sesion>> sesionesEntre(DateTime desde, DateTime hasta) {
    return (select(sesiones)
          ..where((s) =>
              s.fin.isNotNull() &
              s.inicio.isBiggerOrEqualValue(desde) &
              s.inicio.isSmallerThanValue(hasta))
          ..orderBy([(s) => OrderingTerm.desc(s.inicio)]))
        .get();
  }

  /// Ejercicios realmente entrenados (series marcadas como hechas) en un rango.
  /// Sirve para el balance de lo que de verdad hiciste, no lo planeado.
  Future<List<String>> ejerciciosHechosEntre(DateTime desde, DateTime hasta) async {
    final filas = await customSelect(
      '''
      SELECT DISTINCT se.ejercicio_id AS ejercicio
      FROM series se
      JOIN sesiones s ON s.id = se.sesion_id
      WHERE se.hecha = 1 AND s.inicio BETWEEN ? AND ?
      ''',
      variables: [Variable.withDateTime(desde), Variable.withDateTime(hasta)],
      readsFrom: {series, sesiones},
    ).get();
    return filas.map((f) => f.read<String>('ejercicio')).toList();
  }

  Future<void> terminarSesion(int id) => (update(sesiones)
        ..where((s) => s.id.equals(id)))
      .write(SesionesCompanion(fin: Value(DateTime.now())));

  Future<void> borrarSesion(int id) =>
      (delete(sesiones)..where((s) => s.id.equals(id))).go();

  /// Contexto previo: lugar, ánimo, energía y dolor. Cada campo es opcional; se
  /// escribe solo el que llega (los null se dejan como están).
  Future<void> actualizarContextoSesion(
    int id, {
    String? nombre,
    Object? lugar = _sinCambio,
    Animo? animo,
    int? energia,
    int? dolor,
    Object? notas = _sinCambio,
  }) {
    return (update(sesiones)..where((s) => s.id.equals(id))).write(
      SesionesCompanion(
        nombre: nombre == null ? const Value.absent() : Value(nombre),
        lugar: identical(lugar, _sinCambio)
            ? const Value.absent()
            : Value(lugar as String?),
        animoAntes: animo == null ? const Value.absent() : Value(animo),
        energia: energia == null ? const Value.absent() : Value(energia),
        dolor: dolor == null ? const Value.absent() : Value(dolor),
        notas: identical(notas, _sinCambio)
            ? const Value.absent()
            : Value(notas as String?),
      ),
    );
  }

  // ---------------------------------------------------------------- series ---

  Stream<List<Serie>> verSeries(int sesionId) {
    return (select(series)
          ..where((s) => s.sesionId.equals(sesionId))
          ..orderBy([(s) => OrderingTerm.asc(s.orden)]))
        .watch();
  }

  Future<int> anadirSerie({
    required int sesionId,
    required String ejercicioId,
    required int orden,
    int repeticiones = 10,
    double pesoKg = 0,
    TipoSerie tipo = TipoSerie.normal,
  }) {
    return into(series).insert(
      SeriesCompanion.insert(
        sesionId: sesionId,
        ejercicioId: ejercicioId,
        orden: orden,
        repeticiones: repeticiones,
        pesoKg: Value(pesoKg),
        tipo: Value(tipo),
      ),
    );
  }

  Future<void> actualizarSerie(
    int id, {
    int? repeticiones,
    double? pesoKg,
    bool? hecha,
    int? rpe,
    int? descansoSeg,
  }) {
    return (update(series)..where((s) => s.id.equals(id))).write(
      SeriesCompanion(
        repeticiones: repeticiones == null ? const Value.absent() : Value(repeticiones),
        pesoKg: pesoKg == null ? const Value.absent() : Value(pesoKg),
        hecha: hecha == null ? const Value.absent() : Value(hecha),
        rpe: rpe == null ? const Value.absent() : Value(rpe),
        descansoSeg:
            descansoSeg == null ? const Value.absent() : Value(descansoSeg),
      ),
    );
  }

  // ----------------------------------------------------------- plan semanal ---

  Stream<List<DiaPlan>> verPlanSemanal() {
    return (select(planSemanal)..orderBy([(p) => OrderingTerm.asc(p.dia)]))
        .watch();
  }

  Future<DiaPlan?> planDe(int dia) =>
      (select(planSemanal)..where((p) => p.dia.equals(dia))).getSingleOrNull();

  Future<void> guardarDiaPlan(
    int dia, {
    required String titulo,
    required String grupos,
    required bool descanso,
  }) {
    return into(planSemanal).insertOnConflictUpdate(
      PlanSemanalCompanion.insert(
        dia: Value(dia),
        titulo: titulo,
        grupos: Value(grupos),
        descanso: Value(descanso),
      ),
    );
  }

  /// Asigna (o quita, con null) la rutina de un día sin tocar sus otros campos.
  Future<void> asignarRutinaADia(int dia, int? rutinaId) {
    return (update(planSemanal)..where((p) => p.dia.equals(dia)))
        .write(PlanSemanalCompanion(rutinaId: Value(rutinaId)));
  }

  // -------------------------------------------------------------- rutinas ---

  Stream<List<Rutina>> verRutinas() {
    return (select(rutinas)..orderBy([(r) => OrderingTerm.asc(r.nombre)]))
        .watch();
  }

  Future<Rutina?> rutinaPorId(int id) =>
      (select(rutinas)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<int> crearRutina(String nombre, {String? notas}) {
    return into(rutinas).insert(
      RutinasCompanion.insert(
        nombre: nombre,
        creada: DateTime.now(),
        notas: Value(notas),
      ),
    );
  }

  Future<void> renombrarRutina(int id, String nombre, {String? notas}) {
    return (update(rutinas)..where((r) => r.id.equals(id))).write(
      RutinasCompanion(nombre: Value(nombre), notas: Value(notas)),
    );
  }

  Future<void> borrarRutina(int id) =>
      (delete(rutinas)..where((r) => r.id.equals(id))).go();

  /// Ejercicios de una rutina, en orden. `ejercicioId` referencia el catálogo
  /// en assets (no una tabla), igual que en las series.
  Stream<List<RutinaEjercicio>> verEjerciciosDeRutina(int rutinaId) {
    return (select(rutinaEjercicios)
          ..where((e) => e.rutinaId.equals(rutinaId))
          ..orderBy([(e) => OrderingTerm.asc(e.orden)]))
        .watch();
  }

  Future<List<RutinaEjercicio>> ejerciciosDeRutinaUnaVez(int rutinaId) {
    return (select(rutinaEjercicios)
          ..where((e) => e.rutinaId.equals(rutinaId))
          ..orderBy([(e) => OrderingTerm.asc(e.orden)]))
        .get();
  }

  Future<int> anadirEjercicioARutina({
    required int rutinaId,
    required String ejercicioId,
    required int orden,
    int seriesObjetivo = 3,
    int repsObjetivo = 10,
  }) {
    return into(rutinaEjercicios).insert(
      RutinaEjerciciosCompanion.insert(
        rutinaId: rutinaId,
        ejercicioId: ejercicioId,
        orden: orden,
        seriesObjetivo: Value(seriesObjetivo),
        repsObjetivo: Value(repsObjetivo),
      ),
    );
  }

  Future<void> actualizarEjercicioRutina(
    int id, {
    int? seriesObjetivo,
    int? repsObjetivo,
  }) {
    return (update(rutinaEjercicios)..where((e) => e.id.equals(id))).write(
      RutinaEjerciciosCompanion(
        seriesObjetivo:
            seriesObjetivo == null ? const Value.absent() : Value(seriesObjetivo),
        repsObjetivo:
            repsObjetivo == null ? const Value.absent() : Value(repsObjetivo),
      ),
    );
  }

  Future<void> quitarEjercicioRutina(int id) =>
      (delete(rutinaEjercicios)..where((e) => e.id.equals(id))).go();

  /// Reordena: escribe el nuevo `orden` de cada fila de una vez.
  Future<void> reordenarRutina(List<int> idsEnOrden) async {
    await batch((b) {
      for (var i = 0; i < idsEnOrden.length; i++) {
        b.update(
          rutinaEjercicios,
          RutinaEjerciciosCompanion(orden: Value(i)),
          where: (e) => e.id.equals(idsEnOrden[i]),
        );
      }
    });
  }

  Future<void> borrarSerie(int id) =>
      (delete(series)..where((s) => s.id.equals(id))).go();

  // ---------------------------------------------------------- estadisticas ---

  /// Volumen por dia en un rango. Solo cuenta series marcadas como hechas y
  /// descarta el calentamiento, que no representa carga de entrenamiento real.
  Future<List<VolumenDiario>> volumenPorDia({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final filas = await customSelect(
      '''
      SELECT date(s.inicio, 'unixepoch', 'localtime') AS dia,
             SUM(se.peso_kg * se.repeticiones)        AS volumen,
             COUNT(se.id)                             AS n_series
      FROM series se
      JOIN sesiones s ON s.id = se.sesion_id
      WHERE se.hecha = 1
        AND se.tipo != ?
        AND s.inicio BETWEEN ? AND ?
      GROUP BY dia
      ORDER BY dia
      ''',
      variables: [
        Variable.withInt(TipoSerie.calentamiento.index),
        Variable.withDateTime(desde),
        Variable.withDateTime(hasta),
      ],
      readsFrom: {series, sesiones},
    ).get();

    return filas.map((f) {
      return VolumenDiario(
        dia: DateTime.parse(f.read<String>('dia')),
        volumen: f.read<double?>('volumen') ?? 0,
        series: f.read<int>('n_series'),
      );
    }).toList();
  }

  /// Mejor marca por ejercicio: la serie de mas peso, desempatando por
  /// repeticiones.
  Future<List<MejorMarca>> mejoresMarcas() async {
    final filas = await customSelect(
      '''
      SELECT se.ejercicio_id                AS ejercicio,
             MAX(se.peso_kg)                AS peso,
             se.repeticiones                AS reps,
             s.inicio                       AS fecha
      FROM series se
      JOIN sesiones s ON s.id = se.sesion_id
      WHERE se.hecha = 1 AND se.peso_kg > 0
      GROUP BY se.ejercicio_id
      ORDER BY peso DESC
      ''',
      readsFrom: {series, sesiones},
    ).get();

    return filas.map((f) {
      return MejorMarca(
        ejercicioId: f.read<String>('ejercicio'),
        pesoKg: f.read<double>('peso'),
        repeticiones: f.read<int>('reps'),
        fecha: DateTime.fromMillisecondsSinceEpoch(f.read<int>('fecha') * 1000),
      );
    }).toList();
  }

  /// Series hechas por ejercicio, para repartir volumen por grupo muscular.
  /// El mapeo ejercicio -> musculo se resuelve en Dart contra el catalogo.
  Future<Map<String, double>> volumenPorEjercicio({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final filas = await customSelect(
      '''
      SELECT se.ejercicio_id                     AS ejercicio,
             SUM(se.peso_kg * se.repeticiones)   AS volumen
      FROM series se
      JOIN sesiones s ON s.id = se.sesion_id
      WHERE se.hecha = 1
        AND se.tipo != ?
        AND s.inicio BETWEEN ? AND ?
      GROUP BY se.ejercicio_id
      ''',
      variables: [
        Variable.withInt(TipoSerie.calentamiento.index),
        Variable.withDateTime(desde),
        Variable.withDateTime(hasta),
      ],
      readsFrom: {series, sesiones},
    ).get();

    return {
      for (final f in filas)
        f.read<String>('ejercicio'): f.read<double?>('volumen') ?? 0,
    };
  }

  // ---------------------------------------------------------------- eventos ---

  /// Eventos de un día, ordenados por hora. Ese es el corte natural para
  /// cruzarlos con la glucosa del mismo día.
  Stream<List<Evento>> verEventosDia(DateTime dia) {
    final ini = DateTime(dia.year, dia.month, dia.day);
    final fin = ini.add(const Duration(days: 1));
    return (select(eventos)
          ..where((e) => e.momento.isBiggerOrEqualValue(ini) &
              e.momento.isSmallerThanValue(fin))
          ..orderBy([(e) => OrderingTerm.asc(e.momento)]))
        .watch();
  }

  Future<int> anadirEvento(EventosCompanion evento) =>
      into(eventos).insert(evento);

  Future<void> borrarEvento(int id) =>
      (delete(eventos)..where((e) => e.id.equals(id))).go();

  // -------------------------------------------------------- peso corporal ---

  Stream<List<PesoCorporal>> verPesos() =>
      (select(pesosCorporales)..orderBy([(p) => OrderingTerm.asc(p.dia)])).watch();

  Future<void> registrarPeso(DateTime dia, double kg) {
    final d = DateTime(dia.year, dia.month, dia.day);
    return into(pesosCorporales).insertOnConflictUpdate(
      PesosCorporalesCompanion.insert(dia: d, kg: kg),
    );
  }
}
