import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../theme/glass_tokens.dart';

/// Check-in previo al entrenamiento: cómo llegas. Ánimo, energía y dolor se
/// registran ANTES de entrenar para poder cruzarlos luego con el rendimiento.
Future<void> abrirContextoSesion(
  BuildContext context,
  WidgetRef ref,
  Sesion sesion,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HojaContexto(sesion: sesion),
  );
}

class _HojaContexto extends ConsumerStatefulWidget {
  const _HojaContexto({required this.sesion});

  final Sesion sesion;

  @override
  ConsumerState<_HojaContexto> createState() => _HojaContextoState();
}

class _HojaContextoState extends ConsumerState<_HojaContexto> {
  late Animo? _animo = widget.sesion.animoAntes;
  late int _energia = widget.sesion.energia ?? 7;
  late int _dolor = widget.sesion.dolor ?? 2;
  late final _lugar = TextEditingController(text: widget.sesion.lugar ?? '');

  @override
  void dispose() {
    _lugar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
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
              Text('¿Cómo llegas?', style: T.titulo),
              Text('Se guarda antes de entrenar para cruzarlo con tu rendimiento.',
                  style: T.etiqueta),
              const SizedBox(height: G.e6),

              Text('Ánimo', style: T.overline),
              const SizedBox(height: G.e3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final a in Animo.values)
                    _BotonAnimo(
                      animo: a,
                      seleccionado: _animo == a,
                      onTap: () => setState(() => _animo = a),
                    ),
                ],
              ),
              const SizedBox(height: G.e6),

              _SliderEscala(
                titulo: 'Energía',
                valor: _energia,
                color: G.acentoActividad,
                onChange: (v) => setState(() => _energia = v),
              ),
              const SizedBox(height: G.e5),
              _SliderEscala(
                titulo: 'Dolor muscular',
                valor: _dolor,
                color: G.acentoPulso,
                onChange: (v) => setState(() => _dolor = v),
              ),
              const SizedBox(height: G.e6),

              Text('Lugar', style: T.overline),
              const SizedBox(height: G.e2),
              TextField(
                controller: _lugar,
                style: T.cuerpo.copyWith(color: G.textoAlto),
                cursorColor: G.acentoEjercicio,
                decoration: const InputDecoration(hintText: 'Gimnasio, casa…'),
              ),
              const SizedBox(height: G.e6),

              BotonGlass(
                texto: 'Guardar',
                expandido: true,
                onTap: () async {
                  await ref.read(baseDatosProvider).actualizarContextoSesion(
                        widget.sesion.id,
                        lugar: _lugar.text.trim().isEmpty ? null : _lugar.text.trim(),
                        animo: _animo,
                        energia: _energia,
                        dolor: _dolor,
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonAnimo extends StatelessWidget {
  const _BotonAnimo({
    required this.animo,
    required this.seleccionado,
    required this.onTap,
  });

  final Animo animo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: G.rapido,
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: G.e3),
        decoration: BoxDecoration(
          borderRadius: G.brS,
          color: seleccionado
              ? G.acentoEjercicio.withValues(alpha: 0.20)
              : G.cristalRelleno,
          border: Border.all(
            color: seleccionado
                ? G.acentoEjercicio.withValues(alpha: 0.6)
                : G.cristalBorde,
          ),
        ),
        child: Column(
          children: [
            Text(animo.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              animo.etiqueta,
              style: T.etiqueta.copyWith(
                fontSize: 9,
                color: seleccionado ? G.acentoEjercicio : G.textoBajo,
                fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderEscala extends StatelessWidget {
  const _SliderEscala({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.onChange,
  });

  final String titulo;
  final int valor;
  final Color color;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titulo, style: T.overline),
            const Spacer(),
            Text('$valor', style: T.cuerpoFuerte.copyWith(color: color, fontSize: 18)),
            Text(' / 10', style: T.etiqueta),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: Colors.white,
            overlayColor: color.withValues(alpha: 0.18),
          ),
          child: Slider(
            value: valor.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChange(v.round()),
          ),
        ),
      ],
    );
  }
}
