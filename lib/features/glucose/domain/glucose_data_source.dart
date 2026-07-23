import 'glucose_models.dart';

/// Estado de la conexión con el proveedor de glucosa.
enum EstadoGlucosa { sinVincular, sinPermisos, conectada, error }

/// Puerto de datos de glucosa continua.
///
/// Misma frontera que [FuenteDatosSalud]: la UI habla solo con esta interfaz.
/// El adaptador por defecto es LibreLinkUp (leyendo del "seguidor" que comparte
/// la app LibreLink), pero cualquier otro —Nightscout, Dexcom, mock— se enchufa
/// aquí sin tocar pantallas.
abstract interface class FuenteGlucosa {
  String get nombre;

  Future<EstadoGlucosa> estado();

  /// Inicia sesión con el proveedor. En LibreLinkUp son email+clave.
  Future<EstadoGlucosa> vincular({String? usuario, String? clave});

  Future<void> desvincular();

  /// Lecturas en el rango `[desde, hasta]`, ordenadas por tiempo.
  Future<List<LecturaGlucosa>> lecturas({
    required DateTime desde,
    required DateTime hasta,
  });

  /// La lectura más reciente, con su tendencia. Es la que va grande en el
  /// dashboard. Null si aún no hay datos.
  Future<LecturaGlucosa?> ultima();

  /// Todo lo del día en una llamada.
  Future<ResumenGlucosa> resumenDia(DateTime dia);
}

class ErrorGlucosa implements Exception {
  const ErrorGlucosa(this.mensaje, {this.requiereReautenticar = false});
  final String mensaje;
  final bool requiereReautenticar;

  @override
  String toString() => 'ErrorGlucosa: $mensaje';
}
