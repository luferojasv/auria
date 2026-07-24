import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import '../exercises/exercise_providers.dart';
import 'exercise_picker_sheet.dart';

/// Editor de una rutina: nombre y su lista de ejercicios (con GIF, series y
/// reps objetivo). Los ejercicios se eligen del catálogo.
class RoutineEditorPage extends ConsumerWidget {
  const RoutineEditorPage({super.key, required this.rutinaId});

  final int rutinaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicios = ref.watch(ejerciciosDeRutinaProvider(rutinaId));
    final db = ref.read(baseDatosProvider);

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
                  G.e3,
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
                    const SizedBox(width: G.e3),
                    Expanded(child: _Nombre(rutinaId: rutinaId)),
                  ],
                ),
              ),
            ),
            ejercicios.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (e, _) => SliverToBoxAdapter(child: Text('$e', style: T.cuerpo)),
              data: (lista) {
                if (lista.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EstadoVacio(
                      icono: Icons.playlist_add_rounded,
                      titulo: 'Rutina vacía',
                      detalle: 'Añade ejercicios del catálogo con el botón de abajo.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(G.e4, 0, G.e4, 160),
                  sliver: SliverList.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: G.e3),
                    itemBuilder: (_, i) => _FilaEjercicioRutina(
                      item: lista[i],
                      posicion: i + 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        Positioned(
          left: G.e4,
          right: G.e4,
          bottom: MediaQuery.paddingOf(context).bottom + G.e5,
          child: BotonGlass(
            texto: 'Añadir ejercicio',
            icono: Icons.add_rounded,
            expandido: true,
            onTap: () async {
              final id = await elegirEjercicio(context, ref);
              if (id == null) return;
              final actuales = await db.ejerciciosDeRutinaUnaVez(rutinaId);
              await db.anadirEjercicioARutina(
                rutinaId: rutinaId,
                ejercicioId: id,
                orden: actuales.isEmpty
                    ? 0
                    : actuales.map((e) => e.orden).reduce((a, b) => a > b ? a : b) + 1,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Nombre extends ConsumerStatefulWidget {
  const _Nombre({required this.rutinaId});

  final int rutinaId;

  @override
  ConsumerState<_Nombre> createState() => _NombreState();
}

class _NombreState extends ConsumerState<_Nombre> {
  final _ctrl = TextEditingController();
  bool _cargado = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Carga el nombre una vez.
    if (!_cargado) {
      ref.read(baseDatosProvider).rutinaPorId(widget.rutinaId).then((r) {
        if (mounted && r != null && _ctrl.text.isEmpty) _ctrl.text = r.nombre;
      });
      _cargado = true;
    }
    return TextField(
      controller: _ctrl,
      style: T.titulo,
      cursorColor: G.acentoEjercicio,
      textInputAction: TextInputAction.done,
      onChanged: (v) {
        if (v.trim().isNotEmpty) {
          ref.read(baseDatosProvider).renombrarRutina(widget.rutinaId, v.trim());
        }
      },
      decoration: const InputDecoration(
        hintText: 'Nombre de la rutina',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: G.e2),
      ),
    );
  }
}

class _FilaEjercicioRutina extends ConsumerWidget {
  const _FilaEjercicioRutina({required this.item, required this.posicion});

  final RutinaEjercicio item;
  final int posicion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicio = ref.watch(ejercicioProvider(item.ejercicioId));
    final repo = ref.watch(repositorioEjerciciosProvider).value;
    final db = ref.read(baseDatosProvider);
    final url = (ejercicio != null && repo != null)
        ? repo.catalogo.miniaturaDe(ejercicio)
        : null;

    return GlassCard(
      desenfocar: false,
      radio: G.brS,
      padding: const EdgeInsets.all(G.e3),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 52,
              height: 52,
              color: Colors.white,
              child: url == null
                  ? const Icon(Icons.fitness_center_rounded, color: Colors.black26)
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.fitness_center_rounded, color: Colors.black26),
                    ),
            ),
          ),
          const SizedBox(width: G.e3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ejercicio?.nombre ?? item.ejercicioId,
                  style: T.cuerpoFuerte.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: G.e2),
                Row(
                  children: [
                    _Ajuste(
                      valor: item.seriesObjetivo,
                      etiqueta: 'series',
                      onMenos: item.seriesObjetivo > 1
                          ? () => db.actualizarEjercicioRutina(item.id,
                              seriesObjetivo: item.seriesObjetivo - 1)
                          : null,
                      onMas: () => db.actualizarEjercicioRutina(item.id,
                          seriesObjetivo: item.seriesObjetivo + 1),
                    ),
                    const SizedBox(width: G.e3),
                    Text('×', style: T.cuerpo.copyWith(color: G.textoTenue)),
                    const SizedBox(width: G.e3),
                    _Ajuste(
                      valor: item.repsObjetivo,
                      etiqueta: 'reps',
                      onMenos: item.repsObjetivo > 1
                          ? () => db.actualizarEjercicioRutina(item.id,
                              repsObjetivo: item.repsObjetivo - 1)
                          : null,
                      onMas: () => db.actualizarEjercicioRutina(item.id,
                          repsObjetivo: item.repsObjetivo + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => db.quitarEjercicioRutina(item.id),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(G.e2),
              child: Icon(Icons.close_rounded, size: 18, color: G.textoTenue),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contador con - y + para series o reps objetivo.
class _Ajuste extends StatelessWidget {
  const _Ajuste({
    required this.valor,
    required this.etiqueta,
    required this.onMenos,
    required this.onMas,
  });

  final int valor;
  final String etiqueta;
  final VoidCallback? onMenos;
  final VoidCallback? onMas;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Paso(icono: Icons.remove_rounded, onTap: onMenos),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: G.e2),
          child: Column(
            children: [
              Text('$valor', style: T.cuerpoFuerte.copyWith(fontSize: 15)),
              Text(etiqueta, style: T.etiqueta.copyWith(fontSize: 9)),
            ],
          ),
        ),
        _Paso(icono: Icons.add_rounded, onTap: onMas),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.icono, required this.onTap});

  final IconData icono;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? G.cristalRelleno : G.acentoEjercicio.withValues(alpha: 0.14),
          border: Border.all(
            color: onTap == null ? G.cristalBorde : G.acentoEjercicio.withValues(alpha: 0.35),
          ),
        ),
        child: Icon(icono,
            size: 15, color: onTap == null ? G.textoTenue : G.acentoEjercicio),
      ),
    );
  }
}
