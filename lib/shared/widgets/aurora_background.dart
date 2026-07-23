import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

/// Fondo animado: tres focos de color que derivan lentamente detras de todo.
///
/// Se pinta con gradientes radiales, no con desenfoque. Un `BackdropFilter` a
/// pantalla completa y animado cuesta una pasada de GPU por frame y hunde el
/// framerate en gama media; un `RadialGradient` con paradas suaves da el mismo
/// difuminado gratis. El desenfoque real se reserva para las tarjetas, que son
/// pequenas y pocas.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.animado = true,
    this.intensidad = 1.0,
  });

  final Widget child;

  /// Permite congelar el movimiento (ajuste de accesibilidad o ahorro de bateria).
  final bool animado;

  /// 0 = fondo plano, 1 = aurora completa.
  final double intensidad;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // Ciclo muy largo: el movimiento debe percibirse solo si te quedas mirando.
    duration: const Duration(seconds: 48),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animado) _c.repeat();
  }

  @override
  void didUpdateWidget(AuroraBackground old) {
    super.didUpdateWidget(old);
    if (widget.animado && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.animado && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respetamos "reducir movimiento" del sistema.
    final reducir = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Container(
      color: G.fondo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(
                painter: _AuroraPainter(
                  t: reducir ? 0.0 : _c.value,
                  intensidad: widget.intensidad,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.intensidad});

  final double t;
  final double intensidad;

  /// Cada foco: color, radio relativo, y la orbita que describe.
  static const _focos = <_Foco>[
    _Foco(G.auroraViolet, 0.95, Offset(0.18, 0.10), 0.22, 0.10, 0.0),
    _Foco(G.auroraCian, 0.80, Offset(0.88, 0.28), 0.16, 0.14, 0.38),
    _Foco(G.auroraRosa, 0.70, Offset(0.55, 0.92), 0.20, 0.12, 0.71),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (intensidad <= 0) return;
    final lado = math.max(size.width, size.height);

    for (final f in _focos) {
      final fase = (t + f.desfase) * 2 * math.pi;
      final centro = Offset(
        (f.origen.dx + math.cos(fase) * f.orbitaX) * size.width,
        (f.origen.dy + math.sin(fase) * f.orbitaY) * size.height,
      );
      final radio = lado * f.radio;

      // Alpha bajo y caida cuadratica: los focos deben insinuarse, no dominar.
      final pintura = Paint()
        ..shader = RadialGradient(
          colors: [
            f.color.withValues(alpha: 0.34 * intensidad),
            f.color.withValues(alpha: 0.14 * intensidad),
            f.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: radio));
      canvas.drawCircle(centro, radio, pintura);
    }

    // Vineta inferior: ancla la composicion y mejora el contraste de la barra
    // de navegacion, que va justo encima.
    final vineta = Paint()
      ..shader = LinearGradient(
        begin: Alignment.center,
        end: Alignment.bottomCenter,
        colors: [G.fondo.withValues(alpha: 0.0), G.fondo.withValues(alpha: 0.72)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vineta);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.t != t || old.intensidad != intensidad;
}

class _Foco {
  const _Foco(
    this.color,
    this.radio,
    this.origen,
    this.orbitaX,
    this.orbitaY,
    this.desfase,
  );

  final Color color;
  final double radio;
  final Offset origen;
  final double orbitaX;
  final double orbitaY;
  final double desfase;
}
