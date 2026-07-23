import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../exercises/domain/taxonomy_es.dart';

/// Ventana temporal de las estadisticas, en dias.
final rangoStatsProvider = NotifierProvider<RangoStats, int>(RangoStats.new);

class RangoStats extends Notifier<int> {
  @override
  int build() => 30;
  void set(int dias) => state = dias;
}

({DateTime desde, DateTime hasta}) _ventana(int dias) {
  final n = DateTime.now();
  final hasta = DateTime(n.year, n.month, n.day, 23, 59, 59);
  final desde = DateTime(n.year, n.month, n.day).subtract(Duration(days: dias - 1));
  return (desde: desde, hasta: hasta);
}

/// Volumen levantado por dia. Se rellenan los dias sin entrenar con cero para
/// que la grafica tenga una barra por dia y no comprima el eje temporal.
final volumenDiarioProvider = FutureProvider<List<VolumenDiario>>((ref) async {
  final db = ref.watch(baseDatosProvider);
  final dias = ref.watch(rangoStatsProvider);
  final v = _ventana(dias);

  final crudos = await db.volumenPorDia(desde: v.desde, hasta: v.hasta);
  final porDia = {for (final f in crudos) DateTime(f.dia.year, f.dia.month, f.dia.day): f};

  return List.generate(dias, (i) {
    final d = DateTime(v.desde.year, v.desde.month, v.desde.day)
        .add(Duration(days: i));
    return porDia[d] ?? VolumenDiario(dia: d, volumen: 0, series: 0);
  });
});

/// Reparto de volumen por grupo muscular.
///
/// El join no se hace en SQL: la tabla `series` guarda el id del ejercicio y el
/// mapa ejercicio -> musculo vive en el catalogo de assets, no en la base. Se
/// resuelve aqui en Dart, que ademas permite traducir la etiqueta de una vez.
final volumenPorMusculoProvider =
    FutureProvider<List<({String musculo, double volumen})>>((ref) async {
  final db = ref.watch(baseDatosProvider);
  final dias = ref.watch(rangoStatsProvider);
  final repo = await ref.watch(repositorioEjerciciosProvider.future);
  final v = _ventana(dias);

  final porEjercicio = await db.volumenPorEjercicio(desde: v.desde, hasta: v.hasta);

  final acumulado = <String, double>{};
  for (final e in porEjercicio.entries) {
    final ej = repo.porId(e.key);
    if (ej == null) continue;
    // Agrupamos por musculo objetivo, no por `muscle_group`: el objetivo tiene
    // 19 valores frente a 29 y produce un reparto mas legible.
    final etiqueta = musculoEs(ej.objetivo);
    acumulado[etiqueta] = (acumulado[etiqueta] ?? 0) + e.value;
  }

  final lista = acumulado.entries
      .map((e) => (musculo: e.key, volumen: e.value))
      .toList()
    ..sort((a, b) => b.volumen.compareTo(a.volumen));
  return lista;
});

/// Mejores marcas, con el nombre del ejercicio ya resuelto.
final mejoresMarcasProvider =
    FutureProvider<List<({MejorMarca marca, String nombre})>>((ref) async {
  final db = ref.watch(baseDatosProvider);
  final repo = await ref.watch(repositorioEjerciciosProvider.future);
  final marcas = await db.mejoresMarcas();

  return marcas
      .map((m) => (marca: m, nombre: repo.porId(m.ejercicioId)?.nombre ?? m.ejercicioId))
      .toList();
});
