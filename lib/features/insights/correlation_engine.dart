import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Una variable diaria: su valor para cada día, y cómo describirla. Todo el
/// motor trabaja alineando estas series por fecha.
@immutable
class VariableDiaria {
  const VariableDiaria({
    required this.id,
    required this.nombre,
    required this.valores,
    this.subirEsMejor,
  });

  final String id;
  final String nombre;

  /// Día (normalizado a medianoche) → valor.
  final Map<DateTime, double> valores;

  /// Si subir esta variable es "bueno" (dormir más), "malo" (glucosa media), o
  /// null si es neutro. Solo sirve para matizar el texto del hallazgo.
  final bool? subirEsMejor;
}

/// Un patrón detectado entre dos variables.
@immutable
class Hallazgo {
  const Hallazgo({
    required this.a,
    required this.b,
    required this.r,
    required this.n,
  });

  final VariableDiaria a;
  final VariableDiaria b;

  /// Coeficiente de correlación de Pearson, en [-1, 1].
  final double r;

  /// Días con datos en ambas variables (tamaño de la muestra).
  final int n;

  bool get positiva => r >= 0;

  /// Fuerza cualitativa de la correlación.
  String get fuerza {
    final a = r.abs();
    if (a >= 0.7) return 'fuerte';
    if (a >= 0.5) return 'moderada';
    return 'leve';
  }

  /// Texto en lenguaje natural. Deliberadamente en términos de asociación
  /// ("suele"), nunca de causa: una correlación no prueba que A cause B.
  String get texto {
    final mas = positiva ? 'más' : 'menos';
    return 'En los días con más ${a.nombre.toLowerCase()}, '
        'tu ${b.nombre.toLowerCase()} suele ser $mas.';
  }
}

/// Coeficiente de correlación de Pearson de una lista de pares (x, y).
/// Devuelve null si hay menos de 3 puntos o si alguna variable no tiene
/// varianza (todos los valores iguales → correlación indefinida).
double? pearson(List<({double x, double y})> puntos) {
  final n = puntos.length;
  if (n < 3) return null;

  var sx = 0.0, sy = 0.0;
  for (final p in puntos) {
    sx += p.x;
    sy += p.y;
  }
  final mx = sx / n, my = sy / n;

  var cov = 0.0, vx = 0.0, vy = 0.0;
  for (final p in puntos) {
    final dx = p.x - mx, dy = p.y - my;
    cov += dx * dy;
    vx += dx * dx;
    vy += dy * dy;
  }
  if (vx == 0 || vy == 0) return null;

  final r = cov / (math.sqrt(vx) * math.sqrt(vy));
  return r.clamp(-1.0, 1.0);
}

/// Cruza todas las parejas de variables y devuelve los hallazgos que superan el
/// umbral, ordenados por fuerza (|r|) descendente.
///
/// [minDias] evita concluir de pocos datos; [minR] descarta correlaciones
/// triviales. Los valores por defecto son conservadores a propósito: más vale
/// no mostrar un patrón que mostrar uno espurio.
List<Hallazgo> correlacionar(
  List<VariableDiaria> variables, {
  int minDias = 8,
  double minR = 0.4,
}) {
  final salida = <Hallazgo>[];

  for (var i = 0; i < variables.length; i++) {
    for (var j = i + 1; j < variables.length; j++) {
      final a = variables[i], b = variables[j];

      // Alineamos por día: solo los días con dato en AMBAS.
      final puntos = <({double x, double y})>[];
      for (final e in a.valores.entries) {
        final vb = b.valores[e.key];
        if (vb != null) puntos.add((x: e.value, y: vb));
      }
      if (puntos.length < minDias) continue;

      final r = pearson(puntos);
      if (r == null || r.abs() < minR) continue;

      salida.add(Hallazgo(a: a, b: b, r: r, n: puntos.length));
    }
  }

  salida.sort((x, y) => y.r.abs().compareTo(x.r.abs()));
  return salida;
}
