import 'health_models.dart';

/// Estado de la conexion con el proveedor de datos biometricos.
enum EstadoSalud {
  /// Aun no se ha vinculado ninguna cuenta.
  sinVincular,

  /// Vinculada pero sin los permisos necesarios concedidos.
  sinPermisos,

  /// Operativa.
  conectada,

  /// El proveedor respondio con error (token caducado, servicio caido...).
  error,
}

/// Puerto de datos de salud.
///
/// Esta es la frontera del sistema. Toda la app consume esta interfaz y jamas
/// habla directamente con un proveedor. Hay dos motivos concretos:
///
///  1. Huawei Health Kit exige aprobacion manual del servicio en AppGallery
///     Connect antes de devolver un solo dato. Con este puerto, la app entera
///     (dashboard, estadisticas, graficas) se desarrolla y se prueba contra
///     [MockHealthDataSource] mientras esa aprobacion llega.
///  2. Si manana entra Google Fit, Health Connect o Apple HealthKit, se
///     escribe otro adaptador y nada mas cambia.
abstract interface class FuenteDatosSalud {
  /// Nombre legible del proveedor, para mostrarlo en ajustes.
  String get nombre;

  Future<EstadoSalud> estado();

  /// Lanza el flujo de vinculacion/consentimiento. Devuelve el estado final.
  Future<EstadoSalud> vincular();

  Future<void> desvincular();

  /// Resumenes diarios en el rango `[desde, hasta]`, ambos inclusive y
  /// normalizados a dia local.
  Future<List<ResumenActividad>> actividad({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Sesion de sueno que *termina* en [dia]. Devuelve null si no hay registro
  /// (el reloj no se llevo puesto esa noche).
  Future<SesionSueno?> sueno(DateTime dia);

  Future<List<MuestraPulso>> pulsos({
    required DateTime desde,
    required DateTime hasta,
  });

  Future<List<SesionRegistrada>> sesiones({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Conveniencia: todo lo de un dia en una llamada. Los adaptadores pueden
  /// sobrescribirla para agrupar peticiones de red en vez de hacer cuatro.
  Future<InstantaneaDiaria> instantanea(DateTime dia);
}

/// Error de dominio del puerto; los adaptadores traducen sus fallos a este.
class ErrorSalud implements Exception {
  const ErrorSalud(this.mensaje, {this.causa, this.requiereReautenticar = false});

  final String mensaje;
  final Object? causa;

  /// Si true, la UI debe ofrecer volver a vincular en vez de solo reintentar.
  final bool requiereReautenticar;

  @override
  String toString() => 'ErrorSalud: $mensaje';
}
