import 'package:flutter/foundation.dart';

import 'taxonomy_es.dart';

/// Un ejercicio del catalogo.
///
/// Refleja el JSON ya recortado en `tool/slim_dataset.mjs` (1.324 registros,
/// 0,96 MB), no el original de 16,6 MB con diez idiomas.
@immutable
class Ejercicio {
  const Ejercicio({
    required this.id,
    required this.nombre,
    required this.zona,
    required this.equipo,
    required this.objetivo,
    required this.grupo,
    required this.secundarios,
    required this.mediaId,
    required this.pasos,
    required this.idiomaPasos,
  });

  factory Ejercicio.desdeJson(Map<String, dynamic> j) => Ejercicio(
        id: j['id'] as String,
        nombre: j['name'] as String,
        zona: j['bodyPart'] as String,
        equipo: j['equipment'] as String,
        objetivo: j['target'] as String,
        grupo: j['muscleGroup'] as String?,
        secundarios: (j['secondary'] as List<dynamic>).cast<String>(),
        mediaId: j['mediaId'] as String,
        pasos: (j['steps'] as List<dynamic>).cast<String>(),
        idiomaPasos: j['stepsLang'] as String,
      );

  final String id;

  /// En ingles: el dataset no traduce los nombres. La ficha muestra tambien la
  /// zona y el musculo en espanol, y el buscador entiende terminos castellanos
  /// via [aliasEs].
  final String nombre;

  final String zona;
  final String equipo;
  final String objetivo;
  final String? grupo;
  final List<String> secundarios;
  final String mediaId;
  final List<String> pasos;
  final String idiomaPasos;

  String get zonaEsLabel => zonaEs(zona);
  String get equipoEsLabel => equipoEsDe(equipo);
  String get objetivoEsLabel => musculoEs(objetivo);
  String get grupoEsLabel => musculoEs(grupo);
  List<String> get secundariosEs => secundarios.map(musculoEs).toList();

  /// Los pasos vienen en espanol en los 1.324 registros; el flag existe solo
  /// por si el dataset creciera con fichas sin traducir.
  bool get enEspanol => idiomaPasos == 'es';
}

/// Vocabularios y metadatos que acompanan al catalogo.
@immutable
class CatalogoEjercicios {
  const CatalogoEjercicios({
    required this.ejercicios,
    required this.zonas,
    required this.equipos,
    required this.objetivos,
    required this.baseMedia,
    required this.atribucionMedia,
  });

  final List<Ejercicio> ejercicios;
  final List<String> zonas;
  final List<String> equipos;
  final List<String> objetivos;

  /// CDN desde donde se sirven imagenes y GIF. No se empaquetan: son 2.648
  /// ficheros y varios cientos de MB.
  final String baseMedia;
  final String atribucionMedia;

  String miniaturaDe(Ejercicio e) => '$baseMedia/images/${e.id}-${e.mediaId}.jpg';
  String animacionDe(Ejercicio e) => '$baseMedia/videos/${e.id}-${e.mediaId}.gif';
}
