import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

/// Superficie de cristal: desenfoque del fondo, relleno translucido, sheen
/// diagonal y filo especular.
///
/// Sobre el rendimiento — y esto importa de verdad en esta app: cada
/// [BackdropFilter] obliga a la GPU a leer de vuelta lo ya pintado y
/// desenfocarlo. Uno o dos son gratis; treinta en una lista con scroll tiran el
/// framerate a la mitad en gama media. Por eso [desenfocar] existe: en el
/// dashboard (pocas tarjetas grandes) va en `true`, y en el catalogo de 1.324
/// ejercicios va en `false`, donde el relleno opaco solo es indistinguible en
/// movimiento.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.desenfocar = true,
    this.blur = G.blurMedio,
    this.radio,
    this.padding = const EdgeInsets.all(G.e5),
    this.tinte,
    this.onTap,
    this.resaltado = false,
  });

  final Widget child;

  /// Aplica el desenfoque real del fondo. Ver nota de rendimiento arriba.
  final bool desenfocar;
  final double blur;
  final BorderRadius? radio;
  final EdgeInsetsGeometry padding;

  /// Tinte de acento; colorea sutilmente el relleno y el filo.
  final Color? tinte;

  final VoidCallback? onTap;

  /// Estado activo: sube el relleno y enciende el borde.
  final bool resaltado;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.radio ?? G.brM;
    final tinte = widget.tinte;

    Widget contenido = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        // El relleno base mas, si hay tinte, un velo de color muy bajo.
        color: widget.resaltado ? G.cristalRellenoAlto : G.cristalRelleno,
        gradient: tinte == null
            ? G.gradienteCristal
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    tinte.withValues(alpha: 0.16),
                    G.brilloSuperior,
                  ),
                  tinte.withValues(alpha: 0.04),
                ],
              ),
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.desenfocar) {
      contenido = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: contenido,
      );
    }

    Widget tarjeta = ClipRRect(
      borderRadius: r,
      child: CustomPaint(
        // El filo va encima del contenido para que no lo tape el relleno.
        foregroundPainter: _FiloEspecular(
          radio: r,
          color: tinte ?? Colors.white,
          intensidad: widget.resaltado ? 1.0 : 0.7,
        ),
        child: contenido,
      ),
    );

    // Sombra fuera del clip, si no se recorta contra el propio borde.
    tarjeta = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          ...G.sombra(),
          if (widget.resaltado && tinte != null) ...G.halo(tinte, intensidad: 0.28),
        ],
      ),
      child: tarjeta,
    );

    if (widget.onTap == null) return tarjeta;

    // Escala en vez de ripple: la onda de Material se ve como una mancha sobre
    // una superficie translucida.
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.975 : 1.0,
        duration: G.rapido,
        curve: G.curvaSuave,
        child: tarjeta,
      ),
    );
  }
}

/// Traza el borde con un degradado que va de luz arriba-izquierda a nada
/// abajo-derecha, imitando una fuente de luz unica.
class _FiloEspecular extends CustomPainter {
  _FiloEspecular({
    required this.radio,
    required this.color,
    required this.intensidad,
  });

  final BorderRadius radio;
  final Color color;
  final double intensidad;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Media linea hacia dentro: si no, el clip se come la mitad del trazo.
    final rrect = radio.toRRect(rect).deflate(0.5);

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.44 * intensidad),
          color.withValues(alpha: 0.10 * intensidad),
          color.withValues(alpha: 0.16 * intensidad),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, p);
  }

  @override
  bool shouldRepaint(_FiloEspecular old) =>
      old.color != color || old.intensidad != intensidad || old.radio != radio;
}
