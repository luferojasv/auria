import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

/// Mapa muscular: carga los paths SVG (extraídos de MuscleMapJS, MIT) y los
/// ofrece ya parseados como [Path] de Flutter, agrupados por músculo y por
/// vista (frontal / trasera).
class MapaMuscular {
  MapaMuscular._(this.front, this.back, this.boundsFront, this.boundsBack);

  /// slug de músculo -> Path combinado de todas sus partes.
  final Map<String, Path> front;
  final Map<String, Path> back;

  /// Caja que envuelve todo el cuerpo en cada vista, para escalar al lienzo.
  final Rect boundsFront;
  final Rect boundsBack;

  static MapaMuscular? _cache;

  static Future<MapaMuscular> cargar() async {
    if (_cache != null) return _cache!;
    final txt = await rootBundle.loadString('assets/data/muscle_map.json');
    final j = json.decode(txt) as Map<String, dynamic>;

    Map<String, Path> parsear(Map<String, dynamic> vista) {
      final out = <String, Path>{};
      for (final e in vista.entries) {
        final combinado = Path();
        for (final p in (e.value as List).cast<String>()) {
          try {
            combinado.addPath(parseSvgPathData(p), Offset.zero);
          } catch (_) {
            // Path suelto malformado: lo ignoramos en vez de tumbar el mapa.
          }
        }
        out[e.key] = combinado;
      }
      return out;
    }

    final front = parsear(j['front'] as Map<String, dynamic>);
    final back = parsear(j['back'] as Map<String, dynamic>);

    return _cache = MapaMuscular._(
      front,
      back,
      _boundsDe(front.values),
      _boundsDe(back.values),
    );
  }

  static Rect _boundsDe(Iterable<Path> paths) {
    Rect? r;
    for (final p in paths) {
      final b = p.getBounds();
      if (b.isEmpty) continue;
      r = r == null ? b : r.expandToInclude(b);
    }
    return r ?? Rect.zero;
  }
}

/// Traduce los músculos del dataset de ejercicios (target / muscleGroup /
/// secondary, en inglés) a los slugs de MuscleMap. Varios términos del dataset
/// caen en el mismo grupo del mapa (p. ej. 'lats' y 'upper back' -> upper-back),
/// que es la resolución que el mapa dibuja.
const Map<String, String> _aSlug = {
  // target del dataset
  'abs': 'abs',
  'pectorals': 'chest',
  'biceps': 'biceps',
  'glutes': 'gluteal',
  'delts': 'deltoids',
  'triceps': 'triceps',
  'upper back': 'upper-back',
  'lats': 'upper-back',
  'calves': 'calves',
  'quads': 'quadriceps',
  'forearms': 'forearm',
  'hamstrings': 'hamstring',
  'spine': 'lower-back',
  'traps': 'trapezius',
  'adductors': 'adductors',
  'abductors': 'gluteal',
  'serratus anterior': 'serratus',
  'levator scapulae': 'neck',
  // muscle_group / secondary con nombres distintos
  'shoulders': 'deltoids',
  'quadriceps': 'quadriceps',
  'obliques': 'obliques',
  'hip flexors': 'hip-flexors',
  'chest': 'chest',
  'trapezius': 'trapezius',
  'deltoids': 'deltoids',
  'core': 'abs',
  'lower back': 'lower-back',
  'latissimus dorsi': 'upper-back',
  'rhomboids': 'upper-back',
  'abdominals': 'abs',
  'soleus': 'calves',
  'rotator cuff': 'deltoids',
};

/// Devuelve el slug de MuscleMap para un músculo del dataset, o null si no hay
/// equivalente dibujable (p. ej. "cardiovascular system").
String? slugDeMusculo(String? datasetMuscle) {
  if (datasetMuscle == null) return null;
  return _aSlug[datasetMuscle.toLowerCase().trim()];
}

/// Nombre en español de un slug de MuscleMap, para mostrarlo en la interfaz.
const Map<String, String> nombresSlug = {
  'chest': 'Pecho',
  'abs': 'Abdominales',
  'biceps': 'Bíceps',
  'triceps': 'Tríceps',
  'deltoids': 'Hombros',
  'obliques': 'Oblicuos',
  'quadriceps': 'Cuádriceps',
  'calves': 'Gemelos',
  'adductors': 'Aductores',
  'trapezius': 'Trapecio',
  'forearm': 'Antebrazos',
  'serratus': 'Serrato',
  'hip-flexors': 'Flexores de cadera',
  'gluteal': 'Glúteos',
  'hamstring': 'Isquiotibiales',
  'upper-back': 'Espalda alta',
  'lower-back': 'Espalda baja',
};

String nombreSlug(String slug) => nombresSlug[slug] ?? slug;
