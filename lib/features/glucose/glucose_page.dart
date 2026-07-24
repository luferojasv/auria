import 'dart:async';

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
import 'link_sheet.dart';

/// Colores por zona glucémica. El verde = en rango es la referencia visual.
/// Saturados para tema claro: los tonos pastel que funcionaban sobre fondo
/// oscuro se vuelven ilegibles sobre blanco.
const _cBajo = Color(0xFFE5484D);
const _cEnRango = Color(0xFF0E9F6E);
const _cAlto = Color(0xFFC77807);
const _cMuyAlto = Color(0xFFDD6B20);

/// Refresca la glucosa periódicamente **solo mientras esta pantalla está
/// montada** y hay datos reales (con el mock no aporta nada). Al salir de la
/// pantalla, el `dispose` corta el timer y deja de llamar a LibreLinkUp.
class GlucosePage extends ConsumerStatefulWidget {
  const GlucosePage({super.key});

  @override
  ConsumerState<GlucosePage> createState() => _GlucosePageState();
}

class _GlucosePageState extends ConsumerState<GlucosePage> {
  Timer? _refresco;

  static const _cadencia = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    // El sensor entrega un dato nuevo cada ~1 min: ese es el ritmo más fino útil.
    _refresco = Timer.periodic(_cadencia, (_) {
      if (ref.read(glucosaVinculadaProvider).value == true) {
        ref.invalidate(resumenGlucosaProvider);
        ref.invalidate(ultimaGlucosaProvider);
      }
    });
  }

  @override
  void dispose() {
    _refresco?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Glucosa', style: T.titulo),
                          // Deja claro de un vistazo si lo que se ve es real o
                          // de demostración: en una app de salud, confundirlos
                          // sería grave.
                          const _FuenteActiva(),
                        ],
                      ),
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
                    detalle: _mensajeError(e),
                    accion: 'Reintentar',
                    onAccion: () {
                      ref.invalidate(resumenGlucosaProvider);
                      ref.invalidate(ultimaGlucosaProvider);
                    },
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

/// Indicador de origen de los datos. Tocarlo abre la vinculación.
class _FuenteActiva extends ConsumerWidget {
  const _FuenteActiva();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vinculada = ref.watch(glucosaVinculadaProvider).value ?? false;
    final color = vinculada ? _cEnRango : G.acentoCalorias;

    return GestureDetector(
      onTap: () => abrirVinculoGlucosa(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 2, right: G.e4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              vinculada ? 'FreeStyle Libre' : 'Datos de demostración',
              style: T.etiqueta.copyWith(fontSize: 11, color: color),
            ),
            const SizedBox(width: 3),
            Icon(Icons.chevron_right_rounded, size: 14, color: color),
          ],
        ),
      ),
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
                getTooltipColor: (_) => G.fondoInverso,
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
    final fiable = resumen.gmiFiable;
    final tieneGmi = resumen.gmi != null;

    return Column(
      children: [
        Row(
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
                icono: fiable ? Icons.science_outlined : Icons.hourglass_empty_rounded,
                // Cuando no es fiable, el número va con "~" para que se lea como
                // aproximado y no se confunda con una A1c de laboratorio.
                valor: !tieneGmi
                    ? '—'
                    : (fiable ? '' : '~') + resumen.gmi!.toStringAsFixed(1),
                unidad: '%',
                etiqueta: fiable ? 'GMI (HbA1c est.)' : 'GMI · orientativo',
                color: fiable ? G.acentoCalorias : G.textoBajo,
              ),
            ),
            const SizedBox(width: G.e3),
            Expanded(
              child: MetricaTile(
                icono: Icons.equalizer_rounded,
                valor: resumen.variabilidad == null
                    ? '—'
                    : '${resumen.variabilidad!.round()}',
                unidad: '%',
                etiqueta: 'Variabilidad',
                color: G.acentoSueno,
              ),
            ),
          ],
        ),
        if (tieneGmi && !fiable) ...[
          const SizedBox(height: G.e3),
          _AvisoGmi(dias: resumen.diasCubiertos),
        ],
      ],
    );
  }
}

/// Aviso de que el GMI aún no es representativo, con acceso a la explicación
/// completa del cálculo. En una app que estima A1c, dejar claro que el número
/// no es un dato clínico es tan importante como el número mismo.
class _AvisoGmi extends StatelessWidget {
  const _AvisoGmi({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarExplicacion(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(G.e3),
        decoration: BoxDecoration(
          borderRadius: G.brS,
          color: G.alerta.withValues(alpha: 0.10),
          border: Border.all(color: G.alerta.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: G.alerta),
            const SizedBox(width: G.e2),
            Expanded(
              child: Text(
                'GMI orientativo: calculado sobre '
                '${dias <= 1 ? 'menos de un día' : '$dias días'}. '
                'Necesita ~14 días para ser representativo.',
                style: T.etiqueta.copyWith(fontSize: 11.5, height: 1.35),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16, color: G.alerta),
          ],
        ),
      ),
    );
  }

  void _mostrarExplicacion(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HojaGmi(),
    );
  }
}

/// Explicación del cálculo del GMI, para que el número nunca se tome por una
/// HbA1c de laboratorio.
class _HojaGmi extends StatelessWidget {
  const _HojaGmi();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(G.radioL)),
      child: Container(
        color: G.fondoAlto,
        padding: const EdgeInsets.fromLTRB(G.e5, G.e3, G.e5, G.e8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: G.e5),
                  decoration: BoxDecoration(
                    color: G.cristalBordeAlto,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('¿Qué es el GMI?', style: T.titulo),
              const SizedBox(height: G.e4),
              Text(
                'El GMI (Glucose Management Indicator) estima qué HbA1c '
                'correspondería a tu glucosa media del sensor. Se calcula así:',
                style: T.cuerpo,
              ),
              const SizedBox(height: G.e4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(G.e4),
                decoration: BoxDecoration(
                  borderRadius: G.brS,
                  color: G.cristalRelleno,
                  border: Border.all(color: G.cristalBorde),
                ),
                child: Text(
                  'GMI (%) = 3,31 + 0,02392 × glucosa media (mg/dL)',
                  style: T.cuerpoFuerte.copyWith(
                    fontSize: 14,
                    fontFeatures: const [],
                  ),
                ),
              ),
              const SizedBox(height: G.e2),
              Text('Fórmula de Bergenstal et al., 2018.', style: T.etiqueta),
              const SizedBox(height: G.e5),
              _Punto(
                texto: 'No es un análisis de sangre. La HbA1c de laboratorio '
                    'mide otra cosa y puede diferir del GMI por tu biología.',
              ),
              _Punto(
                texto: 'Necesita ~14 días continuos de sensor para ser '
                    'representativo. Con pocos días es solo orientativo.',
              ),
              _Punto(
                texto: 'Es informativo, no diagnóstico. No sustituye tu '
                    'laboratorio ni el criterio de tu médico.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: G.e3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(color: G.acentoCalorias, shape: BoxShape.circle),
          ),
          const SizedBox(width: G.e3),
          Expanded(child: Text(texto, style: T.cuerpo)),
        ],
      ),
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

/// Quita el prefijo técnico "ErrorGlucosa:" para que el detalle se lea limpio.
/// El caso de "sin sensor compartido" recibe además una pista accionable.
String _mensajeError(Object e) {
  var m = e.toString().replaceFirst(RegExp(r'^ErrorGlucosa:\s*'), '');
  if (m.contains('sensor compartido')) {
    m += '\n\nSi acabas de activar el compartir en LibreLink, puede tardar unos '
        'minutos en propagarse. Reintenta en un rato.';
  }
  return m;
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
