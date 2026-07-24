import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/exercises/exercise_detail_page.dart';
import '../features/exercises/exercises_page.dart';
import '../features/glucose/glucose_page.dart';
import '../features/stats/stats_page.dart';
import '../features/workouts/routine_editor_page.dart';
import '../features/workouts/session_page.dart';
import '../features/workouts/workouts_page.dart';
import '../shared/widgets/aurora_background.dart';
import 'shell.dart';

/// Envuelve las rutas de primer nivel (fuera del shell) con el fondo aurora y
/// un Scaffold. El Scaffold es imprescindible: sin un Material como ancestro,
/// Flutter pinta el texto con el subrayado amarillo de "falta Material". Las
/// pestañas ya lo heredan del shell; estas pantallas modales, no.
Widget _modal(Widget hijo) => AuroraBackground(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // Mismo ancho móvil que el shell: coherencia en escritorio.
          constraints: const BoxConstraints(maxWidth: 520),
          child: Scaffold(backgroundColor: Colors.transparent, body: hijo),
        ),
      ),
    );

/// Rutas de la app.
///
/// Las cuatro pestanas viven en un [StatefulShellRoute] para que cada una
/// conserve su pila y su scroll al cambiar de pestana.
///
/// Detalle de ejercicio y sesion van en rutas de primer nivel (en singular,
/// `/ejercicio` y `/sesion`) y no anidadas bajo su pestana. Son pantallas con
/// accion principal anclada abajo, y dentro del shell la barra de navegacion
/// se les quedaria encima.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const DashboardPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/ejercicios', builder: (_, _) => const ExercisesPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/entrenar', builder: (_, _) => const WorkoutsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/glucosa', builder: (_, _) => const GlucosePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/progreso', builder: (_, _) => const StatsPage()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/ejercicio/:id',
      builder: (_, state) =>
          _modal(ExerciseDetailPage(id: state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/sesion/:id',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return _modal(const _RutaInvalida());
        return _modal(SessionPage(sesionId: id));
      },
    ),
    GoRoute(
      path: '/rutina/:id',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return _modal(const _RutaInvalida());
        return _modal(RoutineEditorPage(rutinaId: id));
      },
    ),
  ],
);

class _RutaInvalida extends StatelessWidget {
  const _RutaInvalida();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Sesión no encontrada'));
}
