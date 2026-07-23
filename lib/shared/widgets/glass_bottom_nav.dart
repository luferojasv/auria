import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

class DestinoNav {
  const DestinoNav({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  final Color color;
}

/// Barra de navegacion flotante de cristal.
///
/// La pildora del elemento activo se desliza entre posiciones en vez de
/// aparecer y desaparecer: da continuidad y deja claro de donde vienes.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.destinos,
    required this.indice,
    required this.onSelect,
  });

  final List<DestinoNav> destinos;
  final int indice;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final acento = destinos[indice].color;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        G.e4,
        0,
        G.e4,
        MediaQuery.paddingOf(context).bottom + G.e3,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: G.brL,
          boxShadow: G.sombra(y: 16, blur: 40),
        ),
        child: ClipRRect(
          borderRadius: G.brL,
          child: BackdropFilter(
            filter: G.filtroFuerte,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: G.brL,
                color: G.cristalRellenoAlto,
                border: Border.all(color: G.cristalBorde),
              ),
              child: Stack(
                children: [
                  // Pildora deslizante.
                  AnimatedAlign(
                    duration: G.normal,
                    curve: G.curvaSuave,
                    alignment: Alignment(
                      destinos.length == 1
                          ? 0
                          : -1 + 2 * indice / (destinos.length - 1),
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1 / destinos.length,
                      child: Padding(
                        padding: const EdgeInsets.all(G.e2),
                        child: AnimatedContainer(
                          duration: G.normal,
                          decoration: BoxDecoration(
                            borderRadius: G.brM,
                            color: acento.withValues(alpha: 0.20),
                            border: Border.all(
                              color: acento.withValues(alpha: 0.42),
                            ),
                            boxShadow: G.halo(acento, intensidad: 0.22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < destinos.length; i++)
                        Expanded(
                          child: _Item(
                            destino: destinos[i],
                            activo: i == indice,
                            onTap: () => onSelect(i),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.destino, required this.activo, required this.onTap});

  final DestinoNav destino;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? Colors.white : G.textoBajo;

    return Semantics(
      button: true,
      selected: activo,
      label: destino.etiqueta,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: G.rapido,
              child: Icon(
                activo ? destino.iconoActivo : destino.icono,
                key: ValueKey(activo),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: G.rapido,
              style: T.etiqueta.copyWith(
                color: color,
                fontSize: 10.5,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(destino.etiqueta),
            ),
          ],
        ),
      ),
    );
  }
}
