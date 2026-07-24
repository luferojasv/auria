import 'package:appluisa/data/db/database.dart';
// Solo `Value`: drift exporta también isNull/isNotNull, que chocan con los
// matchers homónimos de los tests.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas de la capa de datos contra una base **en memoria**: cada test
/// arranca con la base recién creada, así que el resultado no depende de lo
/// que haya quedado de ejecuciones anteriores.
void main() {
  late BaseDatos db;

  setUp(() {
    db = BaseDatos.conEjecutor(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('Plan semanal', () {
    test('se siembra con los 7 días al crear la base', () async {
      final plan = await db.verPlanSemanal().first;
      expect(plan, hasLength(7));
      expect(plan.map((d) => d.dia), [1, 2, 3, 4, 5, 6, 7]);
      // El lunes de la rutina de partida.
      expect(plan.first.titulo, contains('Glúteos'));
      // El jueves es descanso activo.
      expect(plan.firstWhere((d) => d.dia == 4).descanso, isTrue);
    });

    test('se puede editar un día sin tocar los demás', () async {
      await db.guardarDiaPlan(2, titulo: 'Core y movilidad', grupos: 'Abdomen', descanso: false);
      final plan = await db.verPlanSemanal().first;
      expect(plan.firstWhere((d) => d.dia == 2).titulo, 'Core y movilidad');
      // El resto intacto.
      expect(plan.firstWhere((d) => d.dia == 1).titulo, contains('Glúteos'));
      expect(plan, hasLength(7), reason: 'editar no debe duplicar filas');
    });
  });

  group('Eventos', () {
    Future<int> comida(DateTime cuando, {double? carbos}) => db.anadirEvento(
          EventosCompanion.insert(
            momento: cuando,
            tipo: TipoEvento.comida,
            titulo: 'Avena con fruta',
            carbos: Value(carbos),
          ),
        );

    test('se guardan y se leen por día', () async {
      final hoy = DateTime.now();
      await comida(DateTime(hoy.year, hoy.month, hoy.day, 8, 30), carbos: 45);
      await comida(DateTime(hoy.year, hoy.month, hoy.day, 13, 0), carbos: 60);

      final eventos = await db.verEventosDia(hoy).first;
      expect(eventos, hasLength(2));
      expect(eventos.first.carbos, 45);
      // Ordenados por hora.
      expect(eventos.first.momento.hour, lessThan(eventos.last.momento.hour));
    });

    test('el filtro por día no se lleva los de días vecinos', () async {
      final hoy = DateTime(2026, 6, 15);
      await comida(DateTime(2026, 6, 14, 23, 59)); // víspera
      await comida(DateTime(2026, 6, 15, 0, 1)); // justo dentro
      await comida(DateTime(2026, 6, 15, 23, 59)); // justo dentro
      await comida(DateTime(2026, 6, 16, 0, 1)); // día siguiente

      final eventos = await db.verEventosDia(hoy).first;
      expect(eventos, hasLength(2), reason: 'solo los dos del propio día');
    });

    test('cada tipo guarda sus campos propios', () async {
      final t = DateTime(2026, 6, 15, 10);
      await db.anadirEvento(EventosCompanion.insert(
        momento: t,
        tipo: TipoEvento.estres,
        titulo: 'Reunión',
        nivel: const Value(8),
        detalle: const Value('Entrega del proyecto'),
      ));
      await db.anadirEvento(EventosCompanion.insert(
        momento: t.add(const Duration(hours: 1)),
        tipo: TipoEvento.medicamento,
        titulo: 'Metformina',
        dosis: const Value('500 mg'),
      ));

      final eventos = await db.verEventosDia(t).first;
      final estres = eventos.firstWhere((e) => e.tipo == TipoEvento.estres);
      final med = eventos.firstWhere((e) => e.tipo == TipoEvento.medicamento);
      expect(estres.nivel, 8);
      expect(estres.detalle, 'Entrega del proyecto');
      expect(med.dosis, '500 mg');
      // Los campos de otro tipo quedan nulos, no en cero.
      expect(med.nivel, isNull);
      expect(estres.carbos, isNull);
    });

    test('se pueden borrar', () async {
      final t = DateTime(2026, 6, 15, 10);
      final id = await comida(t);
      expect(await db.verEventosDia(t).first, hasLength(1));
      await db.borrarEvento(id);
      expect(await db.verEventosDia(t).first, isEmpty);
    });
  });

  group('Sesiones y series', () {
    test('el flujo completo de una sesión', () async {
      final id = await db.crearSesion('Glúteos + Piernas');

      // En curso mientras no tenga fin.
      expect(await db.verSesionEnCurso().first, isNotNull);
      expect(await db.verHistorial().first, isEmpty);

      await db.anadirSerie(sesionId: id, ejercicioId: '0001', orden: 0, repeticiones: 12, pesoKg: 30);
      await db.anadirSerie(sesionId: id, ejercicioId: '0001', orden: 1, repeticiones: 10, pesoKg: 35);

      final series = await db.verSeries(id).first;
      expect(series, hasLength(2));

      // Marcar hecha, con RPE y descanso real.
      await db.actualizarSerie(series.first.id, hecha: true, rpe: 7, descansoSeg: 95);
      final tras = await db.verSeries(id).first;
      expect(tras.first.hecha, isTrue);
      expect(tras.first.rpe, 7);
      expect(tras.first.descansoSeg, 95);

      await db.terminarSesion(id);
      expect(await db.verSesionEnCurso().first, isNull);
      expect(await db.verHistorial().first, hasLength(1));
    });

    test('el contexto previo se guarda campo a campo', () async {
      final id = await db.crearSesion('Test');
      await db.actualizarContextoSesion(id,
          animo: Animo.bien, energia: 8, dolor: 3, lugar: 'Gimnasio');

      var s = await db.verSesionEnCurso().first;
      expect(s!.animoAntes, Animo.bien);
      expect(s.energia, 8);
      expect(s.dolor, 3);
      expect(s.lugar, 'Gimnasio');

      // Actualizar solo la energía no debe borrar lo demás.
      await db.actualizarContextoSesion(id, energia: 5);
      s = await db.verSesionEnCurso().first;
      expect(s!.energia, 5);
      expect(s.lugar, 'Gimnasio', reason: 'los campos no enviados se conservan');
      expect(s.animoAntes, Animo.bien);
    });

    test('borrar la sesión arrastra sus series (cascade)', () async {
      final id = await db.crearSesion('Test');
      await db.anadirSerie(sesionId: id, ejercicioId: '0001', orden: 0);
      await db.borrarSesion(id);
      expect(await db.verSeries(id).first, isEmpty);
    });
  });

  group('Estadísticas', () {
    test('el volumen ignora calentamiento y series sin marcar', () async {
      final id = await db.crearSesion('Test');
      // 10 reps x 50 kg = 500, cuenta.
      final a = await db.anadirSerie(
          sesionId: id, ejercicioId: '0001', orden: 0, repeticiones: 10, pesoKg: 50);
      // Calentamiento: no cuenta aunque esté hecha.
      final b = await db.anadirSerie(
          sesionId: id, ejercicioId: '0001', orden: 1, repeticiones: 20, pesoKg: 20,
          tipo: TipoSerie.calentamiento);
      // Sin marcar como hecha: no cuenta.
      await db.anadirSerie(
          sesionId: id, ejercicioId: '0001', orden: 2, repeticiones: 10, pesoKg: 100);

      await db.actualizarSerie(a, hecha: true);
      await db.actualizarSerie(b, hecha: true);

      final ayer = DateTime.now().subtract(const Duration(days: 1));
      final manana = DateTime.now().add(const Duration(days: 1));
      final volumen = await db.volumenPorDia(desde: ayer, hasta: manana);

      expect(volumen, hasLength(1));
      expect(volumen.first.volumen, 500, reason: 'solo la serie normal marcada');
    });

    test('la mejor marca calcula el 1RM de Epley', () async {
      final id = await db.crearSesion('Test');
      final s = await db.anadirSerie(
          sesionId: id, ejercicioId: '0007', orden: 0, repeticiones: 5, pesoKg: 60);
      await db.actualizarSerie(s, hecha: true);

      final marcas = await db.mejoresMarcas();
      expect(marcas, hasLength(1));
      expect(marcas.first.pesoKg, 60);
      // Epley: 60 * (1 + 5/30) = 70
      expect(marcas.first.unaRepMax, closeTo(70, 0.01));
    });
  });
}
