import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'domain/exercise.dart';
import 'domain/taxonomy_es.dart';
import 'exercise_providers.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = ref.watch(ejerciciosFiltradosProvider);
    final filtro = ref.watch(filtroEjerciciosProvider);
    final ctrl = ref.read(filtroEjerciciosProvider.notifier);
    final repo = ref.watch(repositorioEjerciciosProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              G.e4,
              MediaQuery.paddingOf(context).top + G.e4,
              G.e4,
              G.e3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Ejercicios', style: T.titulo),
                    const Spacer(),
                    resultado.when(
                      data: (l) => Text('${l.length}', style: T.etiqueta),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: G.e4),
                _Buscador(controlador: _texto, onCambio: ctrl.consulta),
              ],
            ),
          ),
        ),

        // Filtros. La zona es el filtro principal (10 valores), asi que va
        // siempre visible; equipo y musculo se abren en hoja aparte para no
        // llenar la pantalla con 28 y 19 chips.
        repo.maybeWhen(
          data: (r) => SliverToBoxAdapter(
            child: _FilaFiltros(
              zonas: r.catalogo.zonas,
              filtro: filtro,
              onZona: ctrl.zona,
              onMas: () => _abrirFiltros(context, r.catalogo),
              onLimpiar: ctrl.limpiar,
            ),
          ),
          orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        resultado.when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: EstadoVacio(
              icono: Icons.error_outline_rounded,
              titulo: 'No se pudo cargar el catálogo',
              detalle: '$e',
            ),
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: EstadoVacio(
                  icono: Icons.search_off_rounded,
                  titulo: 'Sin resultados',
                  detalle: 'Prueba con otro término o quita algún filtro.',
                  accion: filtro.vacio ? null : 'Limpiar filtros',
                  onAccion: ctrl.limpiar,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(G.e4, G.e2, G.e4, 120),
              sliver: SliverList.separated(
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: G.e3),
                itemBuilder: (_, i) => _FilaEjercicio(
                  ejercicio: lista[i],
                  urlMiniatura: repo.value!.catalogo.miniaturaDe(lista[i]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _abrirFiltros(BuildContext context, CatalogoEjercicios catalogo) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HojaFiltros(catalogo: catalogo),
    );
  }
}

// ----------------------------------------------------------------- buscador ---

class _Buscador extends StatelessWidget {
  const _Buscador({required this.controlador, required this.onCambio});

  final TextEditingController controlador;
  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: G.e4),
      radio: G.brS,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: G.textoBajo),
          const SizedBox(width: G.e3),
          Expanded(
            child: TextField(
              controller: controlador,
              onChanged: onCambio,
              style: T.cuerpo.copyWith(color: G.textoAlto),
              cursorColor: G.acentoEjercicio,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                // Pista de que el buscador entiende castellano aunque el
                // catalogo este en ingles.
                hintText: 'Sentadilla, press banca, dominadas…',
                hintStyle: T.cuerpo.copyWith(color: G.textoTenue),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: G.e4),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controlador,
            builder: (_, valor, _) => valor.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      controlador.clear();
                      onCambio('');
                    },
                    child: const Icon(Icons.close_rounded, size: 18, color: G.textoBajo),
                  ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ filtros ---

class _FilaFiltros extends StatelessWidget {
  const _FilaFiltros({
    required this.zonas,
    required this.filtro,
    required this.onZona,
    required this.onMas,
    required this.onLimpiar,
  });

  final List<String> zonas;
  final FiltroEjercicios filtro;
  final ValueChanged<String?> onZona;
  final VoidCallback onMas;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: G.e4),
        children: [
          GlassChip(
            texto: filtro.activos > 0 ? 'Filtros · ${filtro.activos}' : 'Filtros',
            icono: Icons.tune_rounded,
            activo: filtro.activos > 0,
            onTap: onMas,
          ),
          if (!filtro.vacio) ...[
            const SizedBox(width: G.e2),
            GlassChip(texto: 'Limpiar', icono: Icons.close_rounded, onTap: onLimpiar),
          ],
          const SizedBox(width: G.e2),
          const _Separador(),
          for (final z in zonas) ...[
            const SizedBox(width: G.e2),
            GlassChip(
              texto: zonaEs(z),
              activo: filtro.zona == z,
              onTap: () => onZona(z),
            ),
          ],
          const SizedBox(width: G.e4),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: G.e2),
        color: G.cristalBorde,
      );
}

class _HojaFiltros extends ConsumerWidget {
  const _HojaFiltros({required this.catalogo});

  final CatalogoEjercicios catalogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroEjerciciosProvider);
    final ctrl = ref.read(filtroEjerciciosProvider.notifier);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.9,
      builder: (_, scroll) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(G.radioL)),
        child: Container(
          color: G.fondoAlto,
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(G.e5, G.e3, G.e5, G.e10),
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
              Text('Equipamiento', style: T.overline),
              const SizedBox(height: G.e3),
              Wrap(
                spacing: G.e2,
                runSpacing: G.e2,
                children: [
                  for (final e in catalogo.equipos)
                    GlassChip(
                      texto: equipoEsDe(e),
                      activo: filtro.equipo == e,
                      onTap: () => ctrl.equipo(e),
                    ),
                ],
              ),
              const SizedBox(height: G.e6),
              Text('Músculo objetivo', style: T.overline),
              const SizedBox(height: G.e3),
              Wrap(
                spacing: G.e2,
                runSpacing: G.e2,
                children: [
                  for (final o in catalogo.objetivos)
                    GlassChip(
                      texto: musculoEs(o),
                      activo: filtro.objetivo == o,
                      color: G.acentoPulso,
                      onTap: () => ctrl.objetivo(o),
                    ),
                ],
              ),
              const SizedBox(height: G.e6),
              BotonGlass(
                texto: 'Ver resultados',
                expandido: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------- fila ---

class _FilaEjercicio extends StatelessWidget {
  const _FilaEjercicio({required this.ejercicio, required this.urlMiniatura});

  final Ejercicio ejercicio;
  final String urlMiniatura;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      // Sin BackdropFilter: son cientos de filas con scroll y cada desenfoque
      // es una pasada de GPU. Ver la nota en GlassCard.
      desenfocar: false,
      padding: const EdgeInsets.all(G.e3),
      radio: G.brS,
      onTap: () => context.push('/ejercicio/${ejercicio.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              // Fondo claro: las miniaturas del dataset son ilustraciones sobre
              // blanco y sobre cristal oscuro se verian recortadas.
              color: Colors.white.withValues(alpha: 0.92),
              child: CachedNetworkImage(
                imageUrl: urlMiniatura,
                fit: BoxFit.cover,
                fadeInDuration: G.rapido,
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const Icon(
                  Icons.fitness_center_rounded,
                  size: 20,
                  color: Colors.black26,
                ),
              ),
            ),
          ),
          const SizedBox(width: G.e4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ejercicio.nombre,
                  style: T.cuerpoFuerte.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${ejercicio.objetivoEsLabel} · ${ejercicio.equipoEsLabel}',
                  style: T.etiqueta.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: G.textoTenue),
        ],
      ),
    );
  }
}
