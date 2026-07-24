import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../features/exercises/domain/exercise.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';

/// Abre el catálogo como selector y devuelve el id del ejercicio elegido (o
/// null si se cierra sin elegir). Reutiliza el mismo catálogo y buscador que la
/// pestaña de Ejercicios, pero con estado propio para no interferir con ella.
Future<String?> elegirEjercicio(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _Picker(),
  );
}

class _Picker extends ConsumerStatefulWidget {
  const _Picker();

  @override
  ConsumerState<_Picker> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_Picker> {
  String _consulta = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositorioEjerciciosProvider).value;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      builder: (_, scroll) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(G.radioL)),
        child: Container(
          color: G.fondoAlto,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(G.e5, G.e3, G.e5, G.e3),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: G.e4),
                      decoration: BoxDecoration(
                        color: G.cristalBordeAlto,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Row(
                      children: [
                        Text('Elige un ejercicio', style: T.seccion),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(Icons.close_rounded, size: 20, color: G.textoBajo),
                        ),
                      ],
                    ),
                    const SizedBox(height: G.e3),
                    _Buscador(onCambio: (v) => setState(() => _consulta = v)),
                  ],
                ),
              ),
              Expanded(
                child: repo == null
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : _Lista(
                        resultados: repo.buscar(consulta: _consulta),
                        urlDe: repo.catalogo.miniaturaDe,
                        scroll: scroll,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador({required this.onCambio});

  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: G.e4),
      radio: G.brS,
      desenfocar: false,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: G.textoBajo),
          const SizedBox(width: G.e3),
          Expanded(
            child: TextField(
              onChanged: onCambio,
              autofocus: true,
              style: T.cuerpo.copyWith(color: G.textoAlto),
              cursorColor: G.acentoEjercicio,
              decoration: InputDecoration(
                hintText: 'Sentadilla, hip thrust…',
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
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.resultados,
    required this.urlDe,
    required this.scroll,
  });

  final List<Ejercicio> resultados;
  final String Function(Ejercicio) urlDe;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    if (resultados.isEmpty) {
      return Center(child: Text('Sin resultados', style: T.cuerpo));
    }
    return ListView.separated(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(G.e5, G.e2, G.e5, G.e8),
      itemCount: resultados.length,
      separatorBuilder: (_, _) => const SizedBox(height: G.e2),
      itemBuilder: (_, i) {
        final e = resultados[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(e.id),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: G.e2),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: Colors.white,
                    child: CachedNetworkImage(
                      imageUrl: urlDe(e),
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.fitness_center_rounded, size: 18, color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(width: G.e3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nombre,
                          style: T.cuerpoFuerte.copyWith(fontSize: 13.5),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${e.objetivoEsLabel} · ${e.equipoEsLabel}',
                          style: T.etiqueta.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline_rounded, size: 20, color: G.acentoEjercicio),
              ],
            ),
          ),
        );
      },
    );
  }
}
