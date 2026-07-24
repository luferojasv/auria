import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/glass_tokens.dart';
import 'muscle_map_view.dart';

/// Músculos que forman la silueta base pero no son seleccionables como filtro
/// (cabeza, manos, pies…): están para dar forma al cuerpo, no para entrenar.
const _noSeleccionables = {
  'head', 'hair', 'hands', 'feet', 'neck', 'knees', 'ankles', 'tibialis',
};

/// Silueta interactiva de una vista (frontal o trasera). Al tocar un músculo
/// llama [onMusculo] con su slug. [resaltado] se pinta como seleccionado.
class MuscleSilhouette extends ConsumerWidget {
  const MuscleSilhouette({
    super.key,
    required this.frente,
    required this.onMusculo,
    this.resaltado,
  });

  final bool frente;
  final ValueChanged<String> onMusculo;
  final String? resaltado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapa = ref.watch(mapaMuscularProvider);

    return mapa.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => const SizedBox.shrink(),
      data: (m) {
        final paths = frente ? m.front : m.back;
        final bounds = frente ? m.boundsFront : m.boundsBack;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final slug = _musculoEn(d.localPosition, size, paths, bounds);
                if (slug != null) onMusculo(slug);
              },
              child: CustomPaint(
                painter: _PintorSilueta(
                  paths: paths,
                  bounds: bounds,
                  seleccionado: resaltado,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        );
      },
    );
  }

  /// Convierte el toque a coordenadas del path y devuelve el músculo tocado.
  static String? _musculoEn(
    Offset punto,
    Size size,
    Map<String, Path> paths,
    Rect bounds,
  ) {
    if (bounds.isEmpty) return null;
    final escala = (size.width / bounds.width) <= (size.height / bounds.height)
        ? size.width / bounds.width
        : size.height / bounds.height;
    final dx = (size.width - bounds.width * escala) / 2 - bounds.left * escala;
    final dy = (size.height - bounds.height * escala) / 2 - bounds.top * escala;
    final enPath = Offset((punto.dx - dx) / escala, (punto.dy - dy) / escala);

    // Recorremos priorizando los seleccionables; el primero que contenga gana.
    for (final e in paths.entries) {
      if (_noSeleccionables.contains(e.key)) continue;
      if (e.value.contains(enPath)) return e.key;
    }
    return null;
  }
}

class _PintorSilueta extends CustomPainter {
  _PintorSilueta({
    required this.paths,
    required this.bounds,
    required this.seleccionado,
  });

  final Map<String, Path> paths;
  final Rect bounds;
  final String? seleccionado;

  static const _base = Color(0xFFE7E9F2);
  static const _borde = Color(0x22141628);

  @override
  void paint(Canvas canvas, Size size) {
    if (bounds.isEmpty) return;
    final escala = (size.width / bounds.width) <= (size.height / bounds.height)
        ? size.width / bounds.width
        : size.height / bounds.height;
    final dx = (size.width - bounds.width * escala) / 2 - bounds.left * escala;
    final dy = (size.height - bounds.height * escala) / 2 - bounds.top * escala;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(escala);

    final base = Paint()..color = _base;
    final borde = Paint()
      ..color = _borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 / escala;
    for (final p in paths.values) {
      canvas.drawPath(p, base);
      canvas.drawPath(p, borde);
    }

    if (seleccionado != null && paths.containsKey(seleccionado)) {
      canvas.drawPath(paths[seleccionado]!, Paint()..color = G.acentoPulso);
      canvas.drawPath(paths[seleccionado]!, borde);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorSilueta old) =>
      old.seleccionado != seleccionado || old.paths != paths;
}

/// Silueta con conmutador Frente / Espalda, para usar como filtro por músculo.
class SiluetaConVistas extends StatefulWidget {
  const SiluetaConVistas({super.key, required this.onMusculo, this.resaltado});

  final ValueChanged<String> onMusculo;
  final String? resaltado;

  @override
  State<SiluetaConVistas> createState() => _SiluetaConVistasState();
}

class _SiluetaConVistasState extends State<SiluetaConVistas> {
  bool _frente = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Conmutador de vista.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Toggle(texto: 'Frente', activo: _frente, onTap: () => setState(() => _frente = true)),
            const SizedBox(width: G.e2),
            _Toggle(texto: 'Espalda', activo: !_frente, onTap: () => setState(() => _frente = false)),
          ],
        ),
        const SizedBox(height: G.e3),
        Expanded(
          child: MuscleSilhouette(
            frente: _frente,
            onMusculo: widget.onMusculo,
            resaltado: widget.resaltado,
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.texto, required this.activo, required this.onTap});

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: G.e4, vertical: G.e2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: activo ? G.acentoEjercicio.withValues(alpha: 0.18) : G.cristalRelleno,
          border: Border.all(
            color: activo ? G.acentoEjercicio.withValues(alpha: 0.5) : G.cristalBorde,
          ),
        ),
        child: Text(
          texto,
          style: T.etiqueta.copyWith(
            color: activo ? G.acentoEjercicio : G.textoBajo,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
