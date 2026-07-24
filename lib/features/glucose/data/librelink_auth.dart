import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../domain/glucose_data_source.dart';

/// Autenticación contra **LibreLinkUp**, el servicio con el que la app LibreLink
/// comparte tus lecturas con "seguidores".
///
/// No es una API oficial documentada por Abbott: es la que usa la app
/// LibreLinkUp y que la comunidad tiene mapeada. Por eso el adaptador está
/// escrito con cuidado pero **sin validar contra el servicio real** (haría falta
/// tu cuenta). Puntos frágiles marcados con TODO.
///
/// La contraseña NUNCA se guarda: solo viaja en el login y lo que se persiste es
/// el token (JWT) en almacenamiento seguro.
class LibreLinkAuth {
  LibreLinkAuth({FlutterSecureStorage? almacen, http.Client? cliente})
      : _almacen = almacen ?? const FlutterSecureStorage(),
        _http = cliente ?? http.Client();

  final FlutterSecureStorage _almacen;
  final http.Client _http;

  /// Punto de entrada global; el login puede redirigir a un host regional
  /// (`api-eu`, `api-la`, `api-us`…), que se guarda para las siguientes llamadas.
  static const _hostBase = 'https://api.libreview.io';

  // Cabeceras que el backend exige imitando a la app oficial. LibreLinkUp
  // rechaza con 403 cualquier `version` por debajo de su mínimo vigente
  // (comprobado: exige >= 4.16.0). Si Abbott vuelve a subirlo, el cuerpo del
  // 403 trae la versión mínima nueva y basta con actualizar esta constante.
  static const _version = '4.16.0';

  static Map<String, String> get _cabecerasBase => {
        'product': 'llu.android',
        'version': _version,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static const _kToken = 'llu_token';
  static const _kHost = 'llu_host';
  static const _kAccountId = 'llu_account_id';

  Future<bool> get tieneSesion async =>
      await _almacen.read(key: _kToken) != null;

  Future<String> get _host async =>
      await _almacen.read(key: _kHost) ?? _hostBase;

  /// Inicia sesión y guarda el token. Devuelve al terminar; lanza [ErrorGlucosa]
  /// si las credenciales fallan.
  Future<void> iniciarSesion(String email, String clave) async {
    var host = _hostBase;

    // El login puede responder con `redirect` a la región correcta; se reintenta
    // una vez contra ese host.
    for (var intento = 0; intento < 2; intento++) {
      final r = await _http.post(
        Uri.parse('$host/llu/auth/login'),
        headers: _cabecerasBase,
        body: json.encode({'email': email, 'password': clave}),
      );

      if (r.statusCode != 200) {
        throw ErrorGlucosa('LibreLinkUp rechazó el acceso (${r.statusCode}).');
      }

      final j = json.decode(r.body) as Map<String, dynamic>;

      // Respuesta de redirección regional.
      final data = j['data'];
      if (data is Map && data['redirect'] == true) {
        final region = data['region'] as String?;
        if (region == null) throw const ErrorGlucosa('Región de LibreLinkUp desconocida.');
        host = 'https://api-$region.libreview.io';
        continue;
      }

      if (data is! Map || data['authTicket'] == null) {
        throw const ErrorGlucosa('Respuesta de LibreLinkUp inesperada en el login.');
      }

      final token = (data['authTicket'] as Map)['token'] as String;
      final userId = ((data['user'] as Map?)?['id'] as String?) ?? '';

      await _almacen.write(key: _kToken, value: token);
      await _almacen.write(key: _kHost, value: host);
      // Las versiones recientes exigen la cabecera `account-id` con el SHA-256
      // del id de usuario. Se calcula una vez y se guarda.
      await _almacen.write(
        key: _kAccountId,
        value: sha256.convert(utf8.encode(userId)).toString(),
      );
      return;
    }

    throw const ErrorGlucosa('LibreLinkUp pidió demasiadas redirecciones.');
  }

  Future<void> cerrarSesion() async {
    await _almacen.delete(key: _kToken);
    await _almacen.delete(key: _kHost);
    await _almacen.delete(key: _kAccountId);
  }

  /// Cabeceras autenticadas para las llamadas de datos.
  Future<Map<String, String>> cabecerasAuth() async {
    final token = await _almacen.read(key: _kToken);
    if (token == null) {
      throw const ErrorGlucosa('No hay sesión con LibreLinkUp.',
          requiereReautenticar: true);
    }
    final accountId = await _almacen.read(key: _kAccountId);
    return {
      ..._cabecerasBase,
      'Authorization': 'Bearer $token',
      // Se omite sola si accountId es null (null-aware map element).
      'account-id': ?accountId,
    };
  }

  Future<Uri> uri(String ruta) async => Uri.parse('${await _host}$ruta');

  http.Client get cliente => _http;
}
