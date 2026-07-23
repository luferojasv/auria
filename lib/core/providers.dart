import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/glucose/data/mock_glucose_data_source.dart';
import '../features/glucose/domain/glucose_data_source.dart';
import '../features/glucose/domain/glucose_models.dart';
import '../features/health/data/mock_health_data_source.dart';
import '../features/health/domain/health_data_source.dart';
import '../features/health/domain/health_models.dart';

/// Base de datos local. Vive durante toda la app y se cierra al desecharla.
final baseDatosProvider = Provider<BaseDatos>((ref) {
  final db = BaseDatos();
  ref.onDispose(db.close);
  return db;
});

/// Proveedor de biometria.
///
/// Aqui es donde se cambia de datos simulados a datos reales de Huawei: se
/// sustituye esta unica linea por `HuaweiRestDataSource(...)` y la app entera
/// pasa a datos reales. Ninguna pantalla referencia el adaptador directamente.
final fuenteSaludProvider = Provider<FuenteDatosSalud>((ref) {
  return MockHealthDataSource();
});

/// Proveedor de glucosa.
///
/// Aquí se cambia mock → LibreLinkUp: se sustituye por
/// `LibreLinkDataSource(auth: LibreLinkAuth())` y la usuaria vincula con su
/// email/clave desde ajustes. Ninguna pantalla habla con LibreLinkUp directamente.
final fuenteGlucosaProvider = Provider<FuenteGlucosa>((ref) {
  return MockGlucoseDataSource();
});

/// Resumen de glucosa del día seleccionado.
final resumenGlucosaProvider = FutureProvider<ResumenGlucosa>((ref) async {
  final fuente = ref.watch(fuenteGlucosaProvider);
  final dia = ref.watch(diaSeleccionadoProvider);
  return fuente.resumenDia(dia);
});

/// Última lectura (para el dashboard). Se refresca sola cada 2 min: una CGM
/// entrega dato nuevo con esa cadencia.
final ultimaGlucosaProvider = FutureProvider<LecturaGlucosa?>((ref) async {
  final fuente = ref.watch(fuenteGlucosaProvider);
  // Auto-refresco ligero.
  final timer = Timer(const Duration(minutes: 2), () => ref.invalidateSelf());
  ref.onDispose(timer.cancel);
  return fuente.ultima();
});

/// Eventos del día seleccionado.
final eventosDiaProvider = StreamProvider<List<Evento>>((ref) {
  final dia = ref.watch(diaSeleccionadoProvider);
  return ref.watch(baseDatosProvider).verEventosDia(dia);
});

/// Catalogo de ejercicios cargado desde assets. Se lee una sola vez.
final repositorioEjerciciosProvider =
    FutureProvider<RepositorioEjercicios>((ref) async {
  return RepositorioEjercicios.cargar();
});

/// Dia que se esta consultando. Permite navegar el historial sin duplicar
/// providers por pantalla.
final diaSeleccionadoProvider = NotifierProvider<DiaSeleccionado, DateTime>(
  DiaSeleccionado.new,
);

class DiaSeleccionado extends Notifier<DateTime> {
  @override
  DateTime build() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void ir(DateTime d) => state = DateTime(d.year, d.month, d.day);
  void anterior() => state = state.subtract(const Duration(days: 1));

  /// No deja avanzar mas alla de hoy: no hay datos del futuro.
  void siguiente() {
    final n = DateTime.now();
    final hoy = DateTime(n.year, n.month, n.day);
    if (state.isBefore(hoy)) state = state.add(const Duration(days: 1));
  }

  bool get esHoy {
    final n = DateTime.now();
    return state == DateTime(n.year, n.month, n.day);
  }
}

/// Instantanea biometrica del dia seleccionado.
final instantaneaProvider = FutureProvider<InstantaneaDiaria>((ref) async {
  final fuente = ref.watch(fuenteSaludProvider);
  final dia = ref.watch(diaSeleccionadoProvider);
  return fuente.instantanea(dia);
});

/// Actividad de los ultimos [dias] hasta el dia seleccionado, para las graficas.
final actividadRangoProvider =
    FutureProvider.family<List<ResumenActividad>, int>((ref, dias) async {
  final fuente = ref.watch(fuenteSaludProvider);
  final hasta = ref.watch(diaSeleccionadoProvider);
  return fuente.actividad(
    desde: hasta.subtract(Duration(days: dias - 1)),
    hasta: hasta,
  );
});

/// Sueno de las ultimas noches.
final suenoRangoProvider =
    FutureProvider.family<List<SesionSueno?>, int>((ref, dias) async {
  final fuente = ref.watch(fuenteSaludProvider);
  final hasta = ref.watch(diaSeleccionadoProvider);
  return Future.wait([
    for (var i = dias - 1; i >= 0; i--)
      fuente.sueno(hasta.subtract(Duration(days: i))),
  ]);
});

/// Objetivos diarios. De momento fijos; el siguiente paso natural es
/// persistirlos en preferencias y dejar que se editen desde el perfil.
class Objetivos {
  const Objetivos({
    this.pasos = 10000,
    this.calorias = 2200,
    this.minutosActivos = 45,
    this.horasSueno = 8,
  });

  final int pasos;
  final int calorias;
  final int minutosActivos;
  final double horasSueno;
}

final objetivosProvider = Provider<Objetivos>((ref) => const Objetivos());

/// Sesion de entrenamiento abierta, si la hay.
final sesionEnCursoProvider = StreamProvider<Sesion?>((ref) {
  return ref.watch(baseDatosProvider).verSesionEnCurso();
});

/// Historial de sesiones cerradas.
final historialProvider = StreamProvider<List<Sesion>>((ref) {
  return ref.watch(baseDatosProvider).verHistorial();
});

/// Series de una sesion concreta.
final seriesDeSesionProvider =
    StreamProvider.family<List<Serie>, int>((ref, sesionId) {
  return ref.watch(baseDatosProvider).verSeries(sesionId);
});

/// Plan semanal completo (7 dias).
final planSemanalProvider = StreamProvider<List<DiaPlan>>((ref) {
  return ref.watch(baseDatosProvider).verPlanSemanal();
});

/// El dia de hoy en el plan. `DateTime.now().weekday` ya es 1=lunes … 7=domingo.
final planDeHoyProvider = Provider<AsyncValue<DiaPlan?>>((ref) {
  final plan = ref.watch(planSemanalProvider);
  return plan.whenData((dias) {
    final hoy = DateTime.now().weekday;
    for (final d in dias) {
      if (d.dia == hoy) return d;
    }
    return null;
  });
});
