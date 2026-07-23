import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/health_data_source.dart';
import '../domain/health_models.dart';
import 'huawei_auth.dart';

/// Adaptador contra la **Health Kit REST API** de Huawei.
///
/// Se eligio la via REST en la nube y no el plugin `huawei_health` porque este
/// ultimo es solo Android, exige HMS Core instalado y solo funciona con
/// garantias en telefonos Huawei. Por la nube, el reloj sincroniza con la app
/// Huawei Health, esta sube a los servidores de Huawei y nosotros leemos de
/// ahi: funciona igual en un Samsung, un Xiaomi o un Pixel.
///
/// ANTES DE QUE ESTO DEVUELVA UN SOLO DATO hace falta, en AppGallery Connect:
///   1. Crear proyecto y app, y anotar el OAuth Client ID.
///   2. Solicitar el servicio Health Kit y superar su revision manual.
///   3. Que te concedan los scopes de sueno, ritmo cardiaco y actividad, que
///      son restringidos.
/// El proceso esta detallado en `docs/huawei-health-kit.md`.
///
/// Estado: la estructura de peticiones y el mapeo a los modelos de dominio
/// estan escritos, pero NO se han podido validar contra el servicio real
/// porque las credenciales aun no existen. Los identificadores de tipo de dato
/// y la forma exacta de la respuesta deben contrastarse con la documentacion
/// vigente en cuanto haya acceso.
class HuaweiRestDataSource implements FuenteDatosSalud {
  HuaweiRestDataSource({required this.auth, http.Client? cliente})
      : _http = cliente ?? http.Client();

  final HuaweiAuth auth;
  final http.Client _http;

  static const _base = 'https://health-api.cloud.huawei.com/healthkit/v1';

  @override
  String get nombre => 'Huawei Health';

  // ------------------------------------------------------------------ auth ---

  @override
  Future<EstadoSalud> estado() async {
    if (!await auth.tieneSesion) return EstadoSalud.sinVincular;
    try {
      await auth.accessTokenValido();
      return EstadoSalud.conectada;
    } on ErrorSalud {
      return EstadoSalud.sinPermisos;
    } catch (_) {
      return EstadoSalud.error;
    }
  }

  @override
  Future<EstadoSalud> vincular() async {
    try {
      await auth.iniciarSesion();
      return EstadoSalud.conectada;
    } on ErrorSalud {
      return EstadoSalud.sinPermisos;
    } catch (_) {
      return EstadoSalud.error;
    }
  }

  @override
  Future<void> desvincular() => auth.cerrarSesion();

  Future<Map<String, dynamic>> _post(String ruta, Map<String, dynamic> cuerpo) async {
    final token = await auth.accessTokenValido();
    final r = await _http.post(
      Uri.parse('$_base$ruta'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: json.encode(cuerpo),
    );

    if (r.statusCode == 401 || r.statusCode == 403) {
      throw const ErrorSalud(
        'La autorización de Huawei caducó o fue revocada.',
        requiereReautenticar: true,
      );
    }
    if (r.statusCode != 200) {
      throw ErrorSalud('Huawei respondió ${r.statusCode}: ${r.body}');
    }
    return json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  /// La API trabaja en milisegundos desde epoch.
  static int _ms(DateTime d) => d.millisecondsSinceEpoch;

  // ------------------------------------------------------------- actividad ---

  /// Identificadores de tipo de dato de Health Kit.
  ///
  /// Confirmar contra la documentacion vigente antes de dar por buena la
  /// integracion: Huawei los ha renombrado entre versiones.
  static const _tipoPasos = 'com.huawei.continuous.steps.delta';
  static const _tipoDistancia = 'com.huawei.continuous.distance.delta';
  static const _tipoCalorias = 'com.huawei.calories.consume';
  static const _tipoPulso = 'com.huawei.instantaneous.heart_rate';
  static const _tipoSueno = 'com.huawei.continuous.sleep.fragment';

  @override
  Future<List<ResumenActividad>> actividad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final inicio = DateTime(desde.year, desde.month, desde.day);
    final fin = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59);

    // `polymerize` agrega en la nube. Pedir el resumen ya agrupado por dia
    // evita bajarse miles de muestras crudas para luego sumarlas aqui.
    final r = await _post('/sampleSet:polymerize', {
      'polymerizeWith': [
        {'dataTypeName': _tipoPasos},
        {'dataTypeName': _tipoDistancia},
        {'dataTypeName': _tipoCalorias},
      ],
      'startTime': _ms(inicio),
      'endTime': _ms(fin),
      'groupByTime': {'duration': 86400000, 'timeZone': '+0000'},
    });

    final porDia = <DateTime, Map<String, num>>{};

    for (final grupo in (r['group'] as List<dynamic>? ?? const [])) {
      final g = grupo as Map<String, dynamic>;
      final dia = DateTime.fromMillisecondsSinceEpoch(
        (g['startTime'] as num).toInt(),
      );
      final clave = DateTime(dia.year, dia.month, dia.day);
      final acc = porDia.putIfAbsent(clave, () => <String, num>{});

      for (final col in (g['sampleSet'] as List<dynamic>? ?? const [])) {
        final c = col as Map<String, dynamic>;
        final tipo = c['dataTypeName'] as String? ?? '';
        for (final punto in (c['samplePoints'] as List<dynamic>? ?? const [])) {
          final valor = _primerValor(punto as Map<String, dynamic>);
          if (valor != null) acc[tipo] = (acc[tipo] ?? 0) + valor;
        }
      }
    }

    final salida = porDia.entries.map((e) {
      final pasos = (e.value[_tipoPasos] ?? 0).round();
      return ResumenActividad(
        dia: e.key,
        pasos: pasos,
        distanciaM: (e.value[_tipoDistancia] ?? 0).round(),
        calorias: ((e.value[_tipoCalorias] ?? 0) / 1000).round(), // vienen en cal
        // Health Kit no expone "minutos activos" como tal; se aproxima desde
        // los pasos. Si mas adelante se leen las sesiones de ejercicio, es
        // preferible calcularlo con su duracion real.
        minutosActivos: (pasos / 190).round(),
      );
    }).toList()
      ..sort((a, b) => a.dia.compareTo(b.dia));

    return salida;
  }

  /// Los puntos traen una lista `value` con el dato en distintos campos segun
  /// el tipo (`integerValue`, `floatValue`...).
  static num? _primerValor(Map<String, dynamic> punto) {
    for (final v in (punto['value'] as List<dynamic>? ?? const [])) {
      final m = v as Map<String, dynamic>;
      final n = m['integerValue'] ?? m['floatValue'] ?? m['doubleValue'];
      if (n is num) return n;
    }
    return null;
  }

  // ------------------------------------------------------------------ pulso ---

  @override
  Future<List<MuestraPulso>> pulsos({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final r = await _post('/sampleSet:polymerize', {
      'polymerizeWith': [
        {'dataTypeName': _tipoPulso}
      ],
      'startTime': _ms(DateTime(desde.year, desde.month, desde.day)),
      'endTime': _ms(DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59)),
      // Agregamos a 10 minutos: la resolucion nativa daria miles de puntos por
      // dia y la grafica no distingue mas que esto.
      'groupByTime': {'duration': 600000, 'timeZone': '+0000'},
    });

    final salida = <MuestraPulso>[];
    for (final grupo in (r['group'] as List<dynamic>? ?? const [])) {
      final g = grupo as Map<String, dynamic>;
      for (final col in (g['sampleSet'] as List<dynamic>? ?? const [])) {
        for (final punto in ((col as Map<String, dynamic>)['samplePoints']
                as List<dynamic>? ??
            const [])) {
          final p = punto as Map<String, dynamic>;
          final bpm = _primerValor(p);
          if (bpm == null || bpm <= 0) continue;
          salida.add(MuestraPulso(
            momento: DateTime.fromMillisecondsSinceEpoch(
              (p['startTime'] as num).toInt(),
            ),
            bpm: bpm.round(),
          ));
        }
      }
    }
    salida.sort((a, b) => a.momento.compareTo(b.momento));
    return salida;
  }

  // ------------------------------------------------------------------ sueno ---

  /// Mapeo de los codigos de fase de Huawei a nuestro enum.
  /// 1 = despierto, 2 = ligero, 3 = profundo, 4 = REM.
  static FaseSueno _fase(int codigo) => switch (codigo) {
        3 => FaseSueno.profundo,
        4 => FaseSueno.rem,
        1 => FaseSueno.despierto,
        _ => FaseSueno.ligero,
      };

  @override
  Future<SesionSueno?> sueno(DateTime dia) async {
    // La noche que "pertenece" a un dia empieza el dia anterior: se pide desde
    // las 18:00 de la vispera hasta las 12:00 del propio dia.
    final desde = DateTime(dia.year, dia.month, dia.day).subtract(const Duration(hours: 6));
    final hasta = DateTime(dia.year, dia.month, dia.day, 12);

    final r = await _post('/sampleSet:polymerize', {
      'polymerizeWith': [
        {'dataTypeName': _tipoSueno}
      ],
      'startTime': _ms(desde),
      'endTime': _ms(hasta),
      'groupByTime': {'duration': 86400000, 'timeZone': '+0000'},
    });

    final tramos = <TramoSueno>[];
    for (final grupo in (r['group'] as List<dynamic>? ?? const [])) {
      final g = grupo as Map<String, dynamic>;
      for (final col in (g['sampleSet'] as List<dynamic>? ?? const [])) {
        for (final punto in ((col as Map<String, dynamic>)['samplePoints']
                as List<dynamic>? ??
            const [])) {
          final p = punto as Map<String, dynamic>;
          final codigo = _primerValor(p)?.toInt() ?? 2;
          tramos.add(TramoSueno(
            fase: _fase(codigo),
            inicio: DateTime.fromMillisecondsSinceEpoch((p['startTime'] as num).toInt()),
            fin: DateTime.fromMillisecondsSinceEpoch((p['endTime'] as num).toInt()),
          ));
        }
      }
    }

    if (tramos.isEmpty) return null;
    tramos.sort((a, b) => a.inicio.compareTo(b.inicio));
    return SesionSueno(
      inicio: tramos.first.inicio,
      fin: tramos.last.fin,
      tramos: tramos,
    );
  }

  // --------------------------------------------------------------- sesiones ---

  @override
  Future<List<SesionRegistrada>> sesiones({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    // Las actividades van por otro endpoint distinto al de muestras.
    final r = await _post('/activityRecords:get', {
      'startTime': _ms(desde),
      'endTime': _ms(hasta),
    });

    final salida = <SesionRegistrada>[];
    for (final a in (r['activityRecords'] as List<dynamic>? ?? const [])) {
      final m = a as Map<String, dynamic>;
      final inicio = DateTime.fromMillisecondsSinceEpoch(
        (m['startTime'] as num).toInt(),
      );
      final fin = DateTime.fromMillisecondsSinceEpoch(
        (m['endTime'] as num).toInt(),
      );
      salida.add(SesionRegistrada(
        inicio: inicio,
        duracion: fin.difference(inicio),
        tipo: (m['activityType'] as String?) ?? 'Actividad',
        calorias: ((m['calories'] as num?) ?? 0).round(),
      ));
    }
    return salida;
  }

  // ------------------------------------------------------------ instantanea ---

  @override
  Future<InstantaneaDiaria> instantanea(DateTime dia) async {
    final d = DateTime(dia.year, dia.month, dia.day);

    // En paralelo: son cuatro viajes de red independientes y en serie se
    // notaria mucho.
    final resultados = await Future.wait([
      actividad(desde: d, hasta: d),
      sueno(d),
      pulsos(desde: d, hasta: d),
      sesiones(desde: d, hasta: d.add(const Duration(days: 1))),
    ]);

    final act = resultados[0] as List<ResumenActividad>;

    return InstantaneaDiaria(
      dia: d,
      actividad: act.isNotEmpty
          ? act.first
          : ResumenActividad(
              dia: d,
              pasos: 0,
              distanciaM: 0,
              calorias: 0,
              minutosActivos: 0,
            ),
      sueno: resultados[1] as SesionSueno?,
      pulsos: resultados[2] as List<MuestraPulso>,
      sesiones: resultados[3] as List<SesionRegistrada>,
    );
  }
}
