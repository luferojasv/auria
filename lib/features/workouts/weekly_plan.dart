import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';

/// Iniciales de los días, lunes primero (índice 0 = lunes = weekday 1).
const _iniciales = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
const _nombresDia = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

/// Tira de los 7 días del plan semanal, con el día de hoy resaltado. Tocar un
/// día abre su edición.
class TiraSemana extends ConsumerWidget {
  const TiraSemana({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planSemanalProvider);
    final entrenados = ref.watch(diasEntrenadosSemanaProvider).value ?? const {};
    final hoy = DateTime.now().weekday; // 1..7

    return plan.when(
      loading: () => const SizedBox(height: 92),
      error: (e, _) => const SizedBox.shrink(),
      data: (dias) {
        // Aseguramos orden lunes..domingo aunque la BD los devuelva sueltos.
        final porDia = {for (final d in dias) d.dia: d};
        return SizedBox(
          height: 96,
          child: Row(
            children: [
              for (var i = 1; i <= 7; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 7 ? 0 : G.e2),
                    child: _ChipDia(
                      dia: porDia[i],
                      indice: i - 1,
                      esHoy: i == hoy,
                      entrenado: entrenados.contains(i),
                      onTap: () => _editarDia(context, ref, i, porDia[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _editarDia(BuildContext context, WidgetRef ref, int dia, DiaPlan? actual) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HojaEditarDia(dia: dia, actual: actual),
    );
  }
}

class _ChipDia extends StatelessWidget {
  const _ChipDia({
    required this.dia,
    required this.indice,
    required this.esHoy,
    required this.entrenado,
    required this.onTap,
  });

  final DiaPlan? dia;
  final int indice;
  final bool esHoy;

  /// True si esta semana ya se entrenó ese día.
  final bool entrenado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final descanso = dia?.descanso ?? false;
    final color = descanso ? G.acentoSueno : G.acentoEjercicio;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: G.rapido,
        decoration: BoxDecoration(
          borderRadius: G.brS,
          color: esHoy ? color.withValues(alpha: 0.20) : G.cristalRelleno,
          border: Border.all(
            color: esHoy ? color.withValues(alpha: 0.6) : G.cristalBorde,
            width: esHoy ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: G.e3, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _iniciales[indice],
              style: T.overline.copyWith(
                color: esHoy ? color : G.textoBajo,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            // Check verde si ya entrenaste ese día; si no, el icono del plan.
            Icon(
              entrenado
                  ? Icons.check_circle_rounded
                  : (descanso ? Icons.self_improvement_rounded : Icons.bolt_rounded),
              size: 16,
              color: entrenado ? G.exito : (esHoy ? color : G.textoTenue),
            ),
            const SizedBox(height: 5),
            // Solo la primera palabra del título, para que quepa en el chip.
            Text(
              _resumen(dia),
              style: T.etiqueta.copyWith(
                fontSize: 9.5,
                color: esHoy ? G.textoMedio : G.textoTenue,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static String _resumen(DiaPlan? d) {
    if (d == null) return '—';
    if (d.descanso) return 'Descanso';
    final g = d.grupos.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    return g.isEmpty ? d.titulo : g.take(2).join('\n');
  }
}

/// Selector de la rutina asignada a un día: un desplegable con tus rutinas y
/// una opción para dejarlo sin rutina.
class _SelectorRutina extends ConsumerWidget {
  const _SelectorRutina({required this.rutinaId, required this.onCambio});

  final int? rutinaId;
  final ValueChanged<int?> onCambio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasProvider).value ?? const [];

    if (rutinas.isEmpty) {
      return Text(
        'Aún no tienes rutinas. Créalas en "Mis rutinas" para poder asignarlas.',
        style: T.etiqueta.copyWith(fontSize: 12),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: G.e4),
      decoration: BoxDecoration(
        borderRadius: G.brS,
        color: G.cristalRelleno,
        border: Border.all(color: G.cristalBorde),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: rutinaId,
          isExpanded: true,
          dropdownColor: G.fondoAlto,
          borderRadius: G.brS,
          hint: Text('Sin rutina', style: T.cuerpo.copyWith(color: G.textoTenue)),
          icon: const Icon(Icons.expand_more_rounded, color: G.textoBajo),
          items: [
            DropdownMenuItem(value: null, child: Text('Sin rutina', style: T.cuerpo)),
            for (final r in rutinas)
              DropdownMenuItem(value: r.id, child: Text(r.nombre, style: T.cuerpo)),
          ],
          onChanged: onCambio,
        ),
      ),
    );
  }
}

/// Card prominente: qué toca hoy, con acceso a empezar.
class TarjetaHoyToca extends ConsumerWidget {
  const TarjetaHoyToca({super.key, required this.onEmpezar});

  final VoidCallback onEmpezar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoy = ref.watch(planDeHoyProvider);

    return hoy.maybeWhen(
      data: (d) {
        if (d == null) return const SizedBox.shrink();
        final descanso = d.descanso;
        final color = descanso ? G.acentoSueno : G.acentoEjercicio;

        return GlassCard(
          tinte: color,
          padding: const EdgeInsets.all(G.e5),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: G.brS,
                  color: color.withValues(alpha: 0.18),
                ),
                child: Icon(
                  descanso ? Icons.self_improvement_rounded : Icons.bolt_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: G.e4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOY · ${_nombresDia[DateTime.now().weekday - 1]}',
                        style: T.overline.copyWith(color: color)),
                    const SizedBox(height: 3),
                    Text(d.titulo, style: T.seccion, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (!descanso)
                GestureDetector(
                  onTap: onEmpezar,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: G.e4, vertical: G.e3),
                    decoration: BoxDecoration(
                      borderRadius: G.brS,
                      gradient: G.gradienteAcento(color),
                      boxShadow: G.halo(color, intensidad: 0.3),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _HojaEditarDia extends ConsumerStatefulWidget {
  const _HojaEditarDia({required this.dia, required this.actual});

  final int dia;
  final DiaPlan? actual;

  @override
  ConsumerState<_HojaEditarDia> createState() => _HojaEditarDiaState();
}

class _HojaEditarDiaState extends ConsumerState<_HojaEditarDia> {
  late final _titulo = TextEditingController(text: widget.actual?.titulo ?? '');
  late final _grupos = TextEditingController(text: widget.actual?.grupos ?? '');
  late bool _descanso = widget.actual?.descanso ?? false;
  late int? _rutinaId = widget.actual?.rutinaId;

  @override
  void dispose() {
    _titulo.dispose();
    _grupos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
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
              Text(_nombresDia[widget.dia - 1], style: T.titulo),
              const SizedBox(height: G.e5),
              Text('Título', style: T.overline),
              const SizedBox(height: G.e2),
              TextField(
                controller: _titulo,
                style: T.cuerpo.copyWith(color: G.textoAlto),
                cursorColor: G.acentoEjercicio,
                decoration: const InputDecoration(hintText: 'Ej. Glúteos + Piernas'),
              ),
              const SizedBox(height: G.e5),
              Text('Grupos musculares (separados por coma)', style: T.overline),
              const SizedBox(height: G.e2),
              TextField(
                controller: _grupos,
                style: T.cuerpo.copyWith(color: G.textoAlto),
                cursorColor: G.acentoEjercicio,
                decoration: const InputDecoration(hintText: 'Glúteos, Piernas'),
              ),
              const SizedBox(height: G.e5),
              Row(
                children: [
                  Expanded(
                    child: Text('Día de descanso', style: T.cuerpoFuerte),
                  ),
                  Switch(
                    value: _descanso,
                    activeThumbColor: G.acentoSueno,
                    onChanged: (v) => setState(() => _descanso = v),
                  ),
                ],
              ),

              // Rutina asignada (solo si no es descanso): al empezar el entreno
              // de este día, se precargan sus ejercicios.
              if (!_descanso) ...[
                const SizedBox(height: G.e5),
                Text('Rutina', style: T.overline),
                const SizedBox(height: G.e2),
                _SelectorRutina(
                  rutinaId: _rutinaId,
                  onCambio: (id) => setState(() => _rutinaId = id),
                ),
              ],

              const SizedBox(height: G.e6),
              BotonGlass(
                texto: 'Guardar',
                expandido: true,
                onTap: () async {
                  final db = ref.read(baseDatosProvider);
                  await db.guardarDiaPlan(
                    widget.dia,
                    titulo: _titulo.text.trim().isEmpty
                        ? (_descanso ? 'Descanso' : 'Entreno')
                        : _titulo.text.trim(),
                    grupos: _grupos.text.trim(),
                    descanso: _descanso,
                  );
                  // guardarDiaPlan no toca rutinaId; lo fijamos aparte.
                  await db.asignarRutinaADia(widget.dia, _descanso ? null : _rutinaId);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
