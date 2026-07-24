import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'muscle_map.dart';

/// Grupos musculares grandes que una rutina equilibrada debería cubrir. Se usan
/// para detectar los que faltan. Deja fuera los muy secundarios (serrato,
/// aductores…) para no marcar como "hueco" algo menor.
const musculosPrincipales = <String>{
  'chest', 'abs', 'obliques', 'biceps', 'triceps', 'deltoids', 'trapezius',
  'forearm', 'upper-back', 'lower-back', 'gluteal', 'quadriceps', 'hamstring',
  'calves',
};

typedef Cobertura = ({Set<String> primarios, Set<String> secundarios});

/// Cobertura muscular de TODAS las rutinas juntas. Reactivo: al cambiar
/// cualquier rutina o sus ejercicios, se recalcula, porque observa cada
/// `ejerciciosDeRutinaProvider`.
final coberturaMuscularProvider = Provider<Cobertura>((ref) {
  final rutinas = ref.watch(rutinasProvider).value ?? const [];
  final repo = ref.watch(repositorioEjerciciosProvider).value;

  final primarios = <String>{};
  final secundarios = <String>{};
  if (repo == null) return (primarios: primarios, secundarios: secundarios);

  for (final r in rutinas) {
    final ejs = ref.watch(ejerciciosDeRutinaProvider(r.id)).value ?? const [];
    for (final it in ejs) {
      final e = repo.porId(it.ejercicioId);
      if (e == null) continue;
      final p = slugDeMusculo(e.objetivo);
      if (p != null) primarios.add(p);
      final g = slugDeMusculo(e.grupo);
      if (g != null) secundarios.add(g);
      for (final s in e.secundarios) {
        final ss = slugDeMusculo(s);
        if (ss != null) secundarios.add(ss);
      }
    }
  }
  return (primarios: primarios, secundarios: secundarios);
});

/// Músculos principales que ninguna rutina trabaja (ni como principal ni
/// secundario) — los "huecos" de tu entrenamiento.
final musculosQueFaltanProvider = Provider<Set<String>>((ref) {
  final c = ref.watch(coberturaMuscularProvider);
  final cubiertos = {...c.primarios, ...c.secundarios};
  return musculosPrincipales.difference(cubiertos);
});

/// Cobertura de lo REALMENTE entrenado en los últimos 30 días (según las series
/// hechas), no lo planeado. Permite comparar planeado vs hecho.
final balanceRealProvider = FutureProvider<Cobertura>((ref) async {
  ref.watch(historialProvider); // recalcular al registrar una sesión
  final db = ref.watch(baseDatosProvider);
  final repo = await ref.watch(repositorioEjerciciosProvider.future);
  final ahora = DateTime.now();
  final ids = await db.ejerciciosHechosEntre(
    ahora.subtract(const Duration(days: 30)),
    ahora,
  );

  final primarios = <String>{};
  final secundarios = <String>{};
  for (final id in ids) {
    final e = repo.porId(id);
    if (e == null) continue;
    final p = slugDeMusculo(e.objetivo);
    if (p != null) primarios.add(p);
    final g = slugDeMusculo(e.grupo);
    if (g != null) secundarios.add(g);
    for (final s in e.secundarios) {
      final ss = slugDeMusculo(s);
      if (ss != null) secundarios.add(ss);
    }
  }
  return (primarios: primarios, secundarios: secundarios);
});
