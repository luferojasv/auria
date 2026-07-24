import 'dart:convert';

import '../domain/glucose_data_source.dart';
import '../domain/glucose_models.dart';
import 'librelink_auth.dart';

/// Adaptador de glucosa sobre **LibreLinkUp**.
///
/// Estructura escrita contra la API que usa la app LibreLinkUp (no oficial). NO
/// validada contra el servicio real todavía —hace falta la cuenta de la
/// usuaria—; los puntos a confirmar están marcados con TODO.
///
/// Limitación conocida de LibreLinkUp: el endpoint de gráfica devuelve solo las
/// **últimas ~12 h**. Para un histórico más largo habría que ir acumulando las
/// lecturas en la base local a medida que llegan (lo natural en la Fase 4).
class LibreLinkDataSource implements FuenteGlucosa {
  LibreLinkDataSource({required this.auth});

  final LibreLinkAuth auth;

  /// Paciente seleccionado (la propia usuaria, normalmente el único). Se
  /// resuelve en la primera llamada y se cachea en memoria.
  String? _patientId;

  @override
  String get nombre => 'FreeStyle Libre (LibreLinkUp)';

  @override
  Future<EstadoGlucosa> estado() async {
    if (!await auth.tieneSesion) return EstadoGlucosa.sinVincular;
    try {
      await _conexion();
      return EstadoGlucosa.conectada;
    } on ErrorGlucosa {
      return EstadoGlucosa.sinPermisos;
    } catch (_) {
      return EstadoGlucosa.error;
    }
  }

  @override
  Future<EstadoGlucosa> vincular({String? usuario, String? clave}) async {
    if (usuario == null || clave == null) {
      return EstadoGlucosa.sinPermisos;
    }
    try {
      await auth.iniciarSesion(usuario, clave);
      _patientId = null;
      return EstadoGlucosa.conectada;
    } on ErrorGlucosa {
      return EstadoGlucosa.sinPermisos;
    } catch (_) {
      return EstadoGlucosa.error;
    }
  }

  @override
  Future<void> desvincular() async {
    _patientId = null;
    await auth.cerrarSesion();
  }

  /// El "connection" es la persona cuyos datos seguimos. Aunque seas tú misma,
  /// LibreLinkUp lo modela como un seguidor siguiéndote.
  Future<Map<String, dynamic>> _conexion() async {
    final r = await auth.cliente.get(
      await auth.uri('/llu/connections'),
      headers: await auth.cabecerasAuth(),
    );
    if (r.statusCode == 401) {
      throw const ErrorGlucosa('Sesión de LibreLinkUp caducada.',
          requiereReautenticar: true);
    }
    if (r.statusCode != 200) {
      throw ErrorGlucosa(_detalle('conexiones', r.statusCode, r.body));
    }
    final data = (json.decode(r.body) as Map<String, dynamic>)['data'] as List;
    if (data.isEmpty) {
      throw const ErrorGlucosa(
        'No hay ningún sensor compartido con esta cuenta de LibreLinkUp.',
      );
    }
    final conexion = data.first as Map<String, dynamic>;
    _patientId = conexion['patientId'] as String?;
    return conexion;
  }

  /// Mapea el TrendArrow de LibreLinkUp (1..5) a nuestra tendencia.
  static Tendencia? _tendencia(int? arrow) => switch (arrow) {
        1 => Tendencia.bajandoRapido,
        2 => Tendencia.bajando,
        3 => Tendencia.estable,
        4 => Tendencia.subiendo,
        5 => Tendencia.subiendoRapido,
        _ => null,
      };

  static LecturaGlucosa _lectura(Map<String, dynamic> m, {bool conTendencia = false}) {
    // El timestamp viene como "M/d/yyyy h:mm:ss a" en la zona del sensor.
    // TODO: confirmar el formato exacto y la zona al validar; de momento se
    // intenta ISO y, si falla, el formato americano.
    final ts = m['Timestamp'] as String? ?? m['FactoryTimestamp'] as String? ?? '';
    return LecturaGlucosa(
      momento: _fecha(ts),
      mgdl: (m['ValueInMgPerDl'] as num?)?.round() ??
          (m['Value'] as num?)?.round() ??
          0,
      tendencia: conTendencia ? _tendencia((m['TrendArrow'] as num?)?.toInt()) : null,
    );
  }

  static DateTime _fecha(String s) {
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Fallback muy básico "M/d/yyyy h:mm:ss AM/PM".
    try {
      final partes = s.split(' ');
      final f = partes[0].split('/');
      var h = int.parse(partes[1].split(':')[0]);
      final min = int.parse(partes[1].split(':')[1]);
      final pm = partes.length > 2 && partes[2].toUpperCase() == 'PM';
      if (pm && h != 12) h += 12;
      if (!pm && h == 12) h = 0;
      return DateTime(int.parse(f[2]), int.parse(f[0]), int.parse(f[1]), h, min);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<Map<String, dynamic>> _graph() async {
    _patientId ??= (await _conexion())['patientId'] as String?;
    final r = await auth.cliente.get(
      await auth.uri('/llu/connections/$_patientId/graph'),
      headers: await auth.cabecerasAuth(),
    );
    if (r.statusCode != 200) {
      throw ErrorGlucosa(_detalle('lecturas', r.statusCode, r.body));
    }
    return (json.decode(r.body) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  /// Mensaje de error legible que conserva el motivo real de LibreLinkUp: su
  /// cuerpo suele traer la causa (por ejemplo, la versión mínima exigida), y sin
  /// él un "403" a secas no dice nada para depurar.
  static String _detalle(String paso, int codigo, String cuerpo) {
    var motivo = cuerpo.trim();
    try {
      final j = json.decode(cuerpo);
      if (j is Map) {
        final err = j['error'];
        motivo = (err is Map ? err['message']?.toString() : err?.toString()) ??
            j['message']?.toString() ??
            cuerpo;
      }
    } catch (_) {
      // cuerpo no-JSON: lo dejamos tal cual, recortado
    }
    if (motivo.length > 180) motivo = '${motivo.substring(0, 180)}…';
    return 'LibreLinkUp rechazó la petición de $paso ($codigo). '
        '${motivo.isEmpty ? '' : 'Motivo: $motivo'}';
  }

  /// La lectura EN VIVO. LibreLinkUp la sirve en `connection.glucoseMeasurement`,
  /// aparte del histórico, y es la única que va al minuto; el `graphData` llega
  /// con ~30 min de retraso. Es la que muestra también la app oficial.
  static LecturaGlucosa? _actualDe(Map<String, dynamic> data) {
    final m = (data['connection'] as Map?)?['glucoseMeasurement'] as Map?;
    if (m == null) return null;
    return _lectura(m.cast<String, dynamic>(), conTendencia: true);
  }

  @override
  Future<LecturaGlucosa?> ultima() async => _actualDe(await _graph());

  /// Combina el histórico (`graphData`) con la lectura en vivo, que suele ser
  /// más reciente que el último punto del histórico. Sin esto, la gráfica y la
  /// "última lectura" se quedaban ~30 min atrás respecto al sensor real.
  List<LecturaGlucosa> _combinar(
    Map<String, dynamic> data, {
    required DateTime desde,
    required DateTime hasta,
  }) {
    final serie = (data['graphData'] as List? ?? const [])
        .map((m) => _lectura((m as Map).cast<String, dynamic>()))
        .toList();

    final actual = _actualDe(data);
    if (actual != null &&
        // Solo si es realmente más nueva que el último punto del histórico.
        (serie.isEmpty || actual.momento.isAfter(serie.last.momento))) {
      serie.add(actual);
    }

    return serie
        .where((l) => !l.momento.isBefore(desde) && !l.momento.isAfter(hasta))
        .toList()
      ..sort((a, b) => a.momento.compareTo(b.momento));
  }

  @override
  Future<List<LecturaGlucosa>> lecturas({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    return _combinar(await _graph(), desde: desde, hasta: hasta);
  }

  @override
  Future<ResumenGlucosa> resumenDia(DateTime dia) async {
    final ini = DateTime(dia.year, dia.month, dia.day);
    // Una sola llamada de red para todo el día.
    return ResumenGlucosa(
      dia: ini,
      lecturas: _combinar(await _graph(),
          desde: ini, hasta: ini.add(const Duration(days: 1))),
      rango: const RangoObjetivo(),
    );
  }
}
