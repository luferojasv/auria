import 'dart:math';

import '../domain/health_data_source.dart';
import '../domain/health_models.dart';

/// Adaptador de datos sinteticos.
///
/// Genera biometria plausible para desarrollar la app sin depender de la
/// aprobacion de Health Kit. Dos propiedades que importan:
///
///  - **Determinista**: la semilla sale del numero de dia, asi que el 3 de
///    marzo siempre da los mismos datos. Sin esto, cada hot reload redibujaria
///    las graficas con otros valores y seria imposible ajustar la UI.
///  - **Correlacionado**: pasos, calorias y pulso no se sortean por separado.
///    Un dia de muchos pasos trae mas calorias y mas minutos activos, y el
///    domingo se duerme mas. Si los ejes fueran independientes, cualquier
///    grafica de correlacion saldria en ruido y no se veria si funciona.
class MockHealthDataSource implements FuenteDatosSalud {
  MockHealthDataSource({this.latenciaSimulada = const Duration(milliseconds: 240)});

  /// Latencia artificial: obliga a que la UI tenga estados de carga de verdad.
  final Duration latenciaSimulada;

  EstadoSalud _estado = EstadoSalud.conectada;

  @override
  String get nombre => 'Datos de demostración';

  @override
  Future<EstadoSalud> estado() async => _estado;

  @override
  Future<EstadoSalud> vincular() async {
    await Future<void>.delayed(latenciaSimulada);
    return _estado = EstadoSalud.conectada;
  }

  @override
  Future<void> desvincular() async {
    _estado = EstadoSalud.sinVincular;
  }

  // --------------------------------------------------------------- semilla ---

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Semilla estable por dia. El desplazamiento evita que dias contiguos den
  /// secuencias parecidas (Random de Dart correlaciona con semillas vecinas).
  Random _rng(DateTime d, [int sal = 0]) {
    final diasEpoch = _dia(d).millisecondsSinceEpoch ~/ 86400000;
    return Random(diasEpoch * 2654435761 + sal * 40503);
  }

  double _entre(Random r, double min, double max) => min + r.nextDouble() * (max - min);

  // -------------------------------------------------------------- actividad ---

  ResumenActividad _actividadDe(DateTime d) {
    final r = _rng(d, 1);
    final finde = d.weekday >= DateTime.saturday;

    // Base semanal, con el domingo mas bajo y el sabado mas disperso.
    final base = finde ? _entre(r, 4200, 15000) : _entre(r, 6800, 12500);
    // Tendencia suave a lo largo del mes, para que las graficas no sean planas.
    final tendencia = 1 + 0.12 * sin(d.day / 31 * 2 * pi);
    final pasos = (base * tendencia).round();

    // Zancada ~0.72 m; los pasos ya llevan el ruido, no hace falta mas aqui.
    final distancia = (pasos * 0.72).round();

    // Metabolismo basal aproximado + gasto por paso.
    final calorias = (1450 + pasos * 0.042 + _entre(r, -60, 60)).round();

    // Los minutos activos escalan con los pasos pero no linealmente: caminar
    // mucho a ritmo bajo no cuenta igual.
    final minutos = (pasos / 190 + _entre(r, -6, 10)).round().clamp(0, 400);

    return ResumenActividad(
      dia: _dia(d),
      pasos: pasos,
      distanciaM: distancia,
      calorias: calorias,
      minutosActivos: minutos,
    );
  }

  @override
  Future<List<ResumenActividad>> actividad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future<void>.delayed(latenciaSimulada);
    final salida = <ResumenActividad>[];
    var cursor = _dia(desde);
    final fin = _dia(hasta);
    while (!cursor.isAfter(fin)) {
      salida.add(_actividadDe(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return salida;
  }

  // ------------------------------------------------------------------ sueno ---

  /// Construye la noche por ciclos de ~90 min: ligero -> profundo -> ligero ->
  /// REM, con el profundo concentrado al principio y el REM al final, que es
  /// como se reparte de verdad.
  SesionSueno? _suenoDe(DateTime dia) {
    final r = _rng(dia, 2);

    // Una noche de cada doce sin registro: el reloj se queda cargando.
    if (r.nextDouble() < 0.08) return null;

    final finde = dia.weekday == DateTime.sunday || dia.weekday == DateTime.saturday;

    // Se acuesta la noche anterior.
    final anoche = _dia(dia).subtract(const Duration(days: 1));
    final horaAcostarse = finde ? _entre(r, 23.4, 25.6) : _entre(r, 22.7, 24.4);
    final inicio = anoche.add(
      Duration(minutes: (horaAcostarse * 60).round()),
    );

    final horasEnCama = finde ? _entre(r, 7.2, 9.4) : _entre(r, 6.1, 8.3);
    final fin = inicio.add(Duration(minutes: (horasEnCama * 60).round()));

    final tramos = <TramoSueno>[];
    var t = inicio;
    var ciclo = 0;

    while (t.isBefore(fin)) {
      final restante = fin.difference(t);
      if (restante.inMinutes < 8) break;

      // El profundo domina los dos primeros ciclos y casi desaparece al final.
      final pesoProfundo = (1.0 - ciclo * 0.28).clamp(0.08, 1.0);
      final pesoRem = (0.35 + ciclo * 0.22).clamp(0.0, 1.0);

      final plan = <(FaseSueno, double)>[
        (FaseSueno.ligero, _entre(r, 18, 32)),
        (FaseSueno.profundo, _entre(r, 14, 30) * pesoProfundo),
        (FaseSueno.ligero, _entre(r, 10, 22)),
        (FaseSueno.rem, _entre(r, 12, 26) * pesoRem),
      ];

      for (final (fase, mins) in plan) {
        if (mins < 3) continue;
        final dur = Duration(minutes: mins.round());
        final hasta = t.add(dur);
        if (hasta.isAfter(fin)) {
          if (fin.difference(t).inMinutes >= 3) {
            tramos.add(TramoSueno(fase: fase, inicio: t, fin: fin));
          }
          t = fin;
          break;
        }
        tramos.add(TramoSueno(fase: fase, inicio: t, fin: hasta));
        t = hasta;
      }

      // Despertar breve entre ciclos, cada vez mas probable hacia el amanecer.
      if (t.isBefore(fin) && r.nextDouble() < 0.30 + ciclo * 0.12) {
        final dur = Duration(minutes: _entre(r, 3, 13).round());
        final hasta = t.add(dur);
        if (hasta.isBefore(fin)) {
          tramos.add(TramoSueno(fase: FaseSueno.despierto, inicio: t, fin: hasta));
          t = hasta;
        }
      }
      ciclo++;
    }

    if (tramos.isEmpty) return null;
    return SesionSueno(inicio: inicio, fin: fin, tramos: tramos);
  }

  @override
  Future<SesionSueno?> sueno(DateTime dia) async {
    await Future<void>.delayed(latenciaSimulada);
    return _suenoDe(dia);
  }

  // ------------------------------------------------------------------ pulso ---

  /// Muestrea cada 10 minutos. El ritmo sigue una curva circadiana: minimo de
  /// madrugada, meseta diurna, y picos donde el dia tuvo actividad.
  List<MuestraPulso> _pulsosDe(DateTime dia) {
    final r = _rng(dia, 3);
    final act = _actividadDe(dia);

    // Mas actividad sostenida en el tiempo -> reposo algo mas bajo.
    final reposo = (60 - (act.pasos - 8000) / 1400).clamp(48.0, 68.0);

    final salida = <MuestraPulso>[];
    final base = _dia(dia);

    // Hasta dos bloques de ejercicio, situados en horas verosimiles.
    final nBloques = act.minutosActivos > 55 ? 2 : (act.minutosActivos > 25 ? 1 : 0);
    final bloques = <(double, double, double)>[]; // inicio h, duracion h, pico
    for (var i = 0; i < nBloques; i++) {
      final h = i == 0 ? _entre(r, 6.5, 9.0) : _entre(r, 17.5, 20.5);
      bloques.add((h, _entre(r, 0.5, 1.3), _entre(r, 128, 168)));
    }

    for (var m = 0; m < 24 * 60; m += 10) {
      final h = m / 60.0;
      final momento = base.add(Duration(minutes: m));
      if (momento.isAfter(DateTime.now())) break; // no inventamos el futuro

      // Curva circadiana: minimo hacia las 4:00.
      final circadiano = -6.5 * cos((h - 4) / 24 * 2 * pi);
      var bpm = reposo + 6 + circadiano;

      // Sueno: por debajo del reposo diurno.
      if (h < 6.5) bpm -= 4;

      for (final (ini, dur, pico) in bloques) {
        if (h >= ini && h <= ini + dur) {
          // Campana dentro del bloque: sube, mantiene y baja.
          final p = (h - ini) / dur;
          bpm += (pico - bpm) * sin(p * pi);
        } else if (h > ini + dur && h < ini + dur + 0.5) {
          // Recuperacion posterior, decayendo.
          bpm += 16 * (1 - (h - ini - dur) / 0.5);
        }
      }

      bpm += _entre(r, -3.5, 3.5);
      salida.add(MuestraPulso(momento: momento, bpm: bpm.round().clamp(42, 190)));
    }
    return salida;
  }

  @override
  Future<List<MuestraPulso>> pulsos({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future<void>.delayed(latenciaSimulada);
    final salida = <MuestraPulso>[];
    var cursor = _dia(desde);
    final fin = _dia(hasta);
    while (!cursor.isAfter(fin)) {
      salida.addAll(_pulsosDe(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return salida;
  }

  // --------------------------------------------------------------- sesiones ---

  static const _tipos = [
    'Fuerza',
    'Carrera',
    'Caminata',
    'Bicicleta',
    'Elíptica',
    'Natación',
  ];

  List<SesionRegistrada> _sesionesDe(DateTime dia) {
    final r = _rng(dia, 4);
    final act = _actividadDe(dia);
    if (act.minutosActivos < 25) return const [];

    final n = act.minutosActivos > 70 ? 2 : 1;
    return List.generate(n, (i) {
      final mins = _entre(r, 26, 82).round();
      final tipo = _tipos[r.nextInt(_tipos.length)];
      return SesionRegistrada(
        inicio: _dia(dia).add(
          Duration(minutes: ((i == 0 ? _entre(r, 7, 10) : _entre(r, 18, 20.5)) * 60).round()),
        ),
        duracion: Duration(minutes: mins),
        tipo: tipo,
        calorias: (mins * _entre(r, 6.5, 11.5)).round(),
        pulsoMedio: _entre(r, 112, 152).round(),
      );
    });
  }

  @override
  Future<List<SesionRegistrada>> sesiones({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future<void>.delayed(latenciaSimulada);
    final salida = <SesionRegistrada>[];
    var cursor = _dia(desde);
    final fin = _dia(hasta);
    while (!cursor.isAfter(fin)) {
      salida.addAll(_sesionesDe(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return salida;
  }

  // ------------------------------------------------------------ instantanea ---

  @override
  Future<InstantaneaDiaria> instantanea(DateTime dia) async {
    await Future<void>.delayed(latenciaSimulada);
    return InstantaneaDiaria(
      dia: _dia(dia),
      actividad: _actividadDe(dia),
      sueno: _suenoDe(dia),
      pulsos: _pulsosDe(dia),
      sesiones: _sesionesDe(dia),
    );
  }
}
