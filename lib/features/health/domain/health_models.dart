/// Modelos de dominio para los datos biometricos.
///
/// Deliberadamente neutros respecto al proveedor: no mencionan Huawei en
/// ningun sitio. Cuando llegue el adaptador REST, su trabajo sera traducir el
/// JSON de Health Kit a estas clases, y ni la UI ni las estadisticas se enteran.
library;

import 'package:flutter/foundation.dart';

enum FaseSueno { profundo, ligero, rem, despierto }

extension FaseSuenoEs on FaseSueno {
  String get etiqueta => switch (this) {
        FaseSueno.profundo => 'Profundo',
        FaseSueno.ligero => 'Ligero',
        FaseSueno.rem => 'REM',
        FaseSueno.despierto => 'Despierto',
      };
}

@immutable
class TramoSueno {
  const TramoSueno({
    required this.fase,
    required this.inicio,
    required this.fin,
  });

  final FaseSueno fase;
  final DateTime inicio;
  final DateTime fin;

  Duration get duracion => fin.difference(inicio);
}

@immutable
class SesionSueno {
  const SesionSueno({
    required this.inicio,
    required this.fin,
    required this.tramos,
  });

  final DateTime inicio;
  final DateTime fin;
  final List<TramoSueno> tramos;

  /// Tiempo en cama, de cabo a rabo.
  Duration get enCama => fin.difference(inicio);

  /// Tiempo realmente dormido: descuenta los despertares.
  Duration get dormido => tramos
      .where((t) => t.fase != FaseSueno.despierto)
      .fold(Duration.zero, (a, t) => a + t.duracion);

  Duration porFase(FaseSueno f) => tramos
      .where((t) => t.fase == f)
      .fold(Duration.zero, (a, t) => a + t.duracion);

  /// Eficiencia = dormido / en cama. Por debajo de 0.85 se considera pobre.
  double get eficiencia =>
      enCama.inSeconds == 0 ? 0 : dormido.inSeconds / enCama.inSeconds;

  /// Puntuacion 0-100 combinando duracion, eficiencia y reparto de fases.
  ///
  /// No es la formula de ningun fabricante: es una heuristica propia y
  /// documentada, para no fingir que replicamos el algoritmo cerrado del reloj.
  /// Pesos: 50% duracion (objetivo 8 h), 25% eficiencia, 25% profundo+REM
  /// (objetivo combinado 40% del sueno total).
  int get puntuacion {
    if (enCama.inMinutes == 0) return 0;

    final horas = dormido.inMinutes / 60.0;
    final pDuracion = (horas / 8.0).clamp(0.0, 1.0);

    final pEficiencia = ((eficiencia - 0.70) / 0.25).clamp(0.0, 1.0);

    final reparador = porFase(FaseSueno.profundo) + porFase(FaseSueno.rem);
    final ratio = dormido.inSeconds == 0
        ? 0.0
        : reparador.inSeconds / dormido.inSeconds;
    final pFases = (ratio / 0.40).clamp(0.0, 1.0);

    return (100 * (0.50 * pDuracion + 0.25 * pEficiencia + 0.25 * pFases))
        .round();
  }
}

@immutable
class MuestraPulso {
  const MuestraPulso({required this.momento, required this.bpm});

  final DateTime momento;
  final int bpm;
}

@immutable
class ResumenActividad {
  const ResumenActividad({
    required this.dia,
    required this.pasos,
    required this.distanciaM,
    required this.calorias,
    required this.minutosActivos,
  });

  /// Normalizado a medianoche local.
  final DateTime dia;
  final int pasos;
  final int distanciaM;
  final int calorias;
  final int minutosActivos;

  double get distanciaKm => distanciaM / 1000.0;
}

/// Entrenamiento registrado por el reloj (no por la app).
@immutable
class SesionRegistrada {
  const SesionRegistrada({
    required this.inicio,
    required this.duracion,
    required this.tipo,
    required this.calorias,
    this.pulsoMedio,
  });

  final DateTime inicio;
  final Duration duracion;
  final String tipo;
  final int calorias;
  final int? pulsoMedio;
}

/// Todo lo del dia en un solo objeto, para que el dashboard haga una lectura.
@immutable
class InstantaneaDiaria {
  const InstantaneaDiaria({
    required this.dia,
    required this.actividad,
    this.sueno,
    this.pulsos = const [],
    this.sesiones = const [],
  });

  final DateTime dia;
  final ResumenActividad actividad;
  final SesionSueno? sueno;
  final List<MuestraPulso> pulsos;
  final List<SesionRegistrada> sesiones;

  int? get pulsoReposo {
    if (pulsos.isEmpty) return null;
    // El reposo se aproxima con el percentil 5, no con el minimo: un solo
    // valor erroneo del sensor no deberia definir la metrica del dia.
    final orden = pulsos.map((p) => p.bpm).toList()..sort();
    return orden[(orden.length * 0.05).floor()];
  }

  int? get pulsoMedio => pulsos.isEmpty
      ? null
      : (pulsos.map((p) => p.bpm).reduce((a, b) => a + b) / pulsos.length)
          .round();

  int? get pulsoMaximo =>
      pulsos.isEmpty ? null : pulsos.map((p) => p.bpm).reduce((a, b) => a > b ? a : b);
}
