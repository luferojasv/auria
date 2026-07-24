import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import 'routine_actions.dart';

/// Acciones sobre sesiones de entrenamiento compartidas entre pantallas.
///
/// Viven aparte porque se disparan desde sitios muy distintos: la ficha de un
/// ejercicio, la lista de entrenamientos y la propia sesion en curso.

/// Nombre por defecto segun la hora, para no obligar a teclear al empezar.
String nombrePorDefecto([DateTime? cuando]) {
  final t = cuando ?? DateTime.now();
  final momento = t.hour < 12
      ? 'Mañana'
      : t.hour < 19
          ? 'Tarde'
          : 'Noche';
  return 'Entreno · $momento ${DateFormat('d MMM', 'es').format(t)}';
}

/// Devuelve la sesion abierta, creandola si no existe. Prioridad:
/// 1) sesion ya en curso, 2) rutina asignada al dia (precarga sus ejercicios),
/// 3) sesion vacia con el titulo del plan, 4) nombre por hora.
Future<int> obtenerOCrearSesion(WidgetRef ref) async {
  final db = ref.read(baseDatosProvider);
  final abierta = await db.verSesionEnCurso().first;
  if (abierta != null) return abierta.id;

  final hoy = await db.planDe(DateTime.now().weekday);
  if (hoy != null && !hoy.descanso && hoy.rutinaId != null) {
    return empezarSesionDesdeRutina(ref, hoy.rutinaId!);
  }

  final nombre = (hoy != null && !hoy.descanso && hoy.titulo.isNotEmpty)
      ? hoy.titulo
      : nombrePorDefecto();
  return db.crearSesion(nombre);
}

/// Anade un ejercicio a la sesion en curso con tres series vacias, que es como
/// se empieza practicamente siempre. Se ajustan luego desde la sesion.
Future<void> anadirEjercicioASesion(
  BuildContext context,
  WidgetRef ref,
  String ejercicioId, {
  int series = 3,
}) async {
  final db = ref.read(baseDatosProvider);
  final sesionId = await obtenerOCrearSesion(ref);

  final existentes = await db.verSeries(sesionId).first;
  var orden = existentes.isEmpty
      ? 0
      : existentes.map((s) => s.orden).reduce((a, b) => a > b ? a : b) + 1;

  // Si el ejercicio ya estaba, repetimos su ultimo peso: al anadir una serie
  // mas de algo que ya estas haciendo, lo esperado es continuar con la carga.
  final previas = existentes.where((s) => s.ejercicioId == ejercicioId);
  final pesoPrevio = previas.isEmpty ? 0.0 : previas.last.pesoKg;
  final repsPrevias = previas.isEmpty ? 10 : previas.last.repeticiones;

  for (var i = 0; i < series; i++) {
    await db.anadirSerie(
      sesionId: sesionId,
      ejercicioId: ejercicioId,
      orden: orden++,
      repeticiones: repsPrevias,
      pesoKg: pesoPrevio,
    );
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$series series añadidas'),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Cierra la sesion. Si no se completo ninguna serie, la borra en vez de
/// guardar un registro vacio que solo ensucia el historial y las estadisticas.
Future<bool> terminarSesion(WidgetRef ref, int sesionId) async {
  final db = ref.read(baseDatosProvider);
  final series = await db.verSeries(sesionId).first;
  final hechas = series.where((s) => s.hecha).length;

  if (hechas == 0) {
    await db.borrarSesion(sesionId);
    return false;
  }
  await db.terminarSesion(sesionId);
  return true;
}

/// Renombra una sesion.
Future<void> renombrarSesion(WidgetRef ref, int sesionId, String nombre) {
  final db = ref.read(baseDatosProvider);
  return (db.update(db.sesiones)..where((s) => s.id.equals(sesionId)))
      .write(SesionesCompanion(nombre: Value(nombre)));
}
