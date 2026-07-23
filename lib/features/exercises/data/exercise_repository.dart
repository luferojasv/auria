import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/exercise.dart';

/// Traduce terminos de busqueda en espanol a las palabras inglesas que
/// realmente aparecen en los nombres del dataset.
///
/// Sin esto, buscar "sentadilla" devuelve cero resultados sobre 1.324
/// ejercicios, porque todos los nombres estan en ingles ("barbell full squat").
/// Cubre los movimientos y modificadores mas frecuentes del gimnasio.
const Map<String, List<String>> aliasEs = {
  // patrones de movimiento
  'sentadilla': ['squat'],
  'sentadillas': ['squat'],
  'pesomuerto': ['deadlift'],
  'muerto': ['deadlift'],
  'peso muerto': ['deadlift'],
  'zancada': ['lunge'],
  'zancadas': ['lunge'],
  'estocada': ['lunge'],
  'dominada': ['pull-up', 'pullup', 'chin-up'],
  'dominadas': ['pull-up', 'pullup', 'chin-up'],
  'jalon': ['pulldown'],
  'jalón': ['pulldown'],
  'remo': ['row'],
  'press': ['press'],
  'banca': ['bench'],
  'fondo': ['dip'],
  'fondos': ['dip'],
  'flexion': ['push-up', 'pushup'],
  'flexión': ['push-up', 'pushup'],
  'flexiones': ['push-up', 'pushup'],
  'curl': ['curl'],
  'extension': ['extension'],
  'extensión': ['extension'],
  'elevacion': ['raise'],
  'elevación': ['raise'],
  'elevaciones': ['raise'],
  'apertura': ['fly', 'flye'],
  'aperturas': ['fly', 'flye'],
  'encogimiento': ['shrug'],
  'puente': ['bridge'],
  'plancha': ['plank'],
  'abdominal': ['crunch', 'sit-up'],
  'abdominales': ['crunch', 'sit-up'],
  'giro': ['twist'],
  'zambullida': ['pullover'],
  'empuje': ['push', 'thrust'],
  'tiron': ['pull'],
  'tirón': ['pull'],
  'salto': ['jump'],
  'saltos': ['jump'],
  'gemelo': ['calf'],
  'gemelos': ['calf'],
  'puntillas': ['calf raise'],
  'hipthrust': ['hip thrust'],
  'cadera': ['hip'],
  'patada': ['kickback', 'kick'],
  'aduccion': ['adduction'],
  'abduccion': ['abduction'],
  'militar': ['military'],
  'frances': ['skullcrusher', 'french'],
  'francés': ['skullcrusher', 'french'],
  'martillo': ['hammer'],
  'concentrado': ['concentration'],
  'inclinado': ['incline'],
  'declinado': ['decline'],
  'sentado': ['seated'],
  'tumbado': ['lying'],
  'depie': ['standing'],
  'de pie': ['standing'],
  'unilateral': ['single', 'one arm', 'one leg'],
  'agarre': ['grip'],
  'cerrado': ['close'],
  'abierto': ['wide'],
  // equipamiento
  'mancuerna': ['dumbbell'],
  'mancuernas': ['dumbbell'],
  'barra': ['barbell'],
  'polea': ['cable'],
  'maquina': ['machine', 'lever'],
  'máquina': ['machine', 'lever'],
  'banda': ['band'],
  'rusa': ['kettlebell'],
  'pesarusa': ['kettlebell'],
  'balon': ['ball'],
  'balón': ['ball'],
  'pelota': ['ball'],
  'cuerda': ['rope'],
  'rueda': ['wheel', 'roller'],
  'smith': ['smith'],
  'corporal': ['body weight'],
};

/// Carga el catalogo desde los assets y resuelve busquedas y filtros.
///
/// Los 1.324 ejercicios se quedan en memoria (menos de 1 MB de JSON): el
/// catalogo es de solo lectura y cabe de sobra, asi que meterlo en SQLite solo
/// anadiria complejidad sin ganar nada.
class RepositorioEjercicios {
  RepositorioEjercicios._(this._catalogo, this._indice);

  final CatalogoEjercicios _catalogo;

  /// Texto normalizado y pre-calculado por ejercicio. Se construye una vez al
  /// cargar; normalizar en cada pulsacion sobre 1.324 fichas se nota al teclear.
  final List<String> _indice;

  CatalogoEjercicios get catalogo => _catalogo;
  List<Ejercicio> get todos => _catalogo.ejercicios;

  static Future<RepositorioEjercicios> cargar({
    String ruta = 'assets/data/exercises_es.json',
  }) async {
    final texto = await rootBundle.loadString(ruta);
    final j = json.decode(texto) as Map<String, dynamic>;

    final ejercicios = (j['exercises'] as List<dynamic>)
        .map((e) => Ejercicio.desdeJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final vocab = j['vocab'] as Map<String, dynamic>;
    final catalogo = CatalogoEjercicios(
      ejercicios: ejercicios,
      zonas: (vocab['bodyPart'] as List<dynamic>).cast<String>(),
      equipos: (vocab['equipment'] as List<dynamic>).cast<String>(),
      objetivos: (vocab['target'] as List<dynamic>).cast<String>(),
      baseMedia: j['mediaBase'] as String,
      atribucionMedia: j['mediaAttribution'] as String,
    );

    // Indexamos nombre + taxonomia en ingles y en espanol, para que ambos
    // idiomas encuentren la misma ficha.
    final indice = ejercicios.map((e) {
      return normalizar([
        e.nombre,
        e.zona, e.equipo, e.objetivo, e.grupo ?? '',
        ...e.secundarios,
        e.zonaEsLabel, e.equipoEsLabel, e.objetivoEsLabel, e.grupoEsLabel,
        ...e.secundariosEs,
      ].join(' '));
    }).toList(growable: false);

    return RepositorioEjercicios._(catalogo, indice);
  }

  /// Minusculas y sin tildes, para que "bíceps" y "biceps" sean lo mismo.
  static String normalizar(String s) {
    const con = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const sin = 'aaaaaeeeeiiiiooooouuuunc';
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      final i = con.indexOf(c);
      b.write(i >= 0 ? sin[i] : c);
    }
    return b.toString();
  }

  /// Expande cada termino con sus alias en ingles.
  static List<List<String>> _expandir(String consulta) {
    final n = normalizar(consulta.trim());
    if (n.isEmpty) return const [];

    // Primero probamos la frase entera ("peso muerto" -> deadlift).
    final frase = aliasEs[n];
    if (frase != null) {
      return [
        [n, ...frase.map(normalizar)]
      ];
    }

    return n.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).map((t) {
      final al = aliasEs[t];
      return [t, if (al != null) ...al.map(normalizar)];
    }).toList();
  }

  /// Busca y filtra. Un ejercicio entra si **cada** termino de la consulta
  /// encaja por alguna de sus variantes (AND entre terminos, OR entre alias).
  List<Ejercicio> buscar({
    String consulta = '',
    String? zona,
    String? equipo,
    String? objetivo,
    Set<String>? soloIds,
  }) {
    final terminos = _expandir(consulta);
    final salida = <Ejercicio>[];

    for (var i = 0; i < _catalogo.ejercicios.length; i++) {
      final e = _catalogo.ejercicios[i];

      if (zona != null && e.zona != zona) continue;
      if (equipo != null && e.equipo != equipo) continue;
      if (objetivo != null && e.objetivo != objetivo) continue;
      if (soloIds != null && !soloIds.contains(e.id)) continue;

      if (terminos.isNotEmpty) {
        final texto = _indice[i];
        var encaja = true;
        for (final variantes in terminos) {
          if (!variantes.any(texto.contains)) {
            encaja = false;
            break;
          }
        }
        if (!encaja) continue;
      }

      salida.add(e);
    }

    if (terminos.isNotEmpty) {
      // Los que empiezan por la consulta van primero: al escribir "squat"
      // esperas "squat" antes que "single leg squat on bosu".
      final primero = normalizar(consulta.trim());
      salida.sort((a, b) {
        final pa = normalizar(a.nombre).startsWith(primero) ? 0 : 1;
        final pb = normalizar(b.nombre).startsWith(primero) ? 0 : 1;
        if (pa != pb) return pa - pb;
        return a.nombre.length.compareTo(b.nombre.length);
      });
    }

    return salida;
  }

  Ejercicio? porId(String id) {
    for (final e in _catalogo.ejercicios) {
      if (e.id == id) return e;
    }
    return null;
  }
}
