import 'package:flutter/foundation.dart' show mapEquals, setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/glass_tokens.dart';
import 'muscle_map.dart';

/// Provider del mapa muscular (paths ya parseados). Se carga una vez.
final mapaMuscularProvider = FutureProvider<MapaMuscular>((ref) {
  return MapaMuscular.cargar();
});

/// Vista del cuerpo (frontal + trasera).
///
/// Dos modos:
///  - **Resaltado** (por defecto): [primarios] en rosa, [secundarios] en violeta.
///  - **Mapa de calor**: si se pasa [intensidad] (slug → 0..1), cada músculo se
///    colorea con un gradiente amarillo → rojo según cuánto lo trabajas.
class MuscleMapView extends ConsumerWidget {
  const MuscleMapView({
    super.key,
    this.primarios = const {},
    this.secundarios = const {},
    this.intensidad,
    this.altura = 220,
  });

  final Set<String> primarios;
  final Set<String> secundarios;

  /// Si se pasa, activa el modo mapa de calor.
  final Map<String, double>? intensidad;
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
                intensidad: intensidad,
                etiqueta: 'Frente',
              ),
            ),
            Expanded(
              child: _Vista(
                paths: m.back,
                bounds: m.boundsBack,
                primarios: primarios,
                secundarios: secundarios,
                intensidad: intensidad,
                etiqueta: 'Espalda',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Color del mapa de calor para una intensidad 0..1: amarillo → naranja → rojo.
Color colorCalor(double t) {
  const amarillo = Color(0xFFF6C445);
  const naranja = Color(0xFFEE7A2E);
  const rojo = Color(0xFFD92D20);
  if (t <= 0.5) return Color.lerp(amarillo, naranja, (t / 0.5).clamp(0, 1))!;
  return Color.lerp(naranja, rojo, ((t - 0.5) / 0.5).clamp(0, 1))!;
}

class _Vista extends StatelessWidget {
  const _Vista({
    required this.paths,
    required this.bounds,
    required this.primarios,
    required this.secundarios,
    required this.intensidad,
    required this.etiqueta,
  });

  final Map<String, Path> paths;
  final Rect bounds;
  final Set<String> primarios;
  final Set<String> secundarios;
  final Map<String, double>? intensidad;
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
              intensidad: intensidad,
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
    required this.intensidad,
  });

  final Map<String, Path> paths;
  final Rect bounds;
  final Set<String> primarios;
  final Set<String> secundarios;
  final Map<String, double>? intensidad;

  static const _relleno = Color(0xFFE7E9F2); // cuerpo en reposo
  static const _borde = Color(0x22141628);

  @override
  void paint(Canvas canvas, Size size) {
    if (bounds.isEmpty) return;

    final escala = (size.width / bounds.width).clamp(0.0, size.height / bounds.height);
    final dx = (size.width - bounds.width * escala) / 2 - bounds.left * escala;
    final dy = (size.height - bounds.height * escala) / 2 - bounds.top * escala;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(escala);

    final pincelBase = Paint()..color = _relleno..style = PaintingStyle.fill;
    final pincelBorde = Paint()
      ..color = _borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 / escala;
    for (final p in paths.values) {
      canvas.drawPath(p, pincelBase);
      canvas.drawPath(p, pincelBorde);
    }

    final heat = intensidad;
    if (heat != null) {
      // Modo mapa de calor: cada músculo con su color según intensidad.
      for (final e in heat.entries) {
        final p = paths[e.key];
        if (p == null || e.value <= 0) continue;
        canvas.drawPath(p, Paint()..color = colorCalor(e.value.clamp(0.0, 1.0)));
        canvas.drawPath(p, pincelBorde);
      }
    } else {
      // Modo resaltado: secundarios suaves, principales fuertes encima.
      final pincelSec = Paint()..color = G.acentoEjercicio.withValues(alpha: 0.35);
      for (final s in secundarios) {
        final p = paths[s];
        if (p != null && !primarios.contains(s)) canvas.drawPath(p, pincelSec);
      }
      final pincelPri = Paint()..color = G.acentoPulso;
      for (final s in primarios) {
        final p = paths[s];
        if (p != null) {
          canvas.drawPath(p, pincelPri);
          canvas.drawPath(p, pincelBorde);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorCuerpo old) =>
      !setEquals(old.primarios, primarios) ||
      !setEquals(old.secundarios, secundarios) ||
      !mapEquals(old.intensidad, intensidad) ||
      old.paths != paths;
}
