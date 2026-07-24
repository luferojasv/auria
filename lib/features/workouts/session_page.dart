import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import '../exercises/exercise_providers.dart';
import 'rest_timer.dart';
import 'session_context_sheet.dart';
import 'workout_actions.dart';

class SessionPage extends ConsumerWidget {
  const SessionPage({super.key, required this.sesionId});

  final int sesionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesDeSesionProvider(sesionId));
    final enCurso = ref.watch(sesionEnCursoProvider).value;
    final activa = enCurso?.id == sesionId;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  G.e4,
                  MediaQuery.paddingOf(context).top + G.e3,
                  G.e4,
                  G.e4,
                ),
                child: Row(
                  children: [
                    GlassCard(
                      padding: EdgeInsets.zero,
                      radio: BorderRadius.circular(999),
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_back_rounded, size: 20),
                      ),
                    ),
                    const Spacer(),
                    if (activa && enCurso != null) ...[
                      // Check-in previo: ánimo, energía, dolor, lugar.
                      GlassCard(
                        padding: EdgeInsets.zero,
                        radio: BorderRadius.circular(999),
                        onTap: () => abrirContextoSesion(context, ref, enCurso),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            enCurso.animoAntes?.emoji != null
                                ? Icons.mood_rounded
                                : Icons.mood_outlined,
                            size: 20,
                            color: enCurso.animoAntes != null ? G.acentoCalorias : G.textoAlto,
                          ),
                        ),
                      ),
                      const SizedBox(width: G.e2),
                      BotonGlass(
                        texto: 'Terminar',
                        icono: Icons.stop_rounded,
                        color: G.exito,
                        onTap: () => _confirmarTerminar(context, ref),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            series.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EstadoVacio(icono: Icons.error_outline_rounded, titulo: '$e'),
              ),
              data: (lista) {
                if (lista.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EstadoVacio(
                      icono: Icons.add_circle_outline_rounded,
                      titulo: 'Sesión vacía',
                      detalle: 'Busca un ejercicio en el catálogo y añádelo aquí.',
                      accion: 'Ir al catálogo',
                      onAccion: () => context.go('/ejercicios'),
                    ),
                  );
                }

                // Agrupamos por ejercicio conservando el orden de aparicion.
                final grupos = <String, List<Serie>>{};
                for (final s in lista) {
                  grupos.putIfAbsent(s.ejercicioId, () => []).add(s);
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 160),
                  sliver: SliverList.list(
                    children: [
                      for (final entrada in grupos.entries)
                        _BloqueEjercicio(
                          sesionId: sesionId,
                          ejercicioId: entrada.key,
                          series: entrada.value,
                          editable: activa,
                        ),
                      const SizedBox(height: G.e4),
                      if (activa)
                        BotonGlass(
                          texto: 'Añadir otro ejercicio',
                          icono: Icons.add_rounded,
                          expandido: true,
                          onTap: () => context.go('/ejercicios'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),

        if (activa) const Positioned(left: 0, right: 0, bottom: 0, child: RestTimerBar()),
      ],
    );
  }

  Future<void> _confirmarTerminar(BuildContext context, WidgetRef ref) async {
    final guardada = await terminarSesion(ref, sesionId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardada
              ? 'Entrenamiento guardado'
              // Si no se completo ninguna serie no guardamos nada: un registro
              // vacio solo ensuciaria el historial y las estadisticas.
              : 'Sesión descartada: no completaste ninguna serie',
        ),
      ),
    );
    context.pop();
  }
}

// --------------------------------------------------------------- un bloque ---

class _BloqueEjercicio extends ConsumerWidget {
  const _BloqueEjercicio({
    required this.sesionId,
    required this.ejercicioId,
    required this.series,
    required this.editable,
  });

  final int sesionId;
  final String ejercicioId;
  final List<Serie> series;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicio = ref.watch(ejercicioProvider(ejercicioId));
    final nombre = ejercicio?.nombre ?? 'Ejercicio $ejercicioId';
    final sub = ejercicio == null
        ? ''
        : '${ejercicio.objetivoEsLabel} · ${ejercicio.equipoEsLabel}';

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e4),
      child: GlassCard(
        padding: const EdgeInsets.all(G.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: T.cuerpoFuerte,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sub.isNotEmpty)
                        Text(sub, style: T.etiqueta.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/ejercicio/$ejercicioId'),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(G.e1),
                    child: Icon(Icons.info_outline_rounded, size: 18, color: G.textoBajo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: G.e4),

            // Cabecera de columnas.
            Row(
              children: [
                SizedBox(width: 26, child: Text('#', style: T.overline)),
                const SizedBox(width: G.e2),
                Expanded(child: Text('KG', style: T.overline)),
                const SizedBox(width: G.e2),
                Expanded(child: Text('REPS', style: T.overline)),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: G.e2),

            for (var i = 0; i < series.length; i++)
              _FilaSerie(
                serie: series[i],
                numero: i + 1,
                editable: editable,
              ),

            if (editable) ...[
              const SizedBox(height: G.e2),
              GestureDetector(
                onTap: () async {
                  final db = ref.read(baseDatosProvider);
                  final ultima = series.last;
                  await db.anadirSerie(
                    sesionId: sesionId,
                    ejercicioId: ejercicioId,
                    orden: ultima.orden + 1,
                    // Arrastra la carga de la ultima serie: casi siempre se
                    // repite el mismo peso.
                    repeticiones: ultima.repeticiones,
                    pesoKg: ultima.pesoKg,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: G.e3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: G.brS,
                    color: G.cristalRelleno,
                  ),
                  child: Text(
                    '+ Serie',
                    style: T.etiqueta.copyWith(
                      color: G.textoMedio,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- una fila ---

class _FilaSerie extends ConsumerStatefulWidget {
  const _FilaSerie({
    required this.serie,
    required this.numero,
    required this.editable,
  });

  final Serie serie;
  final int numero;
  final bool editable;

  @override
  ConsumerState<_FilaSerie> createState() => _FilaSerieState();
}

class _FilaSerieState extends ConsumerState<_FilaSerie> {
  late final _peso = TextEditingController(text: _fmt(widget.serie.pesoKg));
  late final _reps = TextEditingController(text: '${widget.serie.repeticiones}');

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  @override
  void dispose() {
    _peso.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FilaSerie old) {
    super.didUpdateWidget(old);
    // Solo sincronizamos desde la base si el campo no tiene el foco: si no,
    // el cursor saltaria al final mientras se escribe.
    if (widget.serie.pesoKg != old.serie.pesoKg) {
      final t = _fmt(widget.serie.pesoKg);
      if (_peso.text != t) _peso.text = t;
    }
    if (widget.serie.repeticiones != old.serie.repeticiones) {
      final t = '${widget.serie.repeticiones}';
      if (_reps.text != t) _reps.text = t;
    }
  }

  void _detalleSerie(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleSerie(serie: widget.serie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(baseDatosProvider);
    final hecha = widget.serie.hecha;

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e2),
      child: Row(
        children: [
          // El número abre el detalle de la serie (tipo + RPE). El RPE, si
          // existe, aparece como subíndice para no ocupar otra columna.
          GestureDetector(
            onTap: !widget.editable ? null : () => _detalleSerie(context),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 26,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.numero}',
                        style: T.cuerpoFuerte.copyWith(
                          fontSize: 13,
                          color: widget.serie.tipo == TipoSerie.calentamiento
                              ? G.acentoCalorias
                              : widget.serie.tipo == TipoSerie.fallo
                                  ? G.error
                                  : hecha
                                      ? G.exito
                                      : G.textoBajo,
                        ),
                      ),
                    ],
                  ),
                  if (widget.serie.rpe != null)
                    Text('R${widget.serie.rpe}',
                        style: T.etiqueta.copyWith(fontSize: 8.5, color: G.textoTenue)),
                ],
              ),
            ),
          ),
          const SizedBox(width: G.e2),
          Expanded(
            child: _CampoNumero(
              controlador: _peso,
              habilitado: widget.editable,
              decimal: true,
              onCambio: (v) => db.actualizarSerie(
                widget.serie.id,
                pesoKg: double.tryParse(v.replaceAll(',', '.')) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: G.e2),
          Expanded(
            child: _CampoNumero(
              controlador: _reps,
              habilitado: widget.editable,
              onCambio: (v) => db.actualizarSerie(
                widget.serie.id,
                repeticiones: int.tryParse(v) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: G.e2),
          GestureDetector(
            onTap: !widget.editable
                ? null
                : () {
                    final nueva = !hecha;
                    db.actualizarSerie(widget.serie.id, hecha: nueva);
                    if (nueva) {
                      HapticFeedback.mediumImpact();
                      // Completar una serie arranca el descanso, apuntando a
                      // esta serie: al terminar, el tiempo real se guarda en ella.
                      ref
                          .read(restTimerProvider.notifier)
                          .arrancar(RestTimer.segundosPorDefecto, widget.serie.id);
                    }
                  },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: G.rapido,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: hecha ? G.exito.withValues(alpha: 0.24) : G.cristalRelleno,
                border: Border.all(
                  color: hecha ? G.exito.withValues(alpha: 0.6) : G.cristalBorde,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 18,
                color: hecha ? G.exito : G.textoTenue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoNumero extends StatelessWidget {
  const _CampoNumero({
    required this.controlador,
    required this.onCambio,
    required this.habilitado,
    this.decimal = false,
  });

  final TextEditingController controlador;
  final ValueChanged<String> onCambio;
  final bool habilitado;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      onChanged: onCambio,
      enabled: habilitado,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
        ),
      ],
      style: T.cuerpoFuerte.copyWith(fontSize: 14),
      cursorColor: G.acentoEjercicio,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: G.e2),
      ),
    );
  }
}

/// Detalle de una serie: tipo (normal/calentamiento/fallo) y RPE. El RPE se
/// registra tras completar la serie; es clave para leer el esfuerzo real más
/// allá del peso levantado.
class _DetalleSerie extends ConsumerWidget {
  const _DetalleSerie({required this.serie});

  final Serie serie;

  static const _tipos = {
    TipoSerie.normal: ('Normal', G.acentoEjercicio),
    TipoSerie.calentamiento: ('Calentamiento', G.acentoCalorias),
    TipoSerie.fallo: ('Al fallo', G.error),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(baseDatosProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(G.radioL)),
      child: Container(
        color: G.fondoAlto,
        padding: const EdgeInsets.fromLTRB(G.e5, G.e3, G.e5, G.e8),
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
            Text('Tipo de serie', style: T.overline),
            const SizedBox(height: G.e3),
            Row(
              children: [
                for (final e in _tipos.entries) ...[
                  Expanded(
                    child: GlassChip(
                      texto: e.value.$1,
                      color: e.value.$2,
                      activo: serie.tipo == e.key,
                      onTap: () => db.update(db.series).replace(
                            serie.copyWith(tipo: e.key),
                          ),
                    ),
                  ),
                  if (e.key != TipoSerie.fallo) const SizedBox(width: G.e2),
                ],
              ],
            ),
            const SizedBox(height: G.e6),
            Row(
              children: [
                Text('Esfuerzo percibido (RPE)', style: T.overline),
                const Spacer(),
                Text(
                  serie.rpe == null ? '—' : '${serie.rpe}',
                  style: T.cuerpoFuerte.copyWith(color: G.acentoPulso, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: G.e3),
            Wrap(
              spacing: G.e2,
              runSpacing: G.e2,
              children: [
                for (var r = 1; r <= 10; r++)
                  GestureDetector(
                    onTap: () => db.actualizarSerie(
                      serie.id,
                      // Tocar el RPE ya puesto lo quita.
                      rpe: serie.rpe == r ? null : r,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: G.brS,
                        color: serie.rpe == r
                            ? G.acentoPulso.withValues(alpha: 0.24)
                            : G.cristalRelleno,
                        border: Border.all(
                          color: serie.rpe == r
                              ? G.acentoPulso.withValues(alpha: 0.6)
                              : G.cristalBorde,
                        ),
                      ),
                      child: Text(
                        '$r',
                        style: T.cuerpoFuerte.copyWith(
                          color: serie.rpe == r ? G.acentoPulso : G.textoMedio,
                          fontWeight:
                              serie.rpe == r ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: G.e5),
            Center(
              child: Text(
                'Cierra deslizando hacia abajo',
                style: T.etiqueta.copyWith(fontSize: 11, color: G.textoTenue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
