import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/glass_bits.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';
import 'muscle_coverage.dart';
import 'muscle_map.dart';
import 'muscle_map_view.dart';

enum _Modo { planeado, hecho, calor }

/// Tarjeta de equilibrio muscular con tres vistas:
///  - **Planeado**: músculos que cubren tus rutinas.
///  - **Hecho**: músculos que de verdad entrenaste (30 días).
///  - **Calor**: mapa de calor de los músculos más trabajados por volumen.
class MuscleBalanceCard extends ConsumerStatefulWidget {
  const MuscleBalanceCard({super.key});

  @override
  ConsumerState<MuscleBalanceCard> createState() => _MuscleBalanceCardState();
}

class _MuscleBalanceCardState extends ConsumerState<MuscleBalanceCard> {
  _Modo _modo = _Modo.planeado;

  @override
  Widget build(BuildContext context) {
    final planeado = ref.watch(coberturaMuscularProvider);
    final real = ref.watch(balanceRealProvider).value;
    final intensidad = ref.watch(intensidadMuscularProvider).value ?? const {};

    final hayPlan = planeado.primarios.isNotEmpty || planeado.secundarios.isNotEmpty;
    final hayReal = real != null && (real.primarios.isNotEmpty || real.secundarios.isNotEmpty);
    if (!hayPlan && !hayReal) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EncabezadoSeccion(titulo: 'Tu equilibrio muscular'),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle de 3 modos.
              Row(
                children: [
                  _Toggle(texto: 'Planeado', activo: _modo == _Modo.planeado,
                      onTap: () => setState(() => _modo = _Modo.planeado)),
                  const SizedBox(width: G.e2),
                  _Toggle(texto: 'Hecho', activo: _modo == _Modo.hecho,
                      onTap: () => setState(() => _modo = _Modo.hecho)),
                  const SizedBox(width: G.e2),
                  _Toggle(texto: 'Calor', icono: Icons.local_fire_department_rounded,
                      activo: _modo == _Modo.calor,
                      onTap: () => setState(() => _modo = _Modo.calor)),
                ],
              ),
              const SizedBox(height: G.e4),

              if (_modo == _Modo.calor)
                _VistaCalor(intensidad: intensidad)
              else
                _VistaCobertura(
                  cobertura: _modo == _Modo.hecho
                      ? (real ?? (primarios: <String>{}, secundarios: <String>{}))
                      : planeado,
                  esHecho: _modo == _Modo.hecho,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vista de cobertura (Planeado / Hecho): silueta binaria + grupos que faltan.
class _VistaCobertura extends StatelessWidget {
  const _VistaCobertura({required this.cobertura, required this.esHecho});

  final Cobertura cobertura;
  final bool esHecho;

  @override
  Widget build(BuildContext context) {
    final cubiertosSet = {...cobertura.primarios, ...cobertura.secundarios};
    final faltan = musculosPrincipales.difference(cubiertosSet);
    final total = musculosPrincipales.length;
    final cubiertos = total - faltan.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$cubiertos', style: T.display.copyWith(fontSize: 30)),
            Text(' / $total', style: T.unidad),
            const SizedBox(width: G.e2),
            Text(esHecho ? 'grupos entrenados' : 'grupos que trabajas', style: T.etiqueta),
          ],
        ),
        const SizedBox(height: G.e3),
        MuscleMapView(
          primarios: cobertura.primarios,
          secundarios: cobertura.secundarios.difference(cobertura.primarios),
          altura: 210,
        ),
        const SizedBox(height: G.e4),
        if (esHecho && cubiertosSet.isEmpty)
          Text(
            'Aún no has registrado entrenamientos estos 30 días. Cuando completes '
            'sesiones, aquí verás lo que de verdad trabajaste.',
            style: T.cuerpo.copyWith(fontSize: 13),
          )
        else if (faltan.isEmpty)
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: G.exito),
              const SizedBox(width: G.e2),
              Expanded(
                child: Text(
                  esHecho ? '¡Entrenaste todos los grupos principales!' : '¡Cubres todos los grupos principales!',
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
              Text(esHecho ? 'No entrenaste' : 'Te falta trabajar',
                  style: T.overline.copyWith(color: G.alerta)),
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
    );
  }
}

/// Vista mapa de calor: la silueta coloreada por volumen y los más trabajados.
class _VistaCalor extends StatelessWidget {
  const _VistaCalor({required this.intensidad});

  final Map<String, double> intensidad;

  @override
  Widget build(BuildContext context) {
    if (intensidad.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: G.e5),
        child: Text(
          'Registra entrenamientos para ver qué músculos trabajas más. El mapa '
          'de calor usa el volumen (peso × reps) de tus últimos 30 días.',
          style: T.cuerpo.copyWith(fontSize: 13),
        ),
      );
    }

    // Los 3 músculos más trabajados.
    final orden = intensidad.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = orden.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Músculos más trabajados', style: T.overline),
        const SizedBox(height: G.e2),
        MuscleMapView(intensidad: intensidad, altura: 210),
        const SizedBox(height: G.e4),

        // Podio de los tres primeros.
        for (var i = 0; i < top.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: G.e2),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorCalor(top[i].value),
                  ),
                  child: Text('${i + 1}',
                      style: T.etiqueta.copyWith(
                          fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: G.e3),
                Expanded(child: Text(nombreSlug(top[i].key), style: T.cuerpoFuerte.copyWith(fontSize: 14))),
                // Barra de intensidad relativa.
                SizedBox(
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: top[i].value,
                      minHeight: 6,
                      backgroundColor: G.cristalRelleno,
                      valueColor: AlwaysStoppedAnimation(colorCalor(top[i].value)),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: G.e2),
        // Leyenda del gradiente.
        Row(
          children: [
            Text('menos', style: T.etiqueta.copyWith(fontSize: 10)),
            const SizedBox(width: G.e2),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [colorCalor(0), colorCalor(0.5), colorCalor(1)],
                  ),
                ),
              ),
            ),
            const SizedBox(width: G.e2),
            Text('más', style: T.etiqueta.copyWith(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.texto,
    required this.activo,
    required this.onTap,
    this.icono,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final color = activo ? G.acentoEjercicio : G.textoBajo;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: G.e3, vertical: G.e2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: activo ? G.acentoEjercicio.withValues(alpha: 0.18) : G.cristalRelleno,
          border: Border.all(
            color: activo ? G.acentoEjercicio.withValues(alpha: 0.5) : G.cristalBorde,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              texto,
              style: T.etiqueta.copyWith(
                color: color,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
