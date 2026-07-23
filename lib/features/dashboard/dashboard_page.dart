import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../theme/glass_tokens.dart';
import '../health/domain/health_models.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instantanea = ref.watch(instantaneaProvider);
    final dia = ref.watch(diaSeleccionadoProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(instantaneaProvider),
      backgroundColor: G.fondoAlto,
      color: G.acentoActividad,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Cabecera(dia: dia)),
          instantanea.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: EstadoVacio(
                icono: Icons.cloud_off_rounded,
                titulo: 'No se pudieron leer tus datos',
                detalle: '$e',
                accion: 'Reintentar',
                onAccion: () => ref.invalidate(instantaneaProvider),
              ),
            ),
            data: (d) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 120),
              sliver: SliverList.list(
                children: [
                  _Anillos(datos: d),
                  const SizedBox(height: G.e5),
                  _Metricas(datos: d),
                  const EncabezadoSeccion(titulo: 'Ritmo cardíaco'),
                  _GraficaPulso(pulsos: d.pulsos),
                  if (d.sueno != null) ...[
                    const EncabezadoSeccion(titulo: 'Sueño'),
                    _TarjetaSueno(sueno: d.sueno!),
                  ],
                  if (d.sesiones.isNotEmpty) ...[
                    const EncabezadoSeccion(titulo: 'Registrado por tu reloj'),
                    for (final s in d.sesiones) _FilaSesion(sesion: s),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ cabecera ---

class _Cabecera extends ConsumerWidget {
  const _Cabecera({required this.dia});

  final DateTime dia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(diaSeleccionadoProvider.notifier);
    final esHoy = ref.watch(diaSeleccionadoProvider.notifier).esHoy;

    final fecha = DateFormat("EEEE d 'de' MMMM", 'es').format(dia);
    final hora = DateTime.now().hour;
    final saludo = hora < 6
        ? 'Buenas noches'
        : hora < 13
            ? 'Buenos días'
            : hora < 21
                ? 'Buenas tardes'
                : 'Buenas noches';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        G.e5,
        MediaQuery.paddingOf(context).top + G.e4,
        G.e5,
        G.e5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esHoy ? saludo : 'Resumen', style: T.etiqueta),
                const SizedBox(height: 2),
                Text(
                  // Solo la primera letra en mayuscula: DateFormat en espanol
                  // devuelve el dia en minusculas.
                  fecha[0].toUpperCase() + fecha.substring(1),
                  style: T.titulo,
                ),
              ],
            ),
          ),
          _BotonDia(icono: Icons.chevron_left_rounded, onTap: ctrl.anterior),
          const SizedBox(width: G.e2),
          _BotonDia(
            icono: Icons.chevron_right_rounded,
            // Deshabilitado en el dia de hoy: no hay datos del futuro.
            onTap: esHoy ? null : ctrl.siguiente,
          ),
        ],
      ),
    );
  }
}

class _BotonDia extends StatelessWidget {
  const _BotonDia({required this.icono, this.onTap});

  final IconData icono;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final activo = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: G.cristalRelleno,
          border: Border.all(color: G.cristalBorde),
        ),
        child: Icon(icono, size: 20, color: activo ? G.textoAlto : G.textoTenue),
      ),
    );
  }
}

// ------------------------------------------------------------------- anillos ---

class _Anillos extends ConsumerWidget {
  const _Anillos({required this.datos});

  final InstantaneaDiaria datos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obj = ref.watch(objetivosProvider);
    final a = datos.actividad;

    final pPasos = a.pasos / obj.pasos;
    final pMin = a.minutosActivos / obj.minutosActivos;
    final horas = (datos.sueno?.dormido.inMinutes ?? 0) / 60.0;
    final pSueno = horas / obj.horasSueno;

    return GlassCard(
      padding: const EdgeInsets.all(G.e6),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: AnillosProgreso(
              anillos: [
                Anillo(valor: pPasos, color: G.acentoActividad),
                Anillo(valor: pMin, color: G.acentoEjercicio),
                Anillo(valor: pSueno, color: G.acentoSueno),
              ],
              grosor: 13,
              separacion: 5,
              centro: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${((pPasos + pMin + pSueno) / 3 * 100).round()}',
                    style: T.metrica.copyWith(fontSize: 26),
                  ),
                  Text('%', style: T.unidad.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(width: G.e6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Leyenda(
                  color: G.acentoActividad,
                  titulo: 'Movimiento',
                  valor: '${_miles(a.pasos)} / ${_miles(obj.pasos)}',
                  progreso: pPasos,
                ),
                const SizedBox(height: G.e4),
                _Leyenda(
                  color: G.acentoEjercicio,
                  titulo: 'Ejercicio',
                  valor: '${a.minutosActivos} / ${obj.minutosActivos} min',
                  progreso: pMin,
                ),
                const SizedBox(height: G.e4),
                _Leyenda(
                  color: G.acentoSueno,
                  titulo: 'Sueño',
                  valor: datos.sueno == null
                      ? 'Sin registro'
                      : '${_dur(datos.sueno!.dormido)} / ${obj.horasSueno.toStringAsFixed(0)} h',
                  progreso: pSueno,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({
    required this.color,
    required this.titulo,
    required this.valor,
    required this.progreso,
  });

  final Color color;
  final String titulo;
  final String valor;
  final double progreso;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: G.e2),
            Text(titulo, style: T.etiqueta.copyWith(color: G.textoMedio)),
            const Spacer(),
            if (progreso >= 1)
              Icon(Icons.check_circle_rounded, size: 14, color: color),
          ],
        ),
        const SizedBox(height: 3),
        Text(valor, style: T.cuerpoFuerte.copyWith(fontSize: 14)),
      ],
    );
  }
}

// ------------------------------------------------------------------ metricas ---

class _Metricas extends StatelessWidget {
  const _Metricas({required this.datos});

  final InstantaneaDiaria datos;

  @override
  Widget build(BuildContext context) {
    final a = datos.actividad;
    final reposo = datos.pulsoReposo;

    return Row(
      children: [
        Expanded(
          child: MetricaTile(
            icono: Icons.local_fire_department_rounded,
            valor: _miles(a.calorias),
            unidad: 'kcal',
            etiqueta: 'Energía',
            color: G.acentoCalorias,
          ),
        ),
        const SizedBox(width: G.e3),
        Expanded(
          child: MetricaTile(
            icono: Icons.straighten_rounded,
            valor: a.distanciaKm.toStringAsFixed(1),
            unidad: 'km',
            etiqueta: 'Distancia',
            color: G.acentoActividad,
          ),
        ),
        const SizedBox(width: G.e3),
        Expanded(
          child: MetricaTile(
            icono: Icons.favorite_rounded,
            valor: reposo == null ? '—' : '$reposo',
            unidad: reposo == null ? null : 'bpm',
            etiqueta: 'En reposo',
            color: G.acentoPulso,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ grafica pulso ---

class _GraficaPulso extends StatelessWidget {
  const _GraficaPulso({required this.pulsos});

  final List<MuestraPulso> pulsos;

  @override
  Widget build(BuildContext context) {
    if (pulsos.length < 2) {
      return GlassCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text('Sin lecturas de pulso este día', style: T.cuerpo),
          ),
        ),
      );
    }

    final min = pulsos.map((p) => p.bpm).reduce((a, b) => a < b ? a : b);
    final max = pulsos.map((p) => p.bpm).reduce((a, b) => a > b ? a : b);

    // Eje X en horas decimales, para que las etiquetas caigan en horas exactas.
    final puntos = pulsos
        .map((p) => FlSpot(p.momento.hour + p.momento.minute / 60.0, p.bpm.toDouble()))
        .toList();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(G.e3, G.e5, G.e5, G.e3),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: G.e3, bottom: G.e4),
            child: Row(
              children: [
                _Pastilla(texto: 'Mín $min', color: G.acentoSueno),
                const SizedBox(width: G.e2),
                _Pastilla(texto: 'Máx $max', color: G.acentoPulso),
                const Spacer(),
                Text('bpm', style: T.unidad),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 24,
                minY: (min - 12).toDouble(),
                maxY: (max + 12).toDouble(),
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((max - min) / 2).clamp(10, 60).toDouble(),
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
                      reservedSize: 34,
                      interval: ((max - min) / 2).clamp(10, 60).toDouble(),
                      getTitlesWidget: (v, _) => Text(
                        v.round().toString(),
                        style: T.etiqueta.copyWith(fontSize: 10, color: G.textoTenue),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        if (v % 6 != 0 || v >= 24) return const SizedBox.shrink();
                        return Text(
                          '${v.toInt()}h',
                          style: T.etiqueta.copyWith(fontSize: 10, color: G.textoTenue),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => G.fondoAlto,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.round()} bpm\n${s.x.toInt()}:${((s.x % 1) * 60).round().toString().padLeft(2, '0')}',
                              T.etiqueta.copyWith(color: Colors.white),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: puntos,
                    isCurved: true,
                    curveSmoothness: 0.22,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    gradient: const LinearGradient(
                      colors: [G.acentoSueno, G.acentoPulso],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          G.acentoPulso.withValues(alpha: 0.26),
                          G.acentoPulso.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pastilla extends StatelessWidget {
  const _Pastilla({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: G.e2, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.16),
      ),
      child: Text(
        texto,
        style: T.etiqueta.copyWith(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// -------------------------------------------------------------------- sueno ---

class _TarjetaSueno extends StatelessWidget {
  const _TarjetaSueno({required this.sueno});

  final SesionSueno sueno;

  static const _colores = {
    FaseSueno.profundo: Color(0xFF4C4FD6),
    FaseSueno.rem: Color(0xFF818CF8),
    FaseSueno.ligero: Color(0xFF9FB0FF),
    FaseSueno.despierto: Color(0xFFFFB4C4),
  };

  @override
  Widget build(BuildContext context) {
    final total = sueno.enCama.inSeconds;
    final f = DateFormat.Hm('es');

    return GlassCard(
      tinte: G.acentoSueno,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dur(sueno.dormido), style: T.display.copyWith(fontSize: 32)),
                  Text(
                    '${f.format(sueno.inicio)} — ${f.format(sueno.fin)}',
                    style: T.etiqueta,
                  ),
                ],
              ),
              const Spacer(),
              _Puntuacion(valor: sueno.puntuacion),
            ],
          ),
          const SizedBox(height: G.e5),

          // Hipnograma comprimido: cada fase ocupa su proporcion real de la noche.
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (final t in sueno.tramos)
                    Expanded(
                      flex: (t.duracion.inSeconds * 1000 ~/ total).clamp(1, 1000000),
                      child: ColoredBox(color: _colores[t.fase]!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: G.e4),
          Wrap(
            spacing: G.e4,
            runSpacing: G.e2,
            children: [
              for (final fase in FaseSueno.values)
                _LeyendaFase(
                  color: _colores[fase]!,
                  etiqueta: fase.etiqueta,
                  duracion: sueno.porFase(fase),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Puntuacion extends StatelessWidget {
  const _Puntuacion({required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    final color = valor >= 80
        ? G.exito
        : valor >= 60
            ? G.alerta
            : G.error;

    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: AnillosProgreso(
            anillos: [Anillo(valor: valor / 100, color: color)],
            grosor: 6,
            centro: Text('$valor', style: T.cuerpoFuerte.copyWith(fontSize: 17)),
          ),
        ),
        const SizedBox(height: 3),
        Text('Calidad', style: T.etiqueta.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _LeyendaFase extends StatelessWidget {
  const _LeyendaFase({
    required this.color,
    required this.etiqueta,
    required this.duracion,
  });

  final Color color;
  final String etiqueta;
  final Duration duracion;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('$etiqueta ', style: T.etiqueta.copyWith(fontSize: 11)),
        Text(
          _dur(duracion),
          style: T.etiqueta.copyWith(fontSize: 11, color: G.textoAlto, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- sesiones ---

class _FilaSesion extends StatelessWidget {
  const _FilaSesion({required this.sesion});

  final SesionRegistrada sesion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: G.e3),
      child: GlassCard(
        padding: const EdgeInsets.all(G.e4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(G.e3),
              decoration: BoxDecoration(
                borderRadius: G.brS,
                color: G.acentoEjercicio.withValues(alpha: 0.16),
              ),
              child: const Icon(Icons.fitness_center_rounded, size: 18, color: G.acentoEjercicio),
            ),
            const SizedBox(width: G.e4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sesion.tipo, style: T.cuerpoFuerte),
                  Text(
                    '${DateFormat.Hm('es').format(sesion.inicio)} · ${sesion.duracion.inMinutes} min',
                    style: T.etiqueta,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${sesion.calorias} kcal', style: T.cuerpoFuerte.copyWith(fontSize: 14)),
                if (sesion.pulsoMedio != null)
                  Text('${sesion.pulsoMedio} bpm', style: T.etiqueta.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ helpers ---

String _miles(int n) => NumberFormat.decimalPattern('es').format(n);

String _dur(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
