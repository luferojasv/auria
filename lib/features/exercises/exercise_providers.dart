import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../muscles/muscle_map.dart';
import 'domain/exercise.dart';

@immutable
class FiltroEjercicios {
  const FiltroEjercicios({
    this.consulta = '',
    this.zona,
    this.equipo,
    this.objetivo,
    this.musculoSlug,
  });

  final String consulta;
  final String? zona;
  final String? equipo;
  final String? objetivo;

  /// Slug de MuscleMap elegido tocando la silueta. Filtra por el músculo
  /// principal del ejercicio.
  final String? musculoSlug;

  bool get vacio =>
      consulta.isEmpty &&
      zona == null &&
      equipo == null &&
      objetivo == null &&
      musculoSlug == null;

  int get activos =>
      (zona != null ? 1 : 0) +
      (equipo != null ? 1 : 0) +
      (objetivo != null ? 1 : 0) +
      (musculoSlug != null ? 1 : 0);

  /// `limpiar*` permite volver a null, que un `copyWith` normal no puede
  /// expresar (pasar null significaria "no cambies").
  FiltroEjercicios copiar({
    String? consulta,
    String? zona,
    String? equipo,
    String? objetivo,
    String? musculoSlug,
    bool limpiarZona = false,
    bool limpiarEquipo = false,
    bool limpiarObjetivo = false,
    bool limpiarMusculo = false,
  }) {
    return FiltroEjercicios(
      consulta: consulta ?? this.consulta,
      zona: limpiarZona ? null : (zona ?? this.zona),
      equipo: limpiarEquipo ? null : (equipo ?? this.equipo),
      objetivo: limpiarObjetivo ? null : (objetivo ?? this.objetivo),
      musculoSlug: limpiarMusculo ? null : (musculoSlug ?? this.musculoSlug),
    );
  }
}

class FiltroEjerciciosCtrl extends Notifier<FiltroEjercicios> {
  @override
  FiltroEjercicios build() => const FiltroEjercicios();

  void consulta(String v) => state = state.copiar(consulta: v);

  /// Tocar el filtro ya activo lo desactiva: sirve de alternar sin necesidad
  /// de una "x" aparte en cada chip.
  void zona(String? v) => state = v == null || state.zona == v
      ? state.copiar(limpiarZona: true)
      : state.copiar(zona: v);

  void equipo(String? v) => state = v == null || state.equipo == v
      ? state.copiar(limpiarEquipo: true)
      : state.copiar(equipo: v);

  void objetivo(String? v) => state = v == null || state.objetivo == v
      ? state.copiar(limpiarObjetivo: true)
      : state.copiar(objetivo: v);

  void musculo(String? slug) => state = slug == null || state.musculoSlug == slug
      ? state.copiar(limpiarMusculo: true)
      : state.copiar(musculoSlug: slug);

  void limpiar() => state = const FiltroEjercicios();
}

final filtroEjerciciosProvider =
    NotifierProvider<FiltroEjerciciosCtrl, FiltroEjercicios>(
  FiltroEjerciciosCtrl.new,
);

/// Resultado de aplicar el filtro al catalogo.
final ejerciciosFiltradosProvider = Provider<AsyncValue<List<Ejercicio>>>((ref) {
  final repo = ref.watch(repositorioEjerciciosProvider);
  final f = ref.watch(filtroEjerciciosProvider);

  return repo.whenData((r) {
    var lista = r.buscar(
      consulta: f.consulta,
      zona: f.zona,
      equipo: f.equipo,
      objetivo: f.objetivo,
    );
    // Filtro por músculo tocado en la silueta: coincide si el músculo
    // principal, el grupo o algún secundario del ejercicio cae en ese slug.
    final slug = f.musculoSlug;
    if (slug != null) {
      lista = lista.where((e) {
        if (slugDeMusculo(e.objetivo) == slug) return true;
        if (slugDeMusculo(e.grupo) == slug) return true;
        return e.secundarios.any((s) => slugDeMusculo(s) == slug);
      }).toList();
    }
    return lista;
  });
});

/// Un ejercicio por id, para la ficha de detalle.
final ejercicioProvider = Provider.family<Ejercicio?, String>((ref, id) {
  return ref.watch(repositorioEjerciciosProvider).value?.porId(id);
});
