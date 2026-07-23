import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/aurora_background.dart';
import '../shared/widgets/glass_bottom_nav.dart';
import '../theme/glass_tokens.dart';

/// Armazon con el fondo aurora y la barra de navegacion flotante.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinos = [
    DestinoNav(
      icono: Icons.blur_on_outlined,
      iconoActivo: Icons.blur_on_rounded,
      etiqueta: 'Hoy',
      color: G.acentoActividad,
    ),
    DestinoNav(
      icono: Icons.fitness_center_outlined,
      iconoActivo: Icons.fitness_center_rounded,
      etiqueta: 'Ejercicios',
      color: G.acentoEjercicio,
    ),
    DestinoNav(
      icono: Icons.play_circle_outline_rounded,
      iconoActivo: Icons.play_circle_filled_rounded,
      etiqueta: 'Entrenar',
      color: G.exito,
    ),
    DestinoNav(
      icono: Icons.bloodtype_outlined,
      iconoActivo: Icons.bloodtype_rounded,
      etiqueta: 'Glucosa',
      color: Color(0xFF34D399),
    ),
    DestinoNav(
      icono: Icons.insights_outlined,
      iconoActivo: Icons.insights_rounded,
      etiqueta: 'Progreso',
      color: G.acentoPulso,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // El contenido pasa por debajo de la barra: el desenfoque necesita algo
        // que desenfocar. Cada pantalla reserva el hueco con su propio padding
        // inferior.
        extendBody: true,
        body: shell,
        bottomNavigationBar: GlassBottomNav(
          destinos: _destinos,
          indice: shell.currentIndex,
          onSelect: (i) => shell.goBranch(
            i,
            // Volver a tocar la pestana activa la devuelve a su raiz, que es lo
            // que se espera al pulsar dos veces.
            initialLocation: i == shell.currentIndex,
          ),
        ),
      ),
    );
  }
}
