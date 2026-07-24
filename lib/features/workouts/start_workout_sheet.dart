import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'routine_actions.dart';
import 'workout_actions.dart';

/// Inicia un entrenamiento. Si ya hay uno en curso, va a él. Si hay rutinas
/// guardadas, abre una hoja para empezar desde una (sin volver a "Mis rutinas")
/// o vacío. Si no hay rutinas, empieza directamente.
Future<void> iniciarEntrenamiento(BuildContext context, WidgetRef ref) async {
  final db = ref.read(baseDatosProvider);

  final abierta = await db.verSesionEnCurso().first;
  if (abierta != null) {
    if (context.mounted) context.push('/sesion/${abierta.id}');
    return;
  }

  final rutinas = await db.verRutinas().first;
  if (rutinas.isEmpty) {
    final id = await obtenerOCrearSesion(ref);
    if (context.mounted) context.push('/sesion/$id');
    return;
  }

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _HojaInicio(),
  );
}

class _HojaInicio extends ConsumerWidget {
  const _HojaInicio();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinas = ref.watch(rutinasProvider).value ?? const [];

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
            Text('Empezar entrenamiento', style: T.titulo),
            const SizedBox(height: G.e2),
            Text('Elige una rutina y se cargan sus ejercicios, o empieza en blanco.',
                style: T.etiqueta),
            const SizedBox(height: G.e5),

            Text('DESDE UNA RUTINA', style: T.overline),
            const SizedBox(height: G.e3),
            // Lista acotada por si hay muchas rutinas.
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final r in rutinas)
                      _OpcionRutina(
                        rutinaId: r.id,
                        nombre: r.nombre,
                        onTap: () async {
                          final id = await empezarSesionDesdeRutina(ref, r.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            context.push('/sesion/$id');
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: G.e5),
            BotonGlass(
              texto: 'Empezar en blanco',
              icono: Icons.add_rounded,
              color: G.acentoActividad,
              expandido: true,
              onTap: () async {
                final id = await obtenerOCrearSesion(ref);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.push('/sesion/$id');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionRutina extends ConsumerWidget {
  const _OpcionRutina({
    required this.rutinaId,
    required this.nombre,
    required this.onTap,
  });

  final int rutinaId;
  final String nombre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(ejerciciosDeRutinaProvider(rutinaId)).value?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: G.e2),
      child: GlassCard(
        desenfocar: false,
        radio: G.brS,
        padding: const EdgeInsets.all(G.e4),
        onTap: n == 0 ? null : onTap,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: G.brS,
                color: G.acentoEjercicio.withValues(alpha: 0.14),
              ),
              child: const Icon(Icons.list_alt_rounded, size: 18, color: G.acentoEjercicio),
            ),
            const SizedBox(width: G.e3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: T.cuerpoFuerte.copyWith(fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(n == 0 ? 'Sin ejercicios' : '$n ejercicios',
                      style: T.etiqueta.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded,
                size: 20, color: n == 0 ? G.textoTenue : G.exito),
          ],
        ),
      ),
    );
  }
}
