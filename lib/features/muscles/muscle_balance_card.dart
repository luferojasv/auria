import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'muscle_coverage.dart';
import 'muscle_map.dart';
import 'muscle_map_view.dart';

/// Tarjeta de equilibrio muscular con dos modos:
///  - **Planeado**: músculos que cubren todas tus rutinas.
///  - **Hecho**: músculos que de verdad entrenaste (últimos 30 días).
/// En ambos, marca los grupos principales que faltan.
class MuscleBalanceCard extends ConsumerStatefulWidget {
  const MuscleBalanceCard({super.key});

  @override
  ConsumerState<MuscleBalanceCard> createState() => _MuscleBalanceCardState();
}

class _MuscleBalanceCardState extends ConsumerState<MuscleBalanceCard> {
  bool _hecho = false;

  @override
  Widget build(BuildContext context) {
    final planeado = ref.watch(coberturaMuscularProvider);
    final real = ref.watch(balanceRealProvider).value;

    final cobertura = _hecho
        ? (real ?? (primarios: <String>{}, secundarios: <String>{}))
        : planeado;

    // Sin nada configurado ni entrenado: no mostramos la tarjeta.
    if (planeado.primarios.isEmpty &&
        planeado.secundarios.isEmpty &&
        (real == null || (real.primarios.isEmpty && real.secundarios.isEmpty))) {
      return const SizedBox.shrink();
    }

    final cubiertosSet = {...cobertura.primarios, ...cobertura.secundarios};
    final faltan = musculosPrincipales.difference(cubiertosSet);
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
              // Toggle Planeado / Hecho.
              Row(
                children: [
                  _Toggle(
                    texto: 'Planeado',
                    activo: !_hecho,
                    onTap: () => setState(() => _hecho = false),
                  ),
                  const SizedBox(width: G.e2),
                  _Toggle(
                    texto: 'Hecho · 30d',
                    activo: _hecho,
                    onTap: () => setState(() => _hecho = true),
                  ),
                ],
              ),
              const SizedBox(height: G.e4),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$cubiertos', style: T.display.copyWith(fontSize: 30)),
                  Text(' / $total', style: T.unidad),
                  const SizedBox(width: G.e2),
                  Text(
                    _hecho ? 'grupos entrenados' : 'grupos que trabajas',
                    style: T.etiqueta,
                  ),
                ],
              ),
              const SizedBox(height: G.e3),

              MuscleMapView(
                primarios: cobertura.primarios,
                secundarios: cobertura.secundarios.difference(cobertura.primarios),
                altura: 210,
              ),

              const SizedBox(height: G.e4),
              if (_hecho && cubiertosSet.isEmpty)
                Text(
                  'Aún no has registrado entrenamientos estos 30 días. Cuando '
                  'completes sesiones, aquí verás lo que de verdad trabajaste.',
                  style: T.cuerpo.copyWith(fontSize: 13),
                )
              else if (faltan.isEmpty)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: G.exito),
                    const SizedBox(width: G.e2),
                    Expanded(
                      child: Text(
                        _hecho
                            ? '¡Entrenaste todos los grupos principales!'
                            : '¡Cubres todos los grupos principales!',
                        style: T.cuerpoFuerte.copyWith(fontSize: 14, color: G.exito),
                      ),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: G.alerta),
                    const SizedBox(width: G.e2),
                    Text(
                      _hecho ? 'No entrenaste' : 'Te falta trabajar',
                      style: T.overline.copyWith(color: G.alerta),
                    ),
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
              Row(
                children: [
                  _Leyenda(color: G.acentoPulso, texto: 'Principal'),
                  const SizedBox(width: G.e4),
                  _Leyenda(color: G.acentoEjercicio.withValues(alpha: 0.5), texto: 'Secundario'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.texto, required this.activo, required this.onTap});

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: G.e4, vertical: G.e2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: activo ? G.acentoEjercicio.withValues(alpha: 0.18) : G.cristalRelleno,
          border: Border.all(
            color: activo ? G.acentoEjercicio.withValues(alpha: 0.5) : G.cristalBorde,
          ),
        ),
        child: Text(
          texto,
          style: T.etiqueta.copyWith(
            color: activo ? G.acentoEjercicio : G.textoBajo,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto});

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
