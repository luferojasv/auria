import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import '../muscles/muscle_balance_card.dart';
import 'routine_actions.dart';
import 'start_workout_sheet.dart';
import 'weekly_plan.dart';
import 'workout_actions.dart';

class WorkoutsPage extends ConsumerWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enCurso = ref.watch(sesionEnCursoProvider);
    final historial = ref.watch(historialProvider);

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
            child: Text('Entrenar', style: T.titulo),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 120),
          sliver: SliverList.list(
            children: [
              // Qué toca hoy, según el plan semanal.
              TarjetaHoyToca(
                onEmpezar: () async {
                  final id = await obtenerOCrearSesion(ref);
                  if (context.mounted) context.push('/sesion/$id');
                },
              ),

              const EncabezadoSeccion(titulo: 'Tu semana'),
              const TiraSemana(),

              _SeccionRutinas(),

              const MuscleBalanceCard(),

              const EncabezadoSeccion(titulo: 'Sesión'),
              enCurso.when(
                loading: () => const SizedBox(height: 88),
                error: (e, _) => Text('$e', style: T.cuerpo),
                data: (s) => s == null
                    ? _TarjetaEmpezar(
                        onEmpezar: () => iniciarEntrenamiento(context, ref),
                      )
                    : _TarjetaEnCurso(sesion: s),
              ),

              const EncabezadoSeccion(titulo: 'Historial'),

              historial.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(G.e8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Text('$e', style: T.cuerpo),
                data: (lista) {
                  if (lista.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: G.e6),
                      child: EstadoVacio(
                        icono: Icons.history_rounded,
                        titulo: 'Aún no hay entrenamientos',
                        detalle:
                            'Cuando cierres tu primera sesión aparecerá aquí, '
                            'y con ella empezarán a llenarse tus estadísticas.',
                      ),
                    );
                  }
                  // Agrupamos por semana (lunes) para ver la constancia.
                  final grupos = <DateTime, List<Sesion>>{};
                  for (final s in lista) {
                    final d = DateTime(s.inicio.year, s.inicio.month, s.inicio.day);
                    final lunes = d.subtract(Duration(days: d.weekday - 1));
                    grupos.putIfAbsent(lunes, () => []).add(s);
                  }
                  final semanas = grupos.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  return Column(
                    children: [
                      for (final lunes in semanas) ...[
                        _EncabezadoSemana(lunes: lunes, dias: grupos[lunes]!.length),
                        for (final s in grupos[lunes]!) _FilaHistorial(sesion: s),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaEmpezar extends StatelessWidget {
  const _TarjetaEmpezar({required this.onEmpezar});

  final VoidCallback onEmpezar;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tinte: G.acentoEjercicio,
      padding: const EdgeInsets.all(G.e6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nada en marcha', style: T.seccion),
          const SizedBox(height: G.e1),
          Text(
            'Empieza desde una de tus rutinas —con los ejercicios ya cargados— '
            'o en blanco.',
            style: T.cuerpo,
          ),
          const SizedBox(height: G.e5),
          BotonGlass(
            texto: 'Empezar entrenamiento',
            icono: Icons.play_arrow_rounded,
            expandido: true,
            onTap: onEmpezar,
          ),
        ],
      ),
    );
  }
}

class _TarjetaEnCurso extends ConsumerWidget {
  const _TarjetaEnCurso({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesDeSesionProvider(sesion.id));
    final hechas = series.value?.where((s) => s.hecha).length ?? 0;
    final total = series.value?.length ?? 0;

    return GlassCard(
      tinte: G.exito,
      resaltado: true,
      padding: const EdgeInsets.all(G.e6),
      onTap: () => context.push('/sesion/${sesion.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: G.exito, shape: BoxShape.circle),
              ),
              const SizedBox(width: G.e2),
              Text('EN CURSO', style: T.overline.copyWith(color: G.exito)),
              const Spacer(),
              _Cronometro(desde: sesion.inicio),
            ],
          ),
          const SizedBox(height: G.e3),
          Text(sesion.nombre, style: T.seccion),
          const SizedBox(height: G.e1),
          Text(
            total == 0 ? 'Sin ejercicios todavía' : '$hechas de $total series completadas',
            style: T.cuerpo,
          ),
          if (total > 0) ...[
            const SizedBox(height: G.e4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: hechas / total,
                minHeight: 5,
                backgroundColor: G.cristalRelleno,
                valueColor: const AlwaysStoppedAnimation(G.exito),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cronometro que cuenta desde el inicio de la sesion.
class _Cronometro extends StatefulWidget {
  const _Cronometro({required this.desde});

  final DateTime desde;

  @override
  State<_Cronometro> createState() => _CronometroState();
}

class _CronometroState extends State<_Cronometro> {
  late final Stream<void> _tic =
      Stream.periodic(const Duration(seconds: 1)).asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _tic,
      builder: (_, _) {
        final d = DateTime.now().difference(widget.desde);
        final h = d.inHours;
        final m = d.inMinutes % 60;
        final s = d.inSeconds % 60;
        final texto = h > 0
            ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
            : '$m:${s.toString().padLeft(2, '0')}';
        return Text(texto, style: T.cuerpoFuerte.copyWith(fontSize: 14));
      },
    );
  }
}

class _FilaHistorial extends ConsumerWidget {
  const _FilaHistorial({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesDeSesionProvider(sesion.id));
    final lista = series.value ?? const [];
    final volumen = lista
        .where((s) => s.hecha && s.tipo != TipoSerie.calentamiento)
        .fold<double>(0, (a, s) => a + s.pesoKg * s.repeticiones);
    final duracion = sesion.fin == null
        ? Duration.zero
        : sesion.fin!.difference(sesion.inicio);

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e3),
      child: GlassCard(
        desenfocar: false,
        radio: G.brS,
        padding: const EdgeInsets.all(G.e4),
        onTap: () => context.push('/sesion/${sesion.id}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sesion.nombre,
                    style: T.cuerpoFuerte.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat("d MMM · HH:mm", 'es').format(sesion.inicio),
                    style: T.etiqueta.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  volumen >= 1000
                      ? '${(volumen / 1000).toStringAsFixed(1)} t'
                      : '${volumen.round()} kg',
                  style: T.cuerpoFuerte.copyWith(fontSize: 14),
                ),
                Text(
                  '${duracion.inMinutes} min · ${lista.where((s) => s.hecha).length} series',
                  style: T.etiqueta.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección "Mis rutinas" en la pestaña Entrenar: lista horizontal de rutinas
/// reutilizables, con acceso a crear una nueva y a editar/empezar cada una.
class _SeccionRutinas extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EncabezadoSeccion(
          titulo: 'Mis rutinas',
          accion: 'Nueva',
          onAccion: () => crearRutinaYEditar(context, ref),
        ),
        rutinas.when(
          loading: () => const SizedBox(height: 8),
          error: (e, _) => Text('$e', style: T.cuerpo),
          data: (lista) {
            if (lista.isEmpty) {
              return GlassCard(
                desenfocar: false,
                onTap: () => crearRutinaYEditar(context, ref),
                child: Row(
                  children: [
                    const Icon(Icons.playlist_add_rounded, color: G.acentoEjercicio),
                    const SizedBox(width: G.e3),
                    Expanded(
                      child: Text(
                        'Crea tu primera rutina: elige ejercicios del catálogo, '
                        'con su GIF, series y reps. Luego la asignas a los días.',
                        style: T.cuerpo.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final r in lista) _FilaRutina(rutina: r),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FilaRutina extends ConsumerWidget {
  const _FilaRutina({required this.rutina});

  final Rutina rutina;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicios = ref.watch(ejerciciosDeRutinaProvider(rutina.id)).value ?? const [];

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e3),
      child: GlassCard(
        desenfocar: false,
        radio: G.brS,
        padding: const EdgeInsets.all(G.e4),
        onTap: () => context.push('/rutina/${rutina.id}'),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: G.brS,
                color: G.acentoEjercicio.withValues(alpha: 0.14),
              ),
              child: const Icon(Icons.list_alt_rounded, size: 20, color: G.acentoEjercicio),
            ),
            const SizedBox(width: G.e4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rutina.nombre,
                      style: T.cuerpoFuerte.copyWith(fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    ejercicios.isEmpty
                        ? 'Sin ejercicios · toca para armarla'
                        : '${ejercicios.length} ejercicios',
                    style: T.etiqueta.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            // Empezar el entreno con esta rutina precargada.
            GestureDetector(
              onTap: ejercicios.isEmpty
                  ? null
                  : () async {
                      final id = await empezarSesionDesdeRutina(ref, rutina.id);
                      if (context.mounted) context.push('/sesion/$id');
                    },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(G.e2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ejercicios.isEmpty
                      ? G.cristalRelleno
                      : G.exito.withValues(alpha: 0.16),
                ),
                child: Icon(Icons.play_arrow_rounded,
                    size: 20,
                    color: ejercicios.isEmpty ? G.textoTenue : G.exito),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Encabezado de un grupo del historial: la semana y cuántos días se entrenó.
class _EncabezadoSemana extends StatelessWidget {
  const _EncabezadoSemana({required this.lunes, required this.dias});

  final DateTime lunes;
  final int dias;

  @override
  Widget build(BuildContext context) {
    final n = DateTime.now();
    final hoy = DateTime(n.year, n.month, n.day);
    final lunesActual = hoy.subtract(Duration(days: hoy.weekday - 1));
    final difSemanas = lunesActual.difference(lunes).inDays ~/ 7;

    final titulo = switch (difSemanas) {
      0 => 'Esta semana',
      1 => 'Semana pasada',
      _ => 'Semana del ${DateFormat('d MMM', 'es').format(lunes)}',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(G.e1, G.e5, G.e1, G.e3),
      child: Row(
        children: [
          Text(titulo, style: T.seccion),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: G.e3, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: G.exito.withValues(alpha: 0.14),
            ),
            child: Text(
              '$dias ${dias == 1 ? "día" : "días"}',
              style: T.etiqueta.copyWith(
                  fontSize: 11, color: G.exito, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
