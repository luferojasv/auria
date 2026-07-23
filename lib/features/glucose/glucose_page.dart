import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'domain/glucose_models.dart';
import 'event_sheet.dart';

/// Colores por zona glucémica. El verde = en rango es la referencia visual.
const _cBajo = Color(0xFFFB7185);
const _cEnRango = Color(0xFF34D399);
const _cAlto = Color(0xFFFBBF24);
const _cMuyAlto = Color(0xFFFB923C);

class GlucosePage extends ConsumerWidget {
  const GlucosePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenGlucosaProvider);
    final eventos = ref.watch(eventosDiaProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => ref.invalidate(resumenGlucosaProvider),
          backgroundColor: G.fondoAlto,
          color: _cEnRango,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      Text('Glucosa', style: T.titulo),
                      const Spacer(),
                      resumen.maybeWhen(
                        data: (r) => _Ultima(resumen: r),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              resumen.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: EstadoVacio(
                    icono: Icons.bloodtype_outlined,
                    titulo: 'No se pudo leer la glucosa',
                    detalle: '$e',
                  ),
                ),
                data: (r) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 140),
                  sliver: SliverList.list(
                    children: [
                      _Grafica(resumen: r, eventos: eventos.value ?? const []),
                      const SizedBox(height: G.e5),
                      _TiempoEnRango(tir: r.tiempoEnRango),
                      const SizedBox(height: G.e3),
                      _Stats(resumen: r),
                      const EncabezadoSeccion(titulo: 'Eventos del día'),
                      _ListaEventos(eventos: eventos),
                      const SizedBox(height: G.e6),
                      Text(
                        'Registro personal. No sustituye tu medidor ni el criterio médico.',
                        style: T.etiqueta.copyWith(fontSize: 10.5, color: G.textoTenue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Añadir evento.
        Positioned(
          right: G.e5,
          bottom: MediaQuery.paddingOf(context).bottom + 96,
          child: _BotonAnadir(onTap: () => abrirNuevoEvento(context, ref)),
        ),
      ],
    );
  }
}

class _Ultima extends StatelessWidget {
  const _Ultima({required this.resumen});

  final ResumenGlucosa resumen;

  @override
  Widget build(BuildContext context) {
    final u = resumen.ultima;
    if (u == null) return const SizedBox.shrink();
    final color = _colorDe(u.mgdl, resumen.rango);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('${u.mgdl}', style: T.titulo.copyWith(color: color, fontSize: 26)),
        const SizedBox(width: 3),
        Text('mg/dL', style: T.unidad),
        if (u.tendencia != null) ...[
          const SizedBox(width: 5),
          Text(u.tendencia!.flecha, style: T.titulo.copyWith(color: color, fontSize: 20)),
        ],
      ],
    );
  }
}

class _Grafica extends StatelessWidget {
  const _Grafica({required this.resumen, required this.eventos});

  final ResumenGlucosa resumen;
  final List<Evento> eventos;

  @override
  Widget build(BuildContext context) {
    final lecturas = resumen.lecturas;
    if (lecturas.length < 2) {
      return const GlassCard(
        child: SizedBox(
          height: 160,
          child: Center(child: Text('Sin lecturas de glucosa hoy', style: T.cuerpo)),
        ),
      );
    }

    final rango = resumen.rango;
    final puntos = lecturas
        .map((l) => FlSpot(l.momento.hour + l.momento.minute / 60.0, l.mgdl.toDouble()))
        .toList();
    final maxY = ((resumen.maximo ?? 200) + 30).clamp(200, 400).toDouble();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(G.e2, G.e5, G.e4, G.e3),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 24,
            minY: 40,
            maxY: maxY,
            // Banda del rango objetivo, sombreada en verde tenue.
            rangeAnnotations: RangeAnnotations(
              horizontalRangeAnnotations: [
                HorizontalRangeAnnotation(
                  y1: rango.bajo.toDouble(),
                  y2: rango.alto.toDouble(),
                  color: _cEnRango.withValues(alpha: 0.10),
                ),
              ],
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: G.cristalBorde, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 50,
                  getTitlesWidget: (v, _) => Text(
                    v.round().toString(),
                    style: T.etiqueta.copyWith(fontSize: 9.5, color: G.textoTenue),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 6,
                  reservedSize: 20,
                  getTitlesWidget: (v, _) => v % 6 == 0 && v < 24
                      ? Text('${v.toInt()}h',
                          style: T.etiqueta.copyWith(fontSize: 9.5, color: G.textoTenue))
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            // Marcadores verticales de los eventos sobre la línea de tiempo.
            extraLinesData: ExtraLinesData(
              verticalLines: [
                for (final e in eventos)
                  VerticalLine(
                    x: e.momento.hour + e.momento.minute / 60.0,
                    color: _colorEvento(e.tipo).withValues(alpha: 0.5),
                    strokeWidth: 1.5,
                    dashArray: [3, 3],
                  ),
              ],
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => G.fondoAlto,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          '${s.y.round()} mg/dL\n${s.x.toInt()}:${((s.x % 1) * 60).round().toString().padLeft(2, '0')}',
                          T.etiqueta.copyWith(color: Colors.white),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: puntos,
                isCurved: true,
                curveSmoothness: 0.2,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                color: _cEnRango,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _cEnRango.withValues(alpha: 0.20),
                      _cEnRango.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TiempoEnRango extends StatelessWidget {
  const _TiempoEnRango({required this.tir});

  final TiempoEnRango tir;

  @override
  Widget build(BuildContext context) {
    if (tir.muestras == 0) return const SizedBox.shrink();

    final segmentos = [
      (tir.muyBajo + tir.bajo, _cBajo, 'Bajo'),
      (tir.enRango, _cEnRango, 'En rango'),
      (tir.alto, _cAlto, 'Alto'),
      (tir.muyAlto, _cMuyAlto, 'Muy alto'),
    ].where((s) => s.$1 > 0).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${(tir.enRango * 100).round()}%', style: T.display.copyWith(fontSize: 32)),
              const SizedBox(width: G.e2),
              Text('en rango', style: T.unidad),
              const Spacer(),
              Text('objetivo >70%', style: T.etiqueta),
            ],
          ),
          const SizedBox(height: G.e4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final s in segmentos)
                    Expanded(
                      flex: (s.$1 * 1000).round().clamp(1, 100000),
                      child: ColoredBox(color: s.$2),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: G.e3),
          Wrap(
            spacing: G.e4,
            runSpacing: G.e2,
            children: [
              for (final s in segmentos)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: s.$2, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('${s.$3} ', style: T.etiqueta.copyWith(fontSize: 11)),
                    Text('${(s.$1 * 100).round()}%',
                        style: T.etiqueta.copyWith(fontSize: 11, color: G.textoAlto, fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.resumen});

  final ResumenGlucosa resumen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricaTile(
            icono: Icons.show_chart_rounded,
            valor: '${resumen.media ?? '—'}',
            unidad: 'mg/dL',
            etiqueta: 'Media',
            color: _cEnRango,
          ),
        ),
        const SizedBox(width: G.e3),
        Expanded(
          child: MetricaTile(
            icono: Icons.science_outlined,
            valor: resumen.gmi == null ? '—' : resumen.gmi!.toStringAsFixed(1),
            unidad: '%',
            etiqueta: 'GMI (HbA1c est.)',
            color: G.acentoCalorias,
          ),
        ),
        const SizedBox(width: G.e3),
        Expanded(
          child: MetricaTile(
            icono: Icons.equalizer_rounded,
            valor: resumen.variabilidad == null ? '—' : '${resumen.variabilidad!.round()}',
            unidad: '%',
            etiqueta: 'Variabilidad',
            color: G.acentoSueno,
          ),
        ),
      ],
    );
  }
}

class _ListaEventos extends ConsumerWidget {
  const _ListaEventos({required this.eventos});

  final AsyncValue<List<Evento>> eventos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return eventos.when(
      loading: () => const SizedBox(height: 40),
      error: (e, _) => Text('$e', style: T.cuerpo),
      data: (lista) {
        if (lista.isEmpty) {
          return GlassCard(
            desenfocar: false,
            child: SizedBox(
              height: 64,
              child: Center(
                child: Text('Registra una comida, estrés o medicación con el botón +',
                    style: T.cuerpo.copyWith(fontSize: 13), textAlign: TextAlign.center),
              ),
            ),
          );
        }
        return Column(
          children: [for (final e in lista) _FilaEvento(evento: e)],
        );
      },
    );
  }
}

class _FilaEvento extends ConsumerWidget {
  const _FilaEvento({required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _colorEvento(evento.tipo);
    return Padding(
      padding: const EdgeInsets.only(bottom: G.e2),
      child: GlassCard(
        desenfocar: false,
        radio: G.brS,
        padding: const EdgeInsets.all(G.e3),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: color.withValues(alpha: 0.18),
              ),
              child: Icon(_iconoEvento(evento.tipo), size: 18, color: color),
            ),
            const SizedBox(width: G.e3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.titulo, style: T.cuerpoFuerte.copyWith(fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(_subtitulo(evento), style: T.etiqueta.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Text(DateFormat.Hm('es').format(evento.momento), style: T.etiqueta),
            const SizedBox(width: G.e2),
            GestureDetector(
              onTap: () => ref.read(baseDatosProvider).borrarEvento(evento.id),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(G.e1),
                child: Icon(Icons.close_rounded, size: 16, color: G.textoTenue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitulo(Evento e) {
    switch (e.tipo) {
      case TipoEvento.comida:
        final partes = <String>[
          if (e.carbos != null) '${e.carbos!.round()}g carbos',
          if (e.proteina != null) '${e.proteina!.round()}g prot',
          if (e.calorias != null) '${e.calorias!.round()} kcal',
        ];
        return partes.isEmpty ? e.tipo.etiqueta : partes.join(' · ');
      case TipoEvento.estres:
        return e.nivel != null ? 'Nivel ${e.nivel}/10' : e.tipo.etiqueta;
      case TipoEvento.medicamento:
      case TipoEvento.suplemento:
        return e.dosis ?? e.tipo.etiqueta;
      case TipoEvento.ejercicio:
        return e.nivel != null ? 'Intensidad ${e.nivel}/10' : e.tipo.etiqueta;
    }
  }
}

class _BotonAnadir extends StatelessWidget {
  const _BotonAnadir({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: G.gradienteAcento(_cEnRango),
          boxShadow: G.halo(_cEnRango, intensidad: 0.4),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

Color _colorDe(int mgdl, RangoObjetivo r) {
  if (mgdl < r.bajo) return _cBajo;
  if (mgdl <= r.alto) return _cEnRango;
  if (mgdl < RangoObjetivo.muyAlto) return _cAlto;
  return _cMuyAlto;
}

Color _colorEvento(TipoEvento t) => switch (t) {
      TipoEvento.comida => G.acentoCalorias,
      TipoEvento.ejercicio => G.acentoEjercicio,
      TipoEvento.estres => _cBajo,
      TipoEvento.medicamento => G.acentoSueno,
      TipoEvento.suplemento => G.acentoActividad,
    };

IconData _iconoEvento(TipoEvento t) => switch (t) {
      TipoEvento.comida => Icons.restaurant_rounded,
      TipoEvento.ejercicio => Icons.fitness_center_rounded,
      TipoEvento.estres => Icons.bolt_rounded,
      TipoEvento.medicamento => Icons.medication_rounded,
      TipoEvento.suplemento => Icons.medication_liquid_rounded,
    };
