import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'correlation_engine.dart';
import 'insights_providers.dart';

/// Sección "Patrones" de la pestaña Progreso: cruza tus datos y muestra las
/// relaciones que encuentra, con un aviso de que son asociaciones, no causas.
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallazgos = ref.watch(hallazgosProvider);

    return hallazgos.when(
      loading: () => const _Cargando(),
      error: (e, _) => const SizedBox.shrink(),
      data: (lista) {
        if (lista.isEmpty) {
          return GlassCard(
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: G.acentoSueno),
                const SizedBox(width: G.e3),
                Expanded(
                  child: Text(
                    'Aún no hay patrones claros. Cuando acumules unas semanas de '
                    'datos (sueño, glucosa, entrenamientos), aquí aparecerán las '
                    'relaciones entre ellos.',
                    style: T.cuerpo.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            for (final h in lista.take(6)) _TarjetaHallazgo(hallazgo: h),
            const SizedBox(height: G.e2),
            Text(
              'Patrones observados en tus datos, no relaciones de causa. '
              'No sustituyen el criterio médico.',
              style: T.etiqueta.copyWith(fontSize: 10.5, color: G.textoTenue),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaHallazgo extends StatelessWidget {
  const _TarjetaHallazgo({required this.hallazgo});

  final Hallazgo hallazgo;

  @override
  Widget build(BuildContext context) {
    final color = hallazgo.positiva ? G.exito : G.acentoPulso;

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e3),
      child: GlassCard(
        padding: const EdgeInsets.all(G.e4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nube de puntos: cada día, un punto (variable A vs B).
            SizedBox(
              width: 72,
              height: 72,
              child: _Dispersion(hallazgo: hallazgo, color: color),
            ),
            const SizedBox(width: G.e4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hallazgo.positiva
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 15,
                        color: color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${hallazgo.a.nombre}  ·  ${hallazgo.b.nombre}',
                        style: T.etiqueta.copyWith(fontSize: 11, color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(hallazgo.texto, style: T.cuerpoFuerte.copyWith(fontSize: 13.5, height: 1.35)),
                  const SizedBox(height: G.e2),
                  Text(
                    'Correlación ${hallazgo.fuerza} · ${hallazgo.n} días',
                    style: T.etiqueta.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nube de puntos normalizada (cada eje a 0..1) que ilustra la relación.
class _Dispersion extends StatelessWidget {
  const _Dispersion({required this.hallazgo, required this.color});

  final Hallazgo hallazgo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final puntos = <ScatterSpot>[];
    final a = hallazgo.a.valores, b = hallazgo.b.valores;
    final comunes = a.keys.where(b.containsKey).toList();
    if (comunes.length < 2) return const SizedBox.shrink();

    double min(Iterable<double> xs) => xs.reduce((p, q) => p < q ? p : q);
    double max(Iterable<double> xs) => xs.reduce((p, q) => p > q ? p : q);
    final ax = comunes.map((k) => a[k]!), bx = comunes.map((k) => b[k]!);
    final minA = min(ax), maxA = max(ax), minB = min(bx), maxB = max(bx);
    final rangoA = (maxA - minA).abs() < 1e-9 ? 1 : maxA - minA;
    final rangoB = (maxB - minB).abs() < 1e-9 ? 1 : maxB - minB;

    for (final k in comunes) {
      puntos.add(ScatterSpot(
        (a[k]! - minA) / rangoA,
        (b[k]! - minB) / rangoB,
        dotPainter: FlDotCirclePainter(radius: 2.5, color: color.withValues(alpha: 0.7)),
      ));
    }

    return ScatterChart(
      ScatterChartData(
        minX: -0.05, maxX: 1.05, minY: -0.05, maxY: 1.05,
        scatterSpots: puntos,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: G.cristalBorde),
        ),
        scatterTouchData: ScatterTouchData(enabled: false),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => const GlassCard(
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
}
