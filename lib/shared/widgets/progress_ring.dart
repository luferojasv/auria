import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

/// Un anillo del conjunto.
class Anillo {
  const Anillo({
    required this.valor,
    required this.color,
    this.etiqueta,
  });

  /// Progreso normalizado. Puede pasar de 1.0: el excedente se dibuja como una
  /// segunda vuelta mas brillante, que es como se premia superar el objetivo.
  final double valor;
  final Color color;
  final String? etiqueta;
}

/// Anillos concentricos de progreso, animados.
///
/// Se anima el valor con [TweenAnimationBuilder] para que al llegar dato nuevo
/// el arco crezca en vez de saltar.
class AnillosProgreso extends StatelessWidget {
  const AnillosProgreso({
    super.key,
    required this.anillos,
    this.grosor = 14,
    this.separacion = 6,
    this.centro,
    this.duracion = G.lento,
  });

  final List<Anillo> anillos;
  final double grosor;
  final double separacion;
  final Widget? centro;
  final Duration duracion;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duracion,
      curve: G.curvaSuave,
      builder: (context, avance, _) {
        return CustomPaint(
          painter: _PintorAnillos(
            anillos: anillos,
            grosor: grosor,
            separacion: separacion,
            avance: avance,
          ),
          child: centro == null
              ? const SizedBox.expand()
              : Center(child: centro),
        );
      },
    );
  }
}

class _PintorAnillos extends CustomPainter {
  _PintorAnillos({
    required this.anillos,
    required this.grosor,
    required this.separacion,
    required this.avance,
  });

  final List<Anillo> anillos;
  final double grosor;
  final double separacion;
  final double avance;

  static const _inicio = -math.pi / 2; // arrancamos arriba, no a la derecha

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    var radio = (math.min(size.width, size.height) - grosor) / 2;

    for (final a in anillos) {
      final rect = Rect.fromCircle(center: centro, radius: radio);

      // Pista de fondo.
      canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor
          ..color = a.color.withValues(alpha: 0.16),
      );

      final valor = (a.valor * avance).clamp(0.0, 3.0);
      if (valor > 0.001) {
        final vuelta1 = math.min(valor, 1.0);

        // Halo: mismo arco desenfocado por debajo, que da volumen al anillo.
        // En tema claro va suave: un halo fuerte sobre blanco se ve sucio.
        canvas.drawArc(
          rect,
          _inicio,
          2 * math.pi * vuelta1,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = grosor
            ..strokeCap = StrokeCap.round
            ..color = a.color.withValues(alpha: 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        final trazo = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: 2 * math.pi,
            // El degradado gira con el arco para que el extremo brillante caiga
            // siempre en la punta.
            transform: GradientRotation(_inicio),
            // De un tono claro del acento a su versión plena en la punta. En
            // tema claro NO se blanquea el extremo: sobre fondo luminoso, la
            // punta blanca simplemente desaparecería.
            colors: [
              Color.lerp(a.color, Colors.white, 0.40)!,
              a.color,
              a.color,
            ],
            stops: const [0.0, 0.65, 1.0],
          ).createShader(rect);

        canvas.drawArc(rect, _inicio, 2 * math.pi * vuelta1, false, trazo);

        // Excedente: segunda vuelta en blanco translucido sobre la primera.
        if (valor > 1.0) {
          final resto = math.min(valor - 1.0, 1.0);
          canvas.drawArc(
            rect,
            _inicio,
            2 * math.pi * resto,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = grosor * 0.5
              ..strokeCap = StrokeCap.round
              ..color = Colors.white.withValues(alpha: 0.85),
          );
        }
      }

      radio -= grosor + separacion;
      if (radio <= grosor) break; // sin sitio para mas anillos
    }
  }

  @override
  bool shouldRepaint(_PintorAnillos old) =>
      old.avance != avance ||
      old.grosor != grosor ||
      old.separacion != separacion ||
      !_mismos(old.anillos, anillos);

  static bool _mismos(List<Anillo> a, List<Anillo> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].valor != b[i].valor || a[i].color != b[i].color) return false;
    }
    return true;
  }
}
