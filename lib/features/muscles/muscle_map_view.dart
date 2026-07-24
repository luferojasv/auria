import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/glass_tokens.dart';
import 'muscle_map.dart';

/// Provider del mapa muscular (paths ya parseados). Se carga una vez.
final mapaMuscularProvider = FutureProvider<MapaMuscular>((ref) {
  return MapaMuscular.cargar();
});

/// Vista del cuerpo (frontal + trasera) que resalta los músculos trabajados.
/// [primarios] van en color fuerte, [secundarios] en un tono más suave.
class MuscleMapView extends ConsumerWidget {
  const MuscleMapView({
    super.key,
    required this.primarios,
    this.secundarios = const {},
    this.altura = 220,
  });

  /// Slugs de MuscleMap (usar [slugDeMusculo] para traducir desde el dataset).
  final Set<String> primarios;
  final Set<String> secundarios;
  final double altura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapa = ref.watch(mapaMuscularProvider);

    return mapa.when(
      loading: () => SizedBox(height: altura),
      error: (e, _) => const SizedBox.shrink(),
      data: (m) => SizedBox(
        height: altura,
        child: Row(
          children: [
            Expanded(
              child: _Vista(
                paths: m.front,
                bounds: m.boundsFront,
                primarios: primarios,
                secundarios: secundarios,
                etiqueta: 'Frente',
              ),
            ),
            Expanded(
              child: _Vista(
                paths: m.back,
                bounds: m.boundsBack,
                primarios: primarios,
                secundarios: secundarios,
                etiqueta: 'Espalda',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vista extends StatelessWidget {
  const _Vista({
    required this.paths,
    required this.bounds,
    required this.primarios,
    required this.secundarios,
    required this.etiqueta,
  });

  final Map<String, Path> paths;
  final Rect bounds;
  final Set<String> primarios;
  final Set<String> secundarios;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _PintorCuerpo(
              paths: paths,
              bounds: bounds,
              primarios: primarios,
              secundarios: secundarios,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        Text(etiqueta, style: T.etiqueta.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _PintorCuerpo extends CustomPainter {
  _PintorCuerpo({
    required this.paths,
    required this.bounds,
    required this.primarios,
    required this.secundarios,
  });

  final Map<String, Path> paths;
  final Rect bounds;
  final Set<String> primarios;
  final Set<String> secundarios;

  // Grupos que forman el "cuerpo base" (silueta neutra). El resto se pinta solo
  // si está trabajado.
  static const _relleno = Color(0xFFE7E9F2); // cuerpo en reposo
  static const _borde = Color(0x22141628);

  @override
  void paint(Canvas canvas, Size size) {
    if (bounds.isEmpty) return;

    // Escala uniforme para encajar el cuerpo en el lienzo, centrado.
    final escala = (size.width / bounds.width).clamp(0.0, size.height / bounds.height);
    final anchoEsc = bounds.width * escala;
    final altoEsc = bounds.height * escala;
    final dx = (size.width - anchoEsc) / 2 - bounds.left * escala;
    final dy = (size.height - altoEsc) / 2 - bounds.top * escala;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(escala);

    // 1) Todo el cuerpo en gris neutro.
    final pincelBase = Paint()..color = _relleno..style = PaintingStyle.fill;
    final pincelBorde = Paint()
      ..color = _borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 / escala;
    for (final p in paths.values) {
      canvas.drawPath(p, pincelBase);
      canvas.drawPath(p, pincelBorde);
    }

    // 2) Secundarios en tono suave del acento.
    final pincelSec = Paint()
      ..color = G.acentoEjercicio.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    for (final s in secundarios) {
      final p = paths[s];
      if (p != null && !primarios.contains(s)) canvas.drawPath(p, pincelSec);
    }

    // 3) Primarios en color fuerte, encima.
    final pincelPri = Paint()..color = G.acentoPulso..style = PaintingStyle.fill;
    for (final s in primarios) {
      final p = paths[s];
      if (p != null) {
        canvas.drawPath(p, pincelPri);
        canvas.drawPath(p, pincelBorde);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorCuerpo old) =>
      !setEquals(old.primarios, primarios) ||
      !setEquals(old.secundarios, secundarios) ||
      old.paths != paths;
}
