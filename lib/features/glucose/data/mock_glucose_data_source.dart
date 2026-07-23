import 'dart:math';

import '../domain/glucose_data_source.dart';
import '../domain/glucose_models.dart';

/// Glucosa sintética pero fisiológicamente plausible.
///
/// Reproduce los rasgos que una CGM real muestra y que hacen falta para probar
/// la gráfica y, más adelante, las correlaciones:
///  - **Basal** en ayunas ~95 mg/dL.
///  - **Fenómeno del alba**: subida entre las 4:00 y las 7:00.
///  - **Picos postprandiales** tras desayuno, almuerzo y cena: la glucosa sube,
///    hace pico ~50 min después y vuelve a basal en 2-3 h. La magnitud del pico
///    depende del día (semilla), así unos días quedan más en rango que otros.
///  - **Ejercicio matutino** que empuja la glucosa hacia abajo.
///  - **Ruido** del sensor.
///
/// Determinista por día (misma semilla → mismo trazado), para que la gráfica no
/// baile en cada hot reload.
class MockGlucoseDataSource implements FuenteGlucosa {
  MockGlucoseDataSource({this.latencia = const Duration(milliseconds: 260)});

  final Duration latencia;
  EstadoGlucosa _estado = EstadoGlucosa.conectada;

  @override
  String get nombre => 'Glucosa de demostración';

  @override
  Future<EstadoGlucosa> estado() async => _estado;

  @override
  Future<EstadoGlucosa> vincular({String? usuario, String? clave}) async {
    await Future<void>.delayed(latencia);
    return _estado = EstadoGlucosa.conectada;
  }

  @override
  Future<void> desvincular() async => _estado = EstadoGlucosa.sinVincular;

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

  Random _rng(DateTime d, [int sal = 0]) {
    final dias = _dia(d).millisecondsSinceEpoch ~/ 86400000;
    return Random(dias * 1000003 + sal * 97);
  }

  double _entre(Random r, double a, double b) => a + r.nextDouble() * (b - a);

  /// Comidas del día (hora decimal, subida en mg/dL, ancho en horas).
  List<(double, double, double)> _comidas(DateTime dia) {
    final r = _rng(dia, 7);
    return [
      (_entre(r, 7.0, 8.5), _entre(r, 45, 85), _entre(r, 1.6, 2.4)), // desayuno
      (_entre(r, 12.5, 14.0), _entre(r, 55, 95), _entre(r, 1.8, 2.8)), // almuerzo
      (_entre(r, 19.5, 21.0), _entre(r, 40, 80), _entre(r, 1.8, 2.6)), // cena
      // Picoteo de tarde ocasional.
      if (r.nextDouble() < 0.45)
        (_entre(r, 16.0, 17.5), _entre(r, 20, 45), _entre(r, 1.0, 1.6)),
    ];
  }

  /// Valor de glucosa a una hora decimal [h] del día.
  double _valor(DateTime dia, double h, List<(double, double, double)> comidas,
      Random ruido) {
    final r = _rng(dia, 3);
    final basal = _entre(r, 88, 104);

    // Fenómeno del alba: campana centrada ~5:30.
    final alba = 18 * exp(-pow(h - 5.5, 2) / 3.0);

    // Aportes postprandiales: cada comida es una curva asimétrica (sube rápido,
    // baja lento) que arranca en su hora.
    var comida = 0.0;
    for (final (inicio, subida, ancho) in comidas) {
      if (h < inicio) continue;
      final t = h - inicio;
      // Sube hasta ~0.8 h y luego decae.
      final forma = (t / 0.8) * exp(1 - t / 0.8) * exp(-t / (ancho * 1.4));
      comida += subida * forma.clamp(0.0, 1.5);
    }

    // Ejercicio matutino (~7:30-8:30 los días de entreno): baja la glucosa.
    final finde = dia.weekday >= DateTime.saturday;
    final baja = !finde && h > 7.4 && h < 9.0 ? -12 * sin((h - 7.4) / 1.6 * pi) : 0.0;

    final ruidoV = _entre(ruido, -4, 4);
    return (basal + alba + comida + baja + ruidoV).clamp(58, 260);
  }

  List<LecturaGlucosa> _serie(DateTime dia, {bool hastaAhora = false}) {
    final comidas = _comidas(dia);
    final ruido = _rng(dia, 9);
    final base = _dia(dia);
    final ahora = DateTime.now();

    final out = <LecturaGlucosa>[];
    // Cada 5 minutos, como una CGM en tiempo real.
    for (var m = 0; m < 24 * 60; m += 5) {
      final momento = base.add(Duration(minutes: m));
      if (hastaAhora && momento.isAfter(ahora)) break;
      final h = m / 60.0;
      out.add(LecturaGlucosa(momento: momento, mgdl: _valor(dia, h, comidas, ruido).round()));
    }

    // Tendencia de la última: pendiente de los últimos ~15 min.
    if (out.length >= 4) {
      final ult = out.last.mgdl;
      final antes = out[out.length - 4].mgdl; // 15 min atrás
      final delta = ult - antes;
      final t = delta > 25
          ? Tendencia.subiendoRapido
          : delta > 8
              ? Tendencia.subiendo
              : delta < -25
                  ? Tendencia.bajandoRapido
                  : delta < -8
                      ? Tendencia.bajando
                      : Tendencia.estable;
      out[out.length - 1] = LecturaGlucosa(
        momento: out.last.momento,
        mgdl: out.last.mgdl,
        tendencia: t,
      );
    }
    return out;
  }

  @override
  Future<List<LecturaGlucosa>> lecturas({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    await Future<void>.delayed(latencia);
    final out = <LecturaGlucosa>[];
    var cursor = _dia(desde);
    final fin = _dia(hasta);
    final hoy = _dia(DateTime.now());
    while (!cursor.isAfter(fin)) {
      out.addAll(_serie(cursor, hastaAhora: cursor == hoy));
      cursor = cursor.add(const Duration(days: 1));
    }
    return out.where((l) => !l.momento.isBefore(desde) && !l.momento.isAfter(hasta)).toList();
  }

  @override
  Future<LecturaGlucosa?> ultima() async {
    await Future<void>.delayed(latencia);
    final hoy = _serie(DateTime.now(), hastaAhora: true);
    return hoy.isEmpty ? null : hoy.last;
  }

  @override
  Future<ResumenGlucosa> resumenDia(DateTime dia) async {
    await Future<void>.delayed(latencia);
    final hoy = _dia(DateTime.now());
    return ResumenGlucosa(
      dia: _dia(dia),
      lecturas: _serie(dia, hastaAhora: _dia(dia) == hoy),
      rango: const RangoObjetivo(),
    );
  }
}
