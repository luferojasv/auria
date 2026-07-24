import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import '../health/domain/health_models.dart';
import '../insights/insights_section.dart';
import 'stats_providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(rangoStatsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              G.e5,
              MediaQuery.paddingOf(context).top + G.e4,
              G.e5,
              G.e4,
            ),
            child: Row(
              children: [
                Text('Progreso', style: T.titulo),
                const Spacer(),
                for (final d in const [7, 30, 90]) ...[
                  const SizedBox(width: G.e2),
                  GlassChip(
                    texto: '${d}d',
                    activo: dias == d,
                    onTap: () => ref.read(rangoStatsProvider.notifier).set(d),
                  ),
                ],
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 120),
          sliver: SliverList.list(
            children: const [
              EncabezadoSeccion(titulo: 'Patrones'),
              InsightsSection(),
              EncabezadoSeccion(titulo: 'Volumen'),
              _Volumen(),
              EncabezadoSeccion(titulo: 'Reparto por músculo'),
              _PorMusculo(),
              EncabezadoSeccion(titulo: 'Pasos'),
              _Pasos(),
              EncabezadoSeccion(titulo: 'Sueño'),
              _Sueno(),
              EncabezadoSeccion(titulo: 'Mejores marcas'),
              _Marcas(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- volumen ---

class _Volumen extends ConsumerWidget {
  const _Volumen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(volumenDiarioProvider);

    return datos.when(
      loading: () => const _Cargando(alto: 190),
      error: (e, _) => _Error(mensaje: '$e'),
      data: (lista) {
        final total = lista.fold<double>(0, (a, v) => a + v.volumen);
        if (total == 0) {
          return const GlassCard(
            child: SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Registra tu primer entrenamiento\npara ver tu volumen aquí',
                  textAlign: TextAlign.center,
                  style: T.cuerpo,
                ),
              ),
            ),
          );
        }

        final max = lista.map((v) => v.volumen).reduce((a, b) => a > b ? a : b);
        final entrenados = lista.where((v) => v.volumen > 0).length;

        return GlassCard(
          tinte: G.acentoEjercicio,
          padding: const EdgeInsets.fromLTRB(G.e5, G.e5, G.e5, G.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    total >= 1000
                        ? (total / 1000).toStringAsFixed(1)
                        : total.round().toString(),
                    style: T.display,
                  ),
                  const SizedBox(width: 4),
                  Text(total >= 1000 ? 'toneladas' : 'kg', style: T.unidad),
                ],
              ),
              Text(
                'Volumen total · $entrenados ${entrenados == 1 ? "día" : "días"} de entreno',
                style: T.etiqueta,
              ),
              const SizedBox(height: G.e5),
              SizedBox(
                height: 130,
                child: BarChart(
                  BarChartData(
                    maxY: max * 1.15,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => G.fondoInverso,
                        getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                          '${rod.toY.round()} kg\n'
                          '${DateFormat('d MMM', 'es').format(lista[group.x].dia)}',
                          T.etiqueta.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < lista.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: lista[i].volumen,
                              width: (260 / lista.length).clamp(2.0, 14.0),
                              borderRadius: BorderRadius.circular(3),
                              gradient: lista[i].volumen == 0
                                  ? null
                                  : const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [G.acentoEjercicio, G.auroraCian],
                                    ),
                              color: lista[i].volumen == 0 ? G.cristalRelleno : null,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------- por musculo ---

class _PorMusculo extends ConsumerWidget {
  const _PorMusculo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(volumenPorMusculoProvider);

    return datos.when(
      loading: () => const _Cargando(alto: 140),
      error: (e, _) => _Error(mensaje: '$e'),
      data: (lista) {
        if (lista.isEmpty) {
          return const GlassCard(
            child: SizedBox(
              height: 80,
              child: Center(child: Text('Todavía sin datos', style: T.cuerpo)),
            ),
          );
        }

        final max = lista.first.volumen;
        // Solo el top 8: mas alla la barra es tan corta que no informa.
        final top = lista.take(8).toList();

        return GlassCard(
          child: Column(
            children: [
              for (var i = 0; i < top.length; i++) ...[
                if (i > 0) const SizedBox(height: G.e3),
                _BarraMusculo(
                  etiqueta: top[i].musculo,
                  valor: top[i].volumen,
                  fraccion: top[i].volumen / max,
                  color: Color.lerp(G.acentoEjercicio, G.acentoPulso, i / top.length)!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BarraMusculo extends StatelessWidget {
  const _BarraMusculo({
    required this.etiqueta,
    required this.valor,
    required this.fraccion,
    required this.color,
  });

  final String etiqueta;
  final double valor;
  final double fraccion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            etiqueta,
            style: T.etiqueta.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraccion),
              duration: G.lento,
              curve: G.curvaSuave,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: G.cristalRelleno,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: G.e3),
        SizedBox(
          width: 56,
          child: Text(
            valor >= 1000
                ? '${(valor / 1000).toStringAsFixed(1)} t'
                : '${valor.round()} kg',
            style: T.etiqueta.copyWith(fontSize: 11, color: G.textoAlto),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- pasos ---

class _Pasos extends ConsumerWidget {
  const _Pasos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(rangoStatsProvider);
    final datos = ref.watch(actividadRangoProvider(dias));
    final obj = ref.watch(objetivosProvider);

    return datos.when(
      loading: () => const _Cargando(alto: 170),
      error: (e, _) => _Error(mensaje: '$e'),
      data: (lista) {
        if (lista.isEmpty) return const SizedBox.shrink();

        final media = lista.fold<int>(0, (a, r) => a + r.pasos) / lista.length;
        final cumplidos = lista.where((r) => r.pasos >= obj.pasos).length;

        return GlassCard(
          tinte: G.acentoActividad,
          padding: const EdgeInsets.fromLTRB(G.e5, G.e5, G.e5, G.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    NumberFormat.decimalPattern('es').format(media.round()),
                    style: T.display,
                  ),
                  const SizedBox(width: 4),
                  Text('media diaria', style: T.unidad),
                ],
              ),
              Text(
                '$cumplidos de ${lista.length} días alcanzaron el objetivo',
                style: T.etiqueta,
              ),
              const SizedBox(height: G.e5),
              SizedBox(
                height: 110,
                child: _LineaSimple(
                  valores: lista.map((r) => r.pasos.toDouble()).toList(),
                  color: G.acentoActividad,
                  referencia: obj.pasos.toDouble(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------- sueno ---

class _Sueno extends ConsumerWidget {
  const _Sueno();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(rangoStatsProvider);
    final datos = ref.watch(suenoRangoProvider(dias));
    final obj = ref.watch(objetivosProvider);

    return datos.when(
      loading: () => const _Cargando(alto: 170),
      error: (e, _) => _Error(mensaje: '$e'),
      data: (lista) {
        final conDatos = lista.whereType<SesionSueno>().toList();
        if (conDatos.isEmpty) {
          return const GlassCard(
            child: SizedBox(
              height: 80,
              child: Center(child: Text('Sin registros de sueño', style: T.cuerpo)),
            ),
          );
        }

        final mediaH =
            conDatos.fold<int>(0, (a, s) => a + s.dormido.inMinutes) /
                conDatos.length /
                60.0;
        final mediaPunt =
            conDatos.fold<int>(0, (a, s) => a + s.puntuacion) / conDatos.length;

        return GlassCard(
          tinte: G.acentoSueno,
          padding: const EdgeInsets.fromLTRB(G.e5, G.e5, G.e5, G.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${mediaH.floor()}h ${((mediaH % 1) * 60).round().toString().padLeft(2, '0')}m',
                    style: T.display,
                  ),
                  const SizedBox(width: G.e3),
                  Text('calidad ${mediaPunt.round()}', style: T.unidad),
                ],
              ),
              Text(
                'Media de ${conDatos.length} ${conDatos.length == 1 ? "noche" : "noches"}',
                style: T.etiqueta,
              ),
              const SizedBox(height: G.e5),
              SizedBox(
                height: 110,
                child: _LineaSimple(
                  // Las noches sin registro se dibujan como cero, no se saltan:
                  // asi el hueco es visible en vez de disimularse uniendo la
                  // linea entre dos noches no consecutivas.
                  valores: lista
                      .map((s) => (s?.dormido.inMinutes ?? 0) / 60.0)
                      .toList(),
                  color: G.acentoSueno,
                  referencia: obj.horasSueno,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Linea con area y una guia horizontal de objetivo.
class _LineaSimple extends StatelessWidget {
  const _LineaSimple({
    required this.valores,
    required this.color,
    this.referencia,
  });

  final List<double> valores;
  final Color color;
  final double? referencia;

  @override
  Widget build(BuildContext context) {
    if (valores.length < 2) {
      return Center(child: Text('Datos insuficientes', style: T.etiqueta));
    }

    final max = valores.reduce((a, b) => a > b ? a : b);
    final techo = (referencia == null ? max : (max > referencia! ? max : referencia!)) * 1.18;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: techo == 0 ? 1 : techo,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => G.fondoInverso,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      s.y >= 100 ? '${s.y.round()}' : s.y.toStringAsFixed(1),
                      T.etiqueta.copyWith(color: Colors.white),
                    ))
                .toList(),
          ),
        ),
        extraLinesData: referencia == null
            ? const ExtraLinesData()
            : ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: referencia!,
                    color: G.cristalBordeAlto,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ],
              ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < valores.length; i++)
                FlSpot(i.toDouble(), valores[i]),
            ],
            isCurved: true,
            curveSmoothness: 0.28,
            barWidth: 2,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- marcas ---

class _Marcas extends ConsumerWidget {
  const _Marcas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(mejoresMarcasProvider);

    return datos.when(
      loading: () => const _Cargando(alto: 100),
      error: (e, _) => _Error(mensaje: '$e'),
      data: (lista) {
        if (lista.isEmpty) {
          return const GlassCard(
            child: SizedBox(
              height: 80,
              child: Center(
                child: Text('Sin marcas todavía', style: T.cuerpo),
              ),
            ),
          );
        }

        return GlassCard(
          child: Column(
            children: [
              for (var i = 0; i < lista.take(8).length; i++) ...[
                if (i > 0) const Divider(height: G.e5),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lista[i].nombre,
                            style: T.cuerpoFuerte.copyWith(fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${lista[i].marca.repeticiones} reps · '
                            '1RM≈${lista[i].marca.unaRepMax.round()} kg',
                            style: T.etiqueta.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${lista[i].marca.pesoKg.round()} kg',
                      style: T.cuerpoFuerte.copyWith(color: G.acentoCalorias),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- auxiliar ---

class _Cargando extends StatelessWidget {
  const _Cargando({required this.alto});

  final double alto;

  @override
  Widget build(BuildContext context) => GlassCard(
        child: SizedBox(
          height: alto,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) => GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(G.e3),
          child: Text(mensaje, style: T.cuerpo.copyWith(color: G.error)),
        ),
      );
}
