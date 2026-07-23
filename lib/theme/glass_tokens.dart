import 'dart:ui';

import 'package:flutter/material.dart';

/// Tokens del sistema de diseno "aurora glass".
///
/// Un solo sitio donde viven color, desenfoque, radio y ritmo vertical, para
/// que las pantallas no inventen valores sueltos.
abstract final class G {
  // ---------------------------------------------------------------- color ---

  /// Fondo base. Casi negro pero con tinte azul: el cristal necesita algo de
  /// color debajo o se ve gris sucio.
  static const fondo = Color(0xFF070A14);
  static const fondoAlto = Color(0xFF0D1122);

  /// Los tres focos de la aurora que se mueven detras del contenido.
  static const auroraViolet = Color(0xFF7C5CFF);
  static const auroraCian = Color(0xFF22D3EE);
  static const auroraRosa = Color(0xFFFF5C8A);

  /// Acentos semanticos por dominio de dato.
  static const acentoEjercicio = Color(0xFF7C5CFF); // fuerza / entrenamiento
  static const acentoSueno = Color(0xFF818CF8); // sueno
  static const acentoPulso = Color(0xFFFF5C8A); // ritmo cardiaco
  static const acentoActividad = Color(0xFF22D3EE); // pasos / movimiento
  static const acentoCalorias = Color(0xFFFBBF24); // energia

  static const exito = Color(0xFF34D399);
  static const alerta = Color(0xFFFBBF24);
  static const error = Color(0xFFFB7185);

  // Texto sobre cristal oscuro.
  static const textoAlto = Color(0xFFF4F5FB);
  static const textoMedio = Color(0xB3F4F5FB); // 70%
  static const textoBajo = Color(0x80F4F5FB); // 50%
  static const textoTenue = Color(0x4DF4F5FB); // 30%

  // --------------------------------------------------------------- cristal ---

  /// Relleno del cristal. Muy bajo a proposito: el brillo real lo da el
  /// desenfoque del fondo, no la opacidad del relleno.
  static const cristalRelleno = Color(0x14FFFFFF); // 8%
  static const cristalRellenoAlto = Color(0x1FFFFFFF); // 12%
  static const cristalBorde = Color(0x26FFFFFF); // 15%
  static const cristalBordeAlto = Color(0x40FFFFFF); // 25%

  /// Sheen: el degradado diagonal que simula la luz rozando el borde superior.
  /// Sin esto el "cristal" parece plastico plano.
  static const brilloSuperior = Color(0x1AFFFFFF);

  // ------------------------------------------------------------- desenfoque ---

  /// OJO: cada BackdropFilter es una pasada de GPU cara. En listas largas
  /// usamos [GlassCard] con `desenfocar: false`, que pinta el mismo relleno
  /// sin la pasada de blur. Ver nota en glass_card.dart.
  static const blurSuave = 12.0;
  static const blurMedio = 24.0;
  static const blurFuerte = 40.0;

  // ------------------------------------------------------------------ forma ---

  static const radioS = 16.0;
  static const radioM = 24.0;
  static const radioL = 32.0;
  static const radioXL = 40.0;

  static BorderRadius get brS => BorderRadius.circular(radioS);
  static BorderRadius get brM => BorderRadius.circular(radioM);
  static BorderRadius get brL => BorderRadius.circular(radioL);

  // ---------------------------------------------------------------- espacio ---

  static const e1 = 4.0;
  static const e2 = 8.0;
  static const e3 = 12.0;
  static const e4 = 16.0;
  static const e5 = 20.0;
  static const e6 = 24.0;
  static const e8 = 32.0;
  static const e10 = 40.0;
  static const e12 = 48.0;

  // -------------------------------------------------------------- movimiento ---

  static const curvaSuave = Curves.easeOutCubic;
  static const curvaEntrada = Curves.easeOutBack;
  static const rapido = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 320);
  static const lento = Duration(milliseconds: 620);

  // ------------------------------------------------------------------ sombra ---

  /// Sombra de elevacion del cristal. Negra y muy difusa: separa la tarjeta
  /// del fondo sin ensuciar el color.
  static List<BoxShadow> sombra({double y = 12, double blur = 32}) => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.32),
          offset: Offset(0, y),
          blurRadius: blur,
          spreadRadius: -8,
        ),
      ];

  /// Halo de color para elementos activos (anillo cerrado, boton primario).
  static List<BoxShadow> halo(Color c, {double intensidad = 0.45}) => [
        BoxShadow(
          color: c.withValues(alpha: intensidad),
          blurRadius: 28,
          spreadRadius: -6,
        ),
      ];

  // -------------------------------------------------------------- degradados ---

  /// Sheen diagonal estandar para superficies de cristal.
  static const gradienteCristal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brilloSuperior, Color(0x00FFFFFF)],
    stops: [0.0, 0.55],
  );

  static LinearGradient gradienteAcento(Color c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c, Color.lerp(c, auroraCian, 0.45)!],
      );

  /// Filtro reutilizable; evita construir un ImageFilter nuevo en cada build.
  static final ImageFilter filtroSuave =
      ImageFilter.blur(sigmaX: blurSuave, sigmaY: blurSuave);
  static final ImageFilter filtroMedio =
      ImageFilter.blur(sigmaX: blurMedio, sigmaY: blurMedio);
  static final ImageFilter filtroFuerte =
      ImageFilter.blur(sigmaX: blurFuerte, sigmaY: blurFuerte);
}

/// Tipografia. Numeros con cifras tabulares para que los contadores no bailen
/// al cambiar de valor.
abstract final class T {
  static const _f = 'Inter';

  static const displayXL = TextStyle(
    fontFamily: _f,
    fontSize: 56,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.8,
    color: G.textoAlto,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const display = TextStyle(
    fontFamily: _f,
    fontSize: 38,
    height: 1.05,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: G.textoAlto,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const titulo = TextStyle(
    fontFamily: _f,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: G.textoAlto,
  );

  static const seccion = TextStyle(
    fontFamily: _f,
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: G.textoAlto,
  );

  static const cuerpo = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: G.textoMedio,
  );

  static const cuerpoFuerte = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: G.textoAlto,
  );

  static const etiqueta = TextStyle(
    fontFamily: _f,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: G.textoBajo,
  );

  /// Mayusculas espaciadas para encabezados de seccion.
  static const overline = TextStyle(
    fontFamily: _f,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: G.textoBajo,
  );

  static const metrica = TextStyle(
    fontFamily: _f,
    fontSize: 28,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: G.textoAlto,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const unidad = TextStyle(
    fontFamily: _f,
    fontSize: 13,
    height: 1.0,
    fontWeight: FontWeight.w500,
    color: G.textoBajo,
  );
}
