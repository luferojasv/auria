import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_tokens.dart';

/// Tema de la app: claro. El cristal aquí es vidrio esmerilado blanco que
/// aclara y difumina lo de detrás, y los focos de color de la aurora lo tiñen
/// suavemente.
ThemeData construirTema() {
  const esquema = ColorScheme.light(
    primary: G.acentoEjercicio,
    secondary: G.acentoActividad,
    surface: G.fondoAlto,
    error: G.error,
    onPrimary: Colors.white,
    onSurface: G.textoAlto,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: G.fondo,

    // El fondo aurora lo pone AuroraBackground; los Scaffold van transparentes
    // para no taparlo.
    canvasColor: Colors.transparent,

    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,

    textTheme: const TextTheme(
      displayLarge: T.displayXL,
      displayMedium: T.display,
      titleLarge: T.titulo,
      titleMedium: T.seccion,
      bodyMedium: T.cuerpo,
      labelMedium: T.etiqueta,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: T.titulo,
      iconTheme: IconThemeData(color: G.textoAlto),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    dividerTheme: const DividerThemeData(
      color: G.cristalBorde,
      thickness: 1,
      space: 1,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: G.acentoEjercicio,
      inactiveTrackColor: G.cristalRellenoAlto,
      thumbColor: Colors.white,
      overlayColor: G.acentoEjercicio.withValues(alpha: 0.18),
      trackHeight: 4,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: G.cristalRelleno,
      hintStyle: T.cuerpo.copyWith(color: G.textoTenue),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: G.e4, vertical: G.e3),
      border: OutlineInputBorder(
        borderRadius: G.brS,
        borderSide: const BorderSide(color: G.cristalBorde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: G.brS,
        borderSide: const BorderSide(color: G.cristalBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: G.brS,
        borderSide: const BorderSide(color: G.acentoEjercicio, width: 1.5),
      ),
    ),

    // Auria es una app móvil: en una ventana ancha (desktop) los paneles no
    // deben estirarse a todo lo ancho. Los acotamos a una columna centrada.
    bottomSheetTheme: const BottomSheetThemeData(
      constraints: BoxConstraints(maxWidth: 520),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),

    // Snackbar oscuro sobre app clara: un aviso blanco se confundiría con el
    // contenido y pasaría desapercibido.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: G.fondoInverso,
      contentTextStyle: T.cuerpoFuerte.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: G.brS),
    ),

    // El indicador de "cargando" aparece a menudo sobre cristal; en blanco
    // translucido se integra mejor que en color de marca.
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: G.textoMedio,
      linearTrackColor: G.cristalRelleno,
    ),
  );
}
