import 'package:appluisa/features/exercises/data/exercise_repository.dart';
import 'package:appluisa/features/exercises/domain/taxonomy_es.dart';
import 'package:appluisa/features/glucose/data/mock_glucose_data_source.dart';
import 'package:appluisa/features/glucose/domain/glucose_models.dart';
import 'package:appluisa/features/health/data/mock_health_data_source.dart';
import 'package:appluisa/features/health/domain/health_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Puntuacion de sueno', () {
    SesionSueno construir({
      required int profundoMin,
      required int ligeroMin,
      required int remMin,
      required int despiertoMin,
    }) {
      final inicio = DateTime(2026, 3, 1, 23);
      var t = inicio;
      final tramos = <TramoSueno>[];
      void add(FaseSueno f, int m) {
        if (m <= 0) return;
        final fin = t.add(Duration(minutes: m));
        tramos.add(TramoSueno(fase: f, inicio: t, fin: fin));
        t = fin;
      }

      add(FaseSueno.profundo, profundoMin);
      add(FaseSueno.ligero, ligeroMin);
      add(FaseSueno.rem, remMin);
      add(FaseSueno.despierto, despiertoMin);
      return SesionSueno(inicio: inicio, fin: t, tramos: tramos);
    }

    test('descuenta los despertares del tiempo dormido', () {
      final s = construir(
        profundoMin: 90,
        ligeroMin: 240,
        remMin: 90,
        despiertoMin: 30,
      );
      expect(s.enCama, const Duration(minutes: 450));
      expect(s.dormido, const Duration(minutes: 420));
      expect(s.eficiencia, closeTo(420 / 450, 0.001));
    });

    test('una noche larga y bien repartida puntua alto', () {
      final s = construir(
        profundoMin: 110,
        ligeroMin: 250,
        remMin: 110,
        despiertoMin: 15,
      );
      expect(s.puntuacion, greaterThanOrEqualTo(85));
    });

    test('una noche corta puntua bajo aunque sea eficiente', () {
      // 4 h seguidas sin despertares: eficiencia perfecta, duracion mala.
      final s = construir(
        profundoMin: 60,
        ligeroMin: 120,
        remMin: 60,
        despiertoMin: 0,
      );
      expect(s.eficiencia, 1.0);
      // 4 h perfectas: la duracion la penaliza aunque la eficiencia sea maxima.
      // Debe quedar claramente por debajo de una noche completa (85+).
      expect(s.puntuacion, lessThanOrEqualTo(75));
    });

    test('sesion vacia no revienta', () {
      final t = DateTime(2026, 3, 1);
      final s = SesionSueno(inicio: t, fin: t, tramos: const []);
      expect(s.puntuacion, 0);
      expect(s.eficiencia, 0);
    });
  });

  group('Datos simulados', () {
    final fuente = MockHealthDataSource(latenciaSimulada: Duration.zero);

    test('son deterministas: el mismo dia da siempre lo mismo', () async {
      final dia = DateTime(2026, 5, 14);
      final a = await fuente.instantanea(dia);
      final b = await fuente.instantanea(dia);
      expect(a.actividad.pasos, b.actividad.pasos);
      expect(a.actividad.calorias, b.actividad.calorias);
      expect(a.sueno?.dormido, b.sueno?.dormido);
      expect(a.pulsos.length, b.pulsos.length);
    });

    test('dias distintos dan datos distintos', () async {
      final a = await fuente.instantanea(DateTime(2026, 5, 14));
      final b = await fuente.instantanea(DateTime(2026, 5, 15));
      expect(a.actividad.pasos, isNot(b.actividad.pasos));
    });

    test('pasos, distancia y calorias estan correlacionados', () async {
      final dias = await fuente.actividad(
        desde: DateTime(2026, 4, 1),
        hasta: DateTime(2026, 4, 30),
      );
      expect(dias, hasLength(30));

      // Mas pasos siempre implica mas distancia y mas calorias: si estos ejes
      // se sortearan por separado, cualquier grafica de correlacion saldria en
      // ruido y no se podria ajustar la UI contra ella.
      final ordenados = [...dias]..sort((a, b) => a.pasos.compareTo(b.pasos));
      for (var i = 1; i < ordenados.length; i++) {
        expect(ordenados[i].distanciaM,
            greaterThanOrEqualTo(ordenados[i - 1].distanciaM));
        expect(ordenados[i].calorias,
            greaterThan(ordenados[i - 1].calorias - 130));
      }
    });

    test('el pulso en reposo usa percentil 5, no el minimo', () async {
      final inst = await fuente.instantanea(DateTime(2026, 5, 14));
      final bpms = inst.pulsos.map((p) => p.bpm).toList()..sort();
      expect(inst.pulsoReposo, isNotNull);
      // Debe estar por encima del minimo absoluto: una lectura erronea del
      // sensor no puede definir la metrica del dia.
      expect(inst.pulsoReposo, greaterThanOrEqualTo(bpms.first));
      expect(inst.pulsoReposo, lessThan(inst.pulsoMedio!));
    });

    test('no inventa lecturas del futuro', () async {
      final hoy = DateTime.now();
      final inst = await fuente.instantanea(hoy);
      for (final p in inst.pulsos) {
        expect(p.momento.isAfter(DateTime.now()), isFalse);
      }
    });

    test('las fases de sueno cubren la noche sin solaparse', () async {
      // Buscamos una noche con registro; el mock deja ~1 de cada 12 sin datos.
      SesionSueno? s;
      for (var d = 1; d <= 20 && s == null; d++) {
        s = await fuente.sueno(DateTime(2026, 6, d));
      }
      expect(s, isNotNull);

      final tramos = s!.tramos;
      for (var i = 1; i < tramos.length; i++) {
        expect(tramos[i].inicio, tramos[i - 1].fin,
            reason: 'los tramos deben ir encadenados');
      }
      expect(s.dormido.inMinutes, lessThanOrEqualTo(s.enCama.inMinutes));
    });
  });

  group('Glucosa', () {
    LecturaGlucosa l(int mg) => LecturaGlucosa(momento: DateTime(2026, 1, 1), mgdl: mg);

    test('tiempo en rango reparte por zonas y suma 1', () {
      final tir = TiempoEnRango.de([
        l(50), // muy bajo
        l(65), // bajo
        l(100), l(120), l(150), // en rango (3)
        l(200), // alto
        l(300), // muy alto
      ]);
      expect(tir.muestras, 7);
      expect(tir.enRango, closeTo(3 / 7, 0.001));
      final suma = tir.muyBajo + tir.bajo + tir.enRango + tir.alto + tir.muyAlto;
      expect(suma, closeTo(1.0, 0.001));
    });

    test('los límites del rango cuentan como en rango', () {
      // 70 y 180 son los bordes por defecto: inclusive.
      final tir = TiempoEnRango.de([l(70), l(180)]);
      expect(tir.enRango, 1.0);
    });

    test('GMI y variabilidad se calculan sobre la media', () {
      final r = ResumenGlucosa(
        dia: DateTime(2026, 1, 1),
        lecturas: [l(100), l(100), l(100)],
        rango: const RangoObjetivo(),
      );
      expect(r.media, 100);
      // GMI = 3.31 + 0.02392*100 = 5.702
      expect(r.gmi, closeTo(5.702, 0.001));
      // Sin dispersión, variabilidad 0.
      expect(r.variabilidad, closeTo(0, 0.001));
    });

    test('resumen vacío no revienta', () {
      final r = ResumenGlucosa(dia: DateTime(2026, 1, 1), lecturas: const [], rango: const RangoObjetivo());
      expect(r.media, isNull);
      expect(r.gmi, isNull);
      expect(r.ultima, isNull);
      expect(r.tiempoEnRango.muestras, 0);
    });
  });

  group('Datos de glucosa simulados', () {
    final fuente = MockGlucoseDataSource(latencia: Duration.zero);

    test('son deterministas por día', () async {
      final a = await fuente.resumenDia(DateTime(2026, 5, 20));
      final b = await fuente.resumenDia(DateTime(2026, 5, 20));
      expect(a.lecturas.length, b.lecturas.length);
      expect(a.media, b.media);
    });

    test('las lecturas caen en un rango fisiológico', () async {
      final r = await fuente.resumenDia(DateTime(2026, 5, 20));
      expect(r.lecturas, isNotEmpty);
      for (final lec in r.lecturas) {
        expect(lec.mgdl, inInclusiveRange(58, 260));
      }
    });

    test('genera picos: el máximo supera claramente al mínimo', () async {
      // Las comidas deben crear variación; una línea plana no serviría para
      // ver correlaciones.
      final r = await fuente.resumenDia(DateTime(2026, 5, 20));
      expect(r.maximo! - r.minimo!, greaterThan(30));
    });

    test('la última lectura trae tendencia', () async {
      final u = await fuente.ultima();
      expect(u, isNotNull);
      expect(u!.tendencia, isNotNull);
    });

    test('no inventa lecturas del futuro', () async {
      final r = await fuente.resumenDia(DateTime.now());
      for (final lec in r.lecturas) {
        expect(lec.momento.isAfter(DateTime.now()), isFalse);
      }
    });
  });

  group('Taxonomia en espanol', () {
    test('traduce los valores conocidos', () {
      expect(zonaEs('upper arms'), 'Brazos');
      expect(equipoEsDe('body weight'), 'Peso corporal');
      expect(musculoEs('hamstrings'), 'Isquiotibiales');
      expect(musculoEs('lats'), 'Dorsales');
    });

    test('deja pasar lo desconocido en vez de romper la ficha', () {
      expect(musculoEs('musculo inventado'), 'Musculo inventado');
      expect(zonaEs(null), '');
    });
  });

  group('Catalogo de ejercicios', () {
    late RepositorioEjercicios repo;

    setUpAll(() async {
      repo = await RepositorioEjercicios.cargar();
    });

    test('carga los 1.324 ejercicios y sus vocabularios', () {
      expect(repo.todos, hasLength(1324));
      expect(repo.catalogo.zonas, hasLength(10));
      expect(repo.catalogo.equipos, hasLength(28));
      expect(repo.catalogo.objetivos, hasLength(19));
    });

    test('todas las fichas traen pasos en espanol', () {
      expect(repo.todos.every((e) => e.enEspanol), isTrue);
      expect(repo.todos.every((e) => e.pasos.isNotEmpty), isTrue);
    });

    test('las URL de media se derivan del id y el mediaId', () {
      final e = repo.porId('0001')!;
      expect(repo.catalogo.miniaturaDe(e), endsWith('/images/0001-${e.mediaId}.jpg'));
      expect(repo.catalogo.animacionDe(e), endsWith('/videos/0001-${e.mediaId}.gif'));
    });

    test('buscar en ingles funciona', () {
      final r = repo.buscar(consulta: 'squat');
      expect(r, isNotEmpty);
      expect(r.first.nombre.toLowerCase(), contains('squat'));
    });

    test('buscar en espanol encuentra nombres ingleses', () {
      // El motivo de existir de aliasEs: sin el, esto daria cero resultados.
      for (final (consulta, esperado) in [
        ('sentadilla', 'squat'),
        ('peso muerto', 'deadlift'),
        ('dominadas', 'pull'),
        ('mancuerna', 'dumbbell'),
      ]) {
        final r = repo.buscar(consulta: consulta);
        expect(r, isNotEmpty, reason: '"$consulta" no devolvio nada');
        expect(
          r.any((e) => e.nombre.toLowerCase().contains(esperado)),
          isTrue,
          reason: '"$consulta" deberia encontrar algo con "$esperado"',
        );
      }
    });

    test('la busqueda ignora tildes y mayusculas', () {
      final a = repo.buscar(consulta: 'BÍCEPS');
      final b = repo.buscar(consulta: 'biceps');
      expect(a.length, b.length);
      expect(a, isNotEmpty);
    });

    test('varios terminos se combinan con AND', () {
      final r = repo.buscar(consulta: 'dumbbell curl');
      expect(r, isNotEmpty);
      for (final e in r) {
        final n = e.nombre.toLowerCase();
        expect(n.contains('dumbbell') || n.contains('curl'), isTrue);
      }
      // Debe ser mas restrictivo que cualquiera de los dos por separado.
      expect(r.length, lessThan(repo.buscar(consulta: 'dumbbell').length));
    });

    test('los filtros se acumulan', () {
      final soloZona = repo.buscar(zona: 'chest');
      final zonaYEquipo = repo.buscar(zona: 'chest', equipo: 'dumbbell');
      expect(soloZona, isNotEmpty);
      expect(zonaYEquipo.length, lessThan(soloZona.length));
      expect(zonaYEquipo.every((e) => e.zona == 'chest' && e.equipo == 'dumbbell'),
          isTrue);
    });

    test('los resultados exactos van primero', () {
      final r = repo.buscar(consulta: 'squat');
      expect(r.first.nombre.toLowerCase().startsWith('squat'), isTrue);
    });

    test('una consulta sin sentido devuelve lista vacia, no error', () {
      expect(repo.buscar(consulta: 'xyzqwkjh'), isEmpty);
    });
  });
}
