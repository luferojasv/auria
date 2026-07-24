import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

/// Crea una rutina vacía y abre su editor. El nombre se pone dentro del editor.
Future<void> crearRutinaYEditar(BuildContext context, WidgetRef ref) async {
  final id = await ref.read(baseDatosProvider).crearRutina('Nueva rutina');
  if (context.mounted) context.push('/rutina/$id');
}

/// Abre una sesión nueva precargada con los ejercicios de una rutina, cada uno
/// con sus series objetivo (peso/reps se ajustan al entrenar). Si ya hay una
/// sesión en curso, no la pisa: devuelve esa.
Future<int> empezarSesionDesdeRutina(WidgetRef ref, int rutinaId) async {
  final db = ref.read(baseDatosProvider);

  final abierta = await db.verSesionEnCurso().first;
  if (abierta != null) return abierta.id;

  final rutina = await db.rutinaPorId(rutinaId);
  final sesionId = await db.crearSesion(rutina?.nombre ?? 'Entrenamiento');

  final ejercicios = await db.ejerciciosDeRutinaUnaVez(rutinaId);
  var orden = 0;
  for (final e in ejercicios) {
    // Una fila de serie por cada serie objetivo del ejercicio.
    for (var s = 0; s < e.seriesObjetivo; s++) {
      await db.anadirSerie(
        sesionId: sesionId,
        ejercicioId: e.ejercicioId,
        orden: orden++,
        repeticiones: e.repsObjetivo,
      );
    }
  }
  return sesionId;
}
