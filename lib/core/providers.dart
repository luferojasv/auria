import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/glucose/data/librelink_auth.dart';
import '../features/glucose/data/librelink_data_source.dart';
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

/// Autenticación con LibreLinkUp. La contraseña nunca se guarda: solo se usa
/// para el login y lo que persiste es el token, en almacenamiento seguro.
final libreLinkAuthProvider = Provider<LibreLinkAuth>((ref) => LibreLinkAuth());

/// ¿Hay sesión activa con LibreLinkUp? Es lo que decide si la app muestra
/// glucosa real o de demostración.
final glucosaVinculadaProvider =
    AsyncNotifierProvider<GlucosaVinculada, bool>(GlucosaVinculada.new);

class GlucosaVinculada extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(libreLinkAuthProvider).tieneSesion;

  /// Inicia sesión. Devuelve `null` si todo fue bien, o el mensaje de error
  /// para mostrarlo tal cual en la pantalla.
  ///
  /// No se invalida aquí `resumenGlucosaProvider`/`ultimaGlucosaProvider`: ambos
  /// observan (vía `fuenteGlucosaProvider`) este mismo notifier, así que al
  /// cambiar `state` se recalculan solos. Invalidarlos a mano desde aquí crea
  /// una dependencia circular (resumen depende de este notifier, y este notifier
  /// invalidaría a resumen).
  Future<String?> vincular(String email, String clave) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(libreLinkAuthProvider).iniciarSesion(email, clave);
      state = const AsyncValue.data(true);
      return null;
    } on ErrorGlucosa catch (e) {
      state = const AsyncValue.data(false);
      return e.mensaje;
    } catch (e) {
      state = const AsyncValue.data(false);
      return 'No se pudo conectar con LibreLinkUp: $e';
    }
  }

  Future<void> desvincular() async {
    await ref.read(libreLinkAuthProvider).cerrarSesion();
    state = const AsyncValue.data(false);
  }
}

/// Proveedor de glucosa: real si hay sesión con LibreLinkUp, de demostración si
/// no. Ninguna pantalla sabe cuál de los dos está detrás.
final fuenteGlucosaProvider = Provider<FuenteGlucosa>((ref) {
  final vinculada = ref.watch(glucosaVinculadaProvider).value ?? false;
  if (vinculada) {
    return LibreLinkDataSource(auth: ref.watch(libreLinkAuthProvider));
  }
  return MockGlucoseDataSource();
});

/// Resumen de glucosa del día seleccionado.
/// El auto-refresco no vive aquí sino en la pantalla de Glucosa (ver
/// `AutoRefrescoGlucosa`), para que solo se consuma la API mientras esa
/// pantalla está a la vista, y no en segundo plano.
final resumenGlucosaProvider = FutureProvider<ResumenGlucosa>((ref) async {
  final fuente = ref.watch(fuenteGlucosaProvider);
  final dia = ref.watch(diaSeleccionadoProvider);
  return fuente.resumenDia(dia);
});

/// Última lectura, para el dashboard.
final ultimaGlucosaProvider = FutureProvider<LecturaGlucosa?>((ref) async {
  final fuente = ref.watch(fuenteGlucosaProvider);
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
