import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_card.dart';
import '../../theme/glass_tokens.dart';

@immutable
class EstadoDescanso {
  const EstadoDescanso({this.restante = 0, this.total = 0});

  final int restante;
  final int total;

  bool get activo => restante > 0;
  double get progreso => total == 0 ? 0 : restante / total;
}

/// Cronometro de descanso entre series.
///
/// Se dispara al marcar una serie como hecha. Vive en un provider y no en el
/// estado de la pantalla para que siga corriendo si navegas a la ficha de un
/// ejercicio a mitad del descanso.
class RestTimer extends Notifier<EstadoDescanso> {
  Timer? _t;

  /// Serie que disparó el descanso; al terminar se le escribe el tiempo real.
  int? _serieId;
  DateTime? _arranque;

  @override
  EstadoDescanso build() {
    ref.onDispose(() => _t?.cancel());
    return const EstadoDescanso();
  }

  static const segundosPorDefecto = 90;

  /// [serieId], si se pasa, recibe el descanso realmente transcurrido cuando el
  /// cronómetro termina o se salta: así el registro guarda el descanso real, no
  /// el objetivo.
  void arrancar([int segundos = segundosPorDefecto, int? serieId]) {
    // Si había un descanso anterior en curso, primero cerramos su registro.
    _registrar();
    _t?.cancel();
    _serieId = serieId;
    _arranque = DateTime.now();
    state = EstadoDescanso(restante: segundos, total: segundos);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      final r = state.restante - 1;
      if (r <= 0) {
        t.cancel();
        _registrar();
        state = const EstadoDescanso();
        HapticFeedback.heavyImpact();
      } else {
        state = EstadoDescanso(restante: r, total: state.total);
      }
    });
  }

  /// Suma tiempo sin reiniciar; el total crece para que la barra no retroceda.
  void sumar(int segundos) {
    if (!state.activo) return;
    state = EstadoDescanso(
      restante: state.restante + segundos,
      total: state.total + segundos,
    );
  }

  void saltar() {
    _t?.cancel();
    _registrar();
    state = const EstadoDescanso();
  }

  /// Escribe el descanso transcurrido en la serie que lo disparó, si la hubo.
  void _registrar() {
    final id = _serieId;
    final desde = _arranque;
    _serieId = null;
    _arranque = null;
    if (id == null || desde == null) return;
    final seg = DateTime.now().difference(desde).inSeconds;
    if (seg > 0) {
      ref.read(baseDatosProvider).actualizarSerie(id, descansoSeg: seg);
    }
  }
}

final restTimerProvider =
    NotifierProvider<RestTimer, EstadoDescanso>(RestTimer.new);

/// Barra de descanso anclada al fondo de la sesion.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(restTimerProvider);
    final ctrl = ref.read(restTimerProvider.notifier);

    // Se desliza hacia fuera cuando no hay descanso en curso, en vez de
    // desaparecer de golpe.
    return AnimatedSlide(
      offset: estado.activo ? Offset.zero : const Offset(0, 1.4),
      duration: G.normal,
      curve: G.curvaSuave,
      child: AnimatedOpacity(
        opacity: estado.activo ? 1 : 0,
        duration: G.rapido,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            G.e4,
            0,
            G.e4,
            MediaQuery.paddingOf(context).bottom + G.e4,
          ),
          child: GlassCard(
            tinte: G.acentoActividad,
            resaltado: true,
            padding: const EdgeInsets.all(G.e4),
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    '${estado.restante ~/ 60}:${(estado.restante % 60).toString().padLeft(2, '0')}',
                    style: T.cuerpoFuerte.copyWith(fontSize: 19),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descanso', style: T.etiqueta.copyWith(fontSize: 11)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: estado.progreso,
                          minHeight: 4,
                          backgroundColor: G.cristalRelleno,
                          valueColor: const AlwaysStoppedAnimation(G.acentoActividad),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: G.e3),
                _MiniBoton(texto: '+15', onTap: () => ctrl.sumar(15)),
                const SizedBox(width: G.e2),
                _MiniBoton(icono: Icons.close_rounded, onTap: ctrl.saltar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBoton extends StatelessWidget {
  const _MiniBoton({this.texto, this.icono, required this.onTap});

  final String? texto;
  final IconData? icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: G.cristalRellenoAlto,
          border: Border.all(color: G.cristalBorde),
        ),
        child: icono != null
            ? Icon(icono, size: 17, color: G.textoMedio)
            : Text(
                texto!,
                style: T.etiqueta.copyWith(
                  fontSize: 12,
                  color: G.textoAlto,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
