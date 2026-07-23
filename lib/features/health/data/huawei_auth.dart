import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../domain/health_data_source.dart';

/// OAuth 2.0 con Huawei ID mediante **Authorization Code + PKCE**.
///
/// PKCE y no el flujo con `client_secret`: una app movil se puede descompilar,
/// asi que cualquier secreto que se empaquete deja de serlo. PKCE resuelve
/// justo eso — el codigo solo se puede canjear si quien lo canjea conoce el
/// `code_verifier`, que nunca sale del dispositivo.
///
/// Los tokens van a [FlutterSecureStorage] (Keystore en Android), no a
/// SharedPreferences, que es texto plano legible en un dispositivo rooteado.
class HuaweiAuth {
  HuaweiAuth({
    required this.clientId,
    required this.redirectScheme,
    FlutterSecureStorage? almacen,
    http.Client? cliente,
  })  : _almacen = almacen ?? const FlutterSecureStorage(),
        _http = cliente ?? http.Client();

  /// OAuth Client ID de la app en AppGallery Connect.
  final String clientId;

  /// Esquema de la URL de retorno, p. ej. `com.luisarojas.appluisa`. Debe
  /// coincidir con el `redirect_uri` registrado en AGC y con el intent-filter
  /// declarado en AndroidManifest.
  final String redirectScheme;

  final FlutterSecureStorage _almacen;
  final http.Client _http;

  static const _autorizar = 'https://oauth-login.cloud.huawei.com/oauth2/v3/authorize';
  static const _tokenUrl = 'https://oauth-login.cloud.huawei.com/oauth2/v3/token';

  /// Scopes de Health Kit. Son **restringidos**: no basta con pedirlos, hay que
  /// tenerlos concedidos en la revision de AGC o la autorizacion falla.
  static const scopes = <String>[
    'openid',
    'https://www.huawei.com/healthkit/step.read',
    'https://www.huawei.com/healthkit/heartrate.read',
    'https://www.huawei.com/healthkit/sleep.read',
    'https://www.huawei.com/healthkit/activity.read',
  ];

  static const _kAccess = 'hw_access_token';
  static const _kRefresh = 'hw_refresh_token';
  static const _kCaduca = 'hw_expira_en';

  String get redirectUri => '$redirectScheme:/oauth2redirect';

  Future<bool> get tieneSesion async =>
      await _almacen.read(key: _kRefresh) != null;

  // ------------------------------------------------------------------ PKCE ---

  static final _rnd = Random.secure();

  /// 43-128 caracteres del alfabeto no reservado, segun RFC 7636.
  static String _verifier() {
    const alfabeto =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(64, (_) => alfabeto[_rnd.nextInt(alfabeto.length)]).join();
  }

  /// S256: base64url del SHA-256, sin relleno.
  static String _challenge(String verifier) =>
      base64Url.encode(sha256.convert(ascii.encode(verifier)).bytes).replaceAll('=', '');

  // --------------------------------------------------------------- sesion ---

  Future<void> iniciarSesion() async {
    final verifier = _verifier();
    final estado = _verifier(); // vale como nonce anti-CSRF

    final url = Uri.parse(_autorizar).replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'state': estado,
      'code_challenge': _challenge(verifier),
      'code_challenge_method': 'S256',
      'access_type': 'offline', // necesario para recibir refresh_token
    });

    final resultado = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: redirectScheme,
    );

    final devuelto = Uri.parse(resultado);

    // Comprobamos el state antes de tocar el codigo: si no coincide, la
    // respuesta no viene de la peticion que lanzamos.
    if (devuelto.queryParameters['state'] != estado) {
      throw const ErrorSalud('La respuesta de Huawei no coincide con la petición.');
    }

    final error = devuelto.queryParameters['error'];
    if (error != null) {
      throw ErrorSalud('Huawei rechazó la autorización: $error');
    }

    final codigo = devuelto.queryParameters['code'];
    if (codigo == null) {
      throw const ErrorSalud('Huawei no devolvió código de autorización.');
    }

    await _canjear({
      'grant_type': 'authorization_code',
      'code': codigo,
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'code_verifier': verifier,
    });
  }

  Future<void> cerrarSesion() async {
    await _almacen.delete(key: _kAccess);
    await _almacen.delete(key: _kRefresh);
    await _almacen.delete(key: _kCaduca);
  }

  /// Devuelve un access token vigente, refrescandolo si hace falta.
  Future<String> accessTokenValido() async {
    final token = await _almacen.read(key: _kAccess);
    final caducaStr = await _almacen.read(key: _kCaduca);
    final caduca =
        caducaStr == null ? null : DateTime.tryParse(caducaStr);

    // Margen de un minuto: evita que caduque justo entre la comprobacion y la
    // llegada de la peticion al servidor.
    if (token != null &&
        caduca != null &&
        DateTime.now().isBefore(caduca.subtract(const Duration(minutes: 1)))) {
      return token;
    }

    final refresh = await _almacen.read(key: _kRefresh);
    if (refresh == null) {
      throw const ErrorSalud(
        'No hay sesión con Huawei.',
        requiereReautenticar: true,
      );
    }

    await _canjear({
      'grant_type': 'refresh_token',
      'refresh_token': refresh,
      'client_id': clientId,
    });

    final nuevo = await _almacen.read(key: _kAccess);
    if (nuevo == null) {
      throw const ErrorSalud(
        'No se pudo renovar la sesión con Huawei.',
        requiereReautenticar: true,
      );
    }
    return nuevo;
  }

  Future<void> _canjear(Map<String, String> cuerpo) async {
    final r = await _http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: cuerpo,
    );

    if (r.statusCode != 200) {
      throw ErrorSalud(
        'Huawei rechazó el intercambio de token (${r.statusCode}).',
        causa: r.body,
        requiereReautenticar: true,
      );
    }

    final j = json.decode(r.body) as Map<String, dynamic>;

    await _almacen.write(key: _kAccess, value: j['access_token'] as String);

    // En el refresco, Huawei puede no devolver refresh_token nuevo: en ese caso
    // se conserva el que ya teniamos en vez de borrarlo.
    final refresh = j['refresh_token'] as String?;
    if (refresh != null) {
      await _almacen.write(key: _kRefresh, value: refresh);
    }

    final segundos = (j['expires_in'] as num?)?.toInt() ?? 3600;
    await _almacen.write(
      key: _kCaduca,
      value: DateTime.now().add(Duration(seconds: segundos)).toIso8601String(),
    );
  }
}
