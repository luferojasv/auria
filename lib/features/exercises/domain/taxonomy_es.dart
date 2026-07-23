/// Traduccion de la taxonomia del dataset, que viene solo en ingles.
///
/// Son conjuntos cerrados y verificados contra los 1.324 ejercicios:
/// 10 zonas, 28 equipos, 19 musculos objetivo y 29 grupos musculares.
/// Si el dataset creciera con un valor nuevo, [traducir] lo deja pasar tal cual
/// en vez de romper la ficha.
library;

const Map<String, String> zonasEs = {
  'upper arms': 'Brazos',
  'upper legs': 'Muslos',
  'back': 'Espalda',
  'waist': 'Abdomen',
  'chest': 'Pecho',
  'shoulders': 'Hombros',
  'lower legs': 'Pantorrillas',
  'lower arms': 'Antebrazos',
  'cardio': 'Cardio',
  'neck': 'Cuello',
};

const Map<String, String> equipoEs = {
  'body weight': 'Peso corporal',
  'dumbbell': 'Mancuerna',
  'cable': 'Polea',
  'barbell': 'Barra',
  'leverage machine': 'Máquina de palanca',
  'band': 'Banda',
  'smith machine': 'Máquina Smith',
  'kettlebell': 'Pesa rusa',
  'weighted': 'Con lastre',
  'stability ball': 'Pelota de estabilidad',
  'ez barbell': 'Barra Z',
  'sled machine': 'Máquina de trineo',
  'assisted': 'Asistido',
  'medicine ball': 'Balón medicinal',
  'rope': 'Cuerda',
  'roller': 'Rodillo',
  'resistance band': 'Banda elástica',
  'bosu ball': 'Bosu',
  'wheel roller': 'Rueda abdominal',
  'olympic barbell': 'Barra olímpica',
  'tire': 'Neumático',
  'trap bar': 'Barra hexagonal',
  'stepmill machine': 'Escaladora',
  'elliptical machine': 'Elíptica',
  'hammer': 'Martillo',
  'skierg machine': 'SkiErg',
  'stationary bike': 'Bicicleta estática',
  'upper body ergometer': 'Ergómetro de brazos',
};

const Map<String, String> musculosEs = {
  // target (19)
  'abs': 'Abdominales',
  'pectorals': 'Pectorales',
  'biceps': 'Bíceps',
  'glutes': 'Glúteos',
  'delts': 'Deltoides',
  'triceps': 'Tríceps',
  'upper back': 'Espalda alta',
  'lats': 'Dorsales',
  'calves': 'Gemelos',
  'quads': 'Cuádriceps',
  'forearms': 'Antebrazos',
  'cardiovascular system': 'Sistema cardiovascular',
  'hamstrings': 'Isquiotibiales',
  'spine': 'Columna',
  'traps': 'Trapecios',
  'adductors': 'Aductores',
  'abductors': 'Abductores',
  'serratus anterior': 'Serrato anterior',
  'levator scapulae': 'Elevador de la escápula',
  // muscle_group + secondary_muscles (los que no aparecen arriba)
  'shoulders': 'Hombros',
  'quadriceps': 'Cuádriceps',
  'obliques': 'Oblicuos',
  'hip flexors': 'Flexores de cadera',
  'chest': 'Pecho',
  'trapezius': 'Trapecio',
  'deltoids': 'Deltoides',
  'ankles': 'Tobillos',
  'core': 'Core',
  'lower back': 'Espalda baja',
  'soleus': 'Sóleo',
  'rotator cuff': 'Manguito rotador',
  'wrist flexors': 'Flexores de muñeca',
  'wrist extensors': 'Extensores de muñeca',
  'latissimus dorsi': 'Dorsal ancho',
  'rhomboids': 'Romboides',
  'abdominals': 'Abdominales',
  'wrists': 'Muñecas',
  'hands': 'Manos',
  'ankle stabilizers': 'Estabilizadores de tobillo',
};

/// Devuelve la etiqueta en espanol, o el valor original capitalizado si el
/// dataset trae algo que no conocemos.
String traducir(String? valor, Map<String, String> diccionario) {
  if (valor == null || valor.isEmpty) return '';
  final hit = diccionario[valor.toLowerCase()];
  if (hit != null) return hit;
  return valor[0].toUpperCase() + valor.substring(1);
}

String zonaEs(String? v) => traducir(v, zonasEs);
String equipoEsDe(String? v) => traducir(v, equipoEs);
String musculoEs(String? v) => traducir(v, musculosEs);
