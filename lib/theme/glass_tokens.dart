import 'dart:ui';

import 'package:flutter/material.dart';

/// Tokens del sistema de diseño "aurora glass", en **tema claro**.
///
/// El glassmorphism claro funciona al revés que el oscuro: allí el cristal se
/// veía porque dejaba pasar luz de color; aquí se ve porque es un vidrio
/// esmerilado **blanco** que aclara y difumina lo que tiene detrás (el mismo
/// principio que iOS/macOS). De ahí que el relleno tenga mucha más opacidad que
/// en un tema oscuro: por debajo del 55% el cristal deja de leerse como tal.
abstract final class G {
  // ---------------------------------------------------------------- color ---

  /// Fondo base: blanco con un punto de azul, para que los focos de la aurora
  /// no floten sobre un blanco muerto.
  static const fondo = Color(0xFFF2F4FB);

  /// Superficie sólida (hojas modales, menús).
  static const fondoAlto = Color(0xFFFFFFFF);

  /// Fondo de tooltips y toasts. Oscuro a propósito: sobre una app clara, un
  /// tooltip blanco se confundiría con el contenido.
  static const fondoInverso = Color(0xFF1B1E36);

  /// Focos de la aurora. Se pintan con alfa bajo: sobre fondo claro basta un
  /// velo para dar color, y pasarse ensucia el blanco.
  static const auroraViolet = Color(0xFF7C5CFF);
  static const auroraCian = Color(0xFF22D3EE);
  static const auroraRosa = Color(0xFFFF5C8A);

  /// Acentos por dominio de dato. Más saturados que en el tema oscuro: sobre
  /// blanco, un color luminoso pierde contraste y deja de ser legible.
  static const acentoEjercicio = Color(0xFF6341F0); // fuerza / entrenamiento
  static const acentoSueno = Color(0xFF4F52C9); // sueño
  static const acentoPulso = Color(0xFFDB3A72); // ritmo cardiaco
  static const acentoActividad = Color(0xFF0E8FB2); // pasos / movimiento
  static const acentoCalorias = Color(0xFFC77807); // energia

  static const exito = Color(0xFF0E9F6E);
  static const alerta = Color(0xFFC77807);
  static const error = Color(0xFFD92D20);

  // Texto sobre cristal claro.
  static const textoAlto = Color(0xFF14162B);
  static const textoMedio = Color(0xB014162B); // 69%
  static const textoBajo = Color(0x8A14162B); // 54%
  static const textoTenue = Color(0x5C14162B); // 36%

  // --------------------------------------------------------------- cristal ---

  /// Relleno del cristal: blanco translúcido. Alto a propósito (ver nota
  /// arriba): es lo que produce el esmerilado.
  static const cristalRelleno = Color(0xA6FFFFFF); // 65%
  static const cristalRellenoAlto = Color(0xD6FFFFFF); // 84%

  /// Borde de definición. En claro, un borde blanco desaparece: hace falta una
  /// línea oscura muy tenue para separar la tarjeta del fondo.
  static const cristalBorde = Color(0x1F14162B); // 12% oscuro
  static const cristalBordeAlto = Color(0x3314162B); // 20% oscuro

  /// Reflejo blanco del canto superior, lo que da el "filo" del vidrio.
  static const brilloSuperior = Color(0xE6FFFFFF);

  // ------------------------------------------------------------- desenfoque ---

  /// OJO: cada BackdropFilter es una pasada de GPU cara. En listas largas
  /// usamos [GlassCard] con `desenfocar: false`.
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

  /// Sombra de elevación. Azulada y muy difusa, nunca negra: sobre blanco, el
  /// negro puro ensucia y se ve como una mancha gris.
  static List<BoxShadow> sombra({double y = 10, double blur = 28}) => [
        BoxShadow(
          color: const Color(0xFF2A2E5A).withValues(alpha: 0.10),
          offset: Offset(0, y),
          blurRadius: blur,
          spreadRadius: -6,
        ),
        // Segunda sombra corta: asienta la tarjeta y define su canto inferior.
        BoxShadow(
          color: const Color(0xFF2A2E5A).withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 6,
          spreadRadius: -2,
        ),
      ];

  /// Halo de color para elementos activos.
  static List<BoxShadow> halo(Color c, {double intensidad = 0.35}) => [
        BoxShadow(
          color: c.withValues(alpha: intensidad),
          blurRadius: 22,
          spreadRadius: -6,
          offset: const Offset(0, 6),
        ),
      ];

  // -------------------------------------------------------------- degradados ---

  /// Reflejo diagonal del cristal: blanco arriba-izquierda que se desvanece.
  static const gradienteCristal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x99FFFFFF), Color(0x14FFFFFF)],
    stops: [0.0, 0.6],
  );

  static LinearGradient gradienteAcento(Color c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c, Color.lerp(c, auroraCian, 0.35)!],
      );

  /// Filtros reutilizables; evita construir un ImageFilter en cada build.
  static final ImageFilter filtroSuave =
      ImageFilter.blur(sigmaX: blurSuave, sigmaY: blurSuave);
  static final ImageFilter filtroMedio =
      ImageFilter.blur(sigmaX: blurMedio, sigmaY: blurMedio);
  static final ImageFilter filtroFuerte =
      ImageFilter.blur(sigmaX: blurFuerte, sigmaY: blurFuerte);
}

/// Tipografía. Números con cifras tabulares para que los contadores no bailen
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

  /// Mayúsculas espaciadas para encabezados de sección.
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
