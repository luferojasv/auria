import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import '../muscles/muscle_map_view.dart';
import '../muscles/muscle_map.dart';
import '../workouts/workout_actions.dart';
import 'exercise_providers.dart';

class ExerciseDetailPage extends ConsumerWidget {
  const ExerciseDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicio = ref.watch(ejercicioProvider(id));
    final repo = ref.watch(repositorioEjerciciosProvider).value;

    if (ejercicio == null || repo == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final catalogo = repo.catalogo;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              backgroundColor: Colors.transparent,
              leading: const _BotonAtras(),
              flexibleSpace: FlexibleSpaceBar(
                background: _Animacion(url: catalogo.animacionDe(ejercicio)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(G.e4, G.e5, G.e4, 140),
              sliver: SliverList.list(
                children: [
                  Text(ejercicio.nombre, style: T.titulo),
                  const SizedBox(height: G.e4),
                  Wrap(
                    spacing: G.e2,
                    runSpacing: G.e2,
                    children: [
                      GlassChip(texto: ejercicio.zonaEsLabel, activo: true),
                      GlassChip(
                        texto: ejercicio.equipoEsLabel,
                        activo: true,
                        color: G.acentoActividad,
                      ),
                      GlassChip(
                        texto: ejercicio.objetivoEsLabel,
                        activo: true,
                        color: G.acentoPulso,
                      ),
                    ],
                  ),

                  const EncabezadoSeccion(titulo: 'Músculos implicados'),
                  GlassCard(
                    child: Column(
                      children: [
                        // Mapa muscular: principal en rosa, secundarios en violeta.
                        MuscleMapView(
                          primarios: {
                            ?slugDeMusculo(ejercicio.objetivo),
                          },
                          secundarios: {
                            ?slugDeMusculo(ejercicio.grupo),
                            for (final s in ejercicio.secundarios) ?slugDeMusculo(s),
                          },
                        ),
                        const Divider(height: G.e5),
                        _FilaMusculo(
                          etiqueta: 'Principal',
                          valor: ejercicio.objetivoEsLabel,
                          color: G.acentoPulso,
                        ),
                        if (ejercicio.grupo != null) ...[
                          const Divider(height: G.e5),
                          _FilaMusculo(
                            etiqueta: 'Grupo',
                            valor: ejercicio.grupoEsLabel,
                            color: G.acentoEjercicio,
                          ),
                        ],
                        if (ejercicio.secundarios.isNotEmpty) ...[
                          const Divider(height: G.e5),
                          _FilaMusculo(
                            etiqueta: 'Secundarios',
                            valor: ejercicio.secundariosEs.join(', '),
                            color: G.acentoSueno,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const EncabezadoSeccion(titulo: 'Cómo se hace'),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < ejercicio.pasos.length; i++) ...[
                          if (i > 0) const SizedBox(height: G.e4),
                          _Paso(numero: i + 1, texto: ejercicio.pasos[i]),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: G.e5),
                  Text(
                    catalogo.atribucionMedia,
                    style: T.etiqueta.copyWith(fontSize: 10.5, color: G.textoTenue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Accion principal anclada abajo: anadir a la sesion en curso.
        Positioned(
          left: G.e4,
          right: G.e4,
          bottom: MediaQuery.paddingOf(context).bottom + G.e5,
          child: BotonGlass(
            texto: 'Añadir al entrenamiento',
            icono: Icons.add_rounded,
            expandido: true,
            onTap: () => anadirEjercicioASesion(context, ref, ejercicio.id),
          ),
        ),
      ],
    );
  }
}

class _BotonAtras extends StatelessWidget {
  const _BotonAtras();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(G.e2),
      child: GlassCard(
        padding: EdgeInsets.zero,
        radio: BorderRadius.circular(999),
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, size: 20, color: G.textoAlto),
        ),
      ),
    );
  }
}

class _Animacion extends StatelessWidget {
  const _Animacion({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Los GIF del dataset vienen sobre fondo blanco; se muestran tal cual y
        // el degradado inferior los funde con el fondo oscuro de la app.
        ColoredBox(
          color: Colors.white.withValues(alpha: 0.94),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black26),
              ),
            ),
            errorWidget: (_, _, _) => const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.black26),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [G.fondo.withValues(alpha: 0), G.fondo],
              stops: const [0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilaMusculo extends StatelessWidget {
  const _FilaMusculo({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: G.e3),
        SizedBox(width: 92, child: Text(etiqueta, style: T.etiqueta)),
        Expanded(child: Text(valor, style: T.cuerpoFuerte.copyWith(fontSize: 14))),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.texto});

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: G.acentoEjercicio.withValues(alpha: 0.18),
            border: Border.all(color: G.acentoEjercicio.withValues(alpha: 0.4)),
          ),
          child: Text(
            '$numero',
            style: T.etiqueta.copyWith(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: G.e3),
        Expanded(child: Text(texto, style: T.cuerpo)),
      ],
    );
  }
}
