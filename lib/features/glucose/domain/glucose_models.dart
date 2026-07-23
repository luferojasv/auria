import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Modelos de dominio para glucosa continua (CGM).
///
/// Neutros respecto al proveedor, igual que los de salud: LibreLinkUp,
/// Nightscout o el mock rellenan estas mismas clases. La unidad interna es
/// **mg/dL** (la que usa FreeStyle Libre en gran parte de Latinoamérica); si
/// hiciera falta mmol/L es solo un factor de presentación (÷18).

/// Tendencia de la glucosa, tal como la marca el sensor con su flecha.
enum Tendencia { subiendoRapido, subiendo, estable, bajando, bajandoRapido }

extension TendenciaVista on Tendencia {
  /// Flecha unicode que acompaña a la lectura.
  String get flecha => switch (this) {
        Tendencia.subiendoRapido => '↑↑',
        Tendencia.subiendo => '↑',
        Tendencia.estable => '→',
        Tendencia.bajando => '↓',
        Tendencia.bajandoRapido => '↓↓',
      };

  String get etiqueta => switch (this) {
        Tendencia.subiendoRapido => 'Subiendo rápido',
        Tendencia.subiendo => 'Subiendo',
        Tendencia.estable => 'Estable',
        Tendencia.bajando => 'Bajando',
        Tendencia.bajandoRapido => 'Bajando rápido',
      };
}

/// Una lectura puntual de glucosa.
@immutable
class LecturaGlucosa {
  const LecturaGlucosa({
    required this.momento,
    required this.mgdl,
    this.tendencia,
  });

  final DateTime momento;
  final int mgdl;

  /// Solo la última lectura suele traer tendencia; el histórico no.
  final Tendencia? tendencia;

  double get mmol => mgdl / 18.0;
}

/// Rango objetivo. Los valores por defecto (70–180 mg/dL) son el estándar de
/// consenso internacional para tiempo-en-rango; son un ajuste, no un valor fijo.
@immutable
class RangoObjetivo {
  const RangoObjetivo({this.bajo = 70, this.alto = 180});

  final int bajo;
  final int alto;

  /// Umbral de hipoglucemia clínica: por debajo cuenta como "muy bajo".
  static const muyBajo = 54;

  /// Umbral de hiperglucemia marcada.
  static const muyAlto = 250;
}

/// Reparto del tiempo en cada zona, en fracciones que suman 1.
@immutable
class TiempoEnRango {
  const TiempoEnRango({
    required this.muyBajo,
    required this.bajo,
    required this.enRango,
    required this.alto,
    required this.muyAlto,
    required this.muestras,
  });

  final double muyBajo;
  final double bajo;
  final double enRango;
  final double alto;
  final double muyAlto;
  final int muestras;

  /// Calcula el reparto a partir de una serie de lecturas.
  factory TiempoEnRango.de(
    List<LecturaGlucosa> lecturas, {
    RangoObjetivo rango = const RangoObjetivo(),
  }) {
    if (lecturas.isEmpty) {
      return const TiempoEnRango(
        muyBajo: 0, bajo: 0, enRango: 0, alto: 0, muyAlto: 0, muestras: 0,
      );
    }
    var mb = 0, b = 0, er = 0, a = 0, ma = 0;
    for (final l in lecturas) {
      if (l.mgdl < RangoObjetivo.muyBajo) {
        mb++;
      } else if (l.mgdl < rango.bajo) {
        b++;
      } else if (l.mgdl <= rango.alto) {
        er++;
      } else if (l.mgdl < RangoObjetivo.muyAlto) {
        a++;
      } else {
        ma++;
      }
    }
    final n = lecturas.length;
    return TiempoEnRango(
      muyBajo: mb / n,
      bajo: b / n,
      enRango: er / n,
      alto: a / n,
      muyAlto: ma / n,
      muestras: n,
    );
  }
}

/// Estadísticas del día para el dashboard.
@immutable
class ResumenGlucosa {
  const ResumenGlucosa({
    required this.dia,
    required this.lecturas,
    required this.rango,
  });

  final DateTime dia;
  final List<LecturaGlucosa> lecturas;
  final RangoObjetivo rango;

  LecturaGlucosa? get ultima => lecturas.isEmpty ? null : lecturas.last;

  TiempoEnRango get tiempoEnRango => TiempoEnRango.de(lecturas, rango: rango);

  int? get media => lecturas.isEmpty
      ? null
      : (lecturas.map((l) => l.mgdl).reduce((a, b) => a + b) / lecturas.length)
          .round();

  int? get minimo =>
      lecturas.isEmpty ? null : lecturas.map((l) => l.mgdl).reduce((a, b) => a < b ? a : b);
  int? get maximo =>
      lecturas.isEmpty ? null : lecturas.map((l) => l.mgdl).reduce((a, b) => a > b ? a : b);

  /// GMI (Glucose Management Indicator): estima la HbA1c a partir de la glucosa
  /// media. Fórmula de Bergenstal 2018. Es una estimación poblacional, no un
  /// análisis de sangre.
  double? get gmi {
    final m = media;
    if (m == null) return null;
    return 3.31 + 0.02392 * m;
  }

  /// Coeficiente de variación (%), medida estándar de variabilidad glucémica.
  /// Por debajo de 36% se considera glucosa estable.
  double? get variabilidad {
    if (lecturas.length < 2) return null;
    final m = media!.toDouble();
    if (m == 0) return null;
    final varianza = lecturas
            .map((l) => (l.mgdl - m) * (l.mgdl - m))
            .reduce((a, b) => a + b) /
        lecturas.length;
    return 100 * math.sqrt(varianza) / m;
  }
}
