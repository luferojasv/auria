import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'correlation_engine.dart';

/// Nº de días hacia atrás que analiza el motor. Cuantos más, más fiable la
/// correlación; menos de ~2 semanas da poco.
const _dias = 30;

DateTime _medianoche(DateTime d) => DateTime(d.year, d.month, d.day);

/// Reúne las variables diarias de todas las fuentes (salud, glucosa,
/// entrenamiento) para los últimos [_dias] días. Cada fuente aporta lo que
/// tenga; los días sin dato simplemente no entran en esa variable.
///
/// Nota: con el proveedor de demostración hay dato de todo cada día. Con datos
/// reales, la glucosa histórica depende de que se haya ido acumulando (ver
/// Fase 4), y el sueño/actividad de que Huawei esté conectado.
final variablesDiariasProvider = FutureProvider<List<VariableDiaria>>((ref) async {
  final salud = ref.watch(fuenteSaludProvider);
  final glucosa = ref.watch(fuenteGlucosaProvider);
  final db = ref.watch(baseDatosProvider);
  ref.watch(historialProvider); // recalcular al registrar entrenamientos

  final hoy = _medianoche(DateTime.now());
  final desde = hoy.subtract(const Duration(days: _dias - 1));
  final dias = [for (var i = 0; i < _dias; i++) desde.add(Duration(days: i))];

  // --- Actividad: una sola llamada para todo el rango ---
  final actividad = await salud.actividad(desde: desde, hasta: hoy);
  final pasos = <DateTime, double>{};
  final minutos = <DateTime, double>{};
  final calorias = <DateTime, double>{};
  for (final a in actividad) {
    final d = _medianoche(a.dia);
    pasos[d] = a.pasos.toDouble();
    minutos[d] = a.minutosActivos.toDouble();
    calorias[d] = a.calorias.toDouble();
  }

  // --- Sueño y glucosa por día (en paralelo) ---
  final suenos = await Future.wait(dias.map(salud.sueno));
  final glucosas = await Future.wait(dias.map(glucosa.resumenDia));

  final horasSueno = <DateTime, double>{};
  final calidadSueno = <DateTime, double>{};
  for (var i = 0; i < dias.length; i++) {
    final s = suenos[i];
    if (s != null) {
      horasSueno[dias[i]] = s.dormido.inMinutes / 60.0;
      calidadSueno[dias[i]] = s.puntuacion.toDouble();
    }
  }

  final glucosaMedia = <DateTime, double>{};
  final tiempoEnRango = <DateTime, double>{};
  for (var i = 0; i < dias.length; i++) {
    final g = glucosas[i];
    if (g.media != null) glucosaMedia[dias[i]] = g.media!.toDouble();
    if (g.lecturas.isNotEmpty) {
      tiempoEnRango[dias[i]] = g.tiempoEnRango.enRango * 100;
    }
  }

  // --- Volumen de entrenamiento ---
  final vol = await db.volumenPorDia(desde: desde, hasta: hoy.add(const Duration(days: 1)));
  final volumen = {for (final v in vol) _medianoche(v.dia): v.volumen};

  // Solo las variables con al menos algún dato.
  final todas = <VariableDiaria>[
    VariableDiaria(id: 'sueno', nombre: 'Sueño', valores: horasSueno, subirEsMejor: true),
    VariableDiaria(id: 'calidad', nombre: 'Calidad del sueño', valores: calidadSueno, subirEsMejor: true),
    VariableDiaria(id: 'pasos', nombre: 'Pasos', valores: pasos, subirEsMejor: true),
    VariableDiaria(id: 'minutos', nombre: 'Minutos activos', valores: minutos, subirEsMejor: true),
    VariableDiaria(id: 'calorias', nombre: 'Calorías', valores: calorias),
    VariableDiaria(id: 'glucosa', nombre: 'Glucosa media', valores: glucosaMedia, subirEsMejor: false),
    VariableDiaria(id: 'tir', nombre: 'Tiempo en rango', valores: tiempoEnRango, subirEsMejor: true),
    VariableDiaria(id: 'volumen', nombre: 'Volumen de entreno', valores: volumen, subirEsMejor: true),
  ];
  return todas.where((v) => v.valores.length >= 3).toList();
});

/// Los patrones detectados entre las variables.
final hallazgosProvider = FutureProvider<List<Hallazgo>>((ref) async {
  final vars = await ref.watch(variablesDiariasProvider.future);
  return correlacionar(vars);
});
