import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'muscle_coverage.dart';
import 'muscle_map.dart';
import 'muscle_map_view.dart';

/// Tarjeta de equilibrio muscular: silueta con lo que trabajan TODAS tus
/// rutinas, y los grupos que te faltan. Se oculta si aún no hay rutinas con
/// ejercicios.
class MuscleBalanceCard extends ConsumerWidget {
  const MuscleBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cobertura = ref.watch(coberturaMuscularProvider);
    final faltan = ref.watch(musculosQueFaltanProvider);

    // Sin nada configurado todavía: no mostramos la tarjeta.
    if (cobertura.primarios.isEmpty && cobertura.secundarios.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = musculosPrincipales.length;
    final cubiertos = total - faltan.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EncabezadoSeccion(titulo: 'Tu equilibrio muscular'),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$cubiertos', style: T.display.copyWith(fontSize: 30)),
                  Text(' / $total', style: T.unidad),
                  const SizedBox(width: G.e2),
                  Text('grupos que trabajas', style: T.etiqueta),
                ],
              ),
              const SizedBox(height: G.e3),

              MuscleMapView(
                primarios: cobertura.primarios,
                secundarios: cobertura.secundarios.difference(cobertura.primarios),
                altura: 210,
              ),

              const SizedBox(height: G.e4),
              if (faltan.isEmpty)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: G.exito),
                    const SizedBox(width: G.e2),
                    Expanded(
                      child: Text('¡Cubres todos los grupos principales!',
                          style: T.cuerpoFuerte.copyWith(fontSize: 14, color: G.exito)),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: G.alerta),
                    const SizedBox(width: G.e2),
                    Text('Te falta trabajar', style: T.overline.copyWith(color: G.alerta)),
                  ],
                ),
                const SizedBox(height: G.e3),
                Wrap(
                  spacing: G.e2,
                  runSpacing: G.e2,
                  children: [
                    for (final s in faltan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: G.e3, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: G.alerta.withValues(alpha: 0.12),
                          border: Border.all(color: G.alerta.withValues(alpha: 0.30)),
                        ),
                        child: Text(nombreSlug(s),
                            style: T.etiqueta.copyWith(
                                fontSize: 12, color: G.alerta, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: G.e3),
              // Leyenda de colores.
              Row(
                children: [
                  _Punto(color: G.acentoPulso, texto: 'Principal'),
                  const SizedBox(width: G.e4),
                  _Punto(color: G.acentoEjercicio.withValues(alpha: 0.5), texto: 'Secundario'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(texto, style: T.etiqueta.copyWith(fontSize: 11)),
      ],
    );
  }
}
