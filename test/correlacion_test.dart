import 'package:appluisa/features/insights/correlation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pearson', () {
    test('correlación positiva perfecta', () {
      final r = pearson([(x: 1, y: 2), (x: 2, y: 4), (x: 3, y: 6), (x: 4, y: 8)]);
      expect(r, closeTo(1.0, 1e-9));
    });

    test('correlación negativa perfecta', () {
      final r = pearson([(x: 1, y: 8), (x: 2, y: 6), (x: 3, y: 4), (x: 4, y: 2)]);
      expect(r, closeTo(-1.0, 1e-9));
    });

    test('sin relación da r cercano a 0', () {
      final r = pearson([(x: 1, y: 5), (x: 2, y: 1), (x: 3, y: 9), (x: 4, y: 2), (x: 5, y: 6)]);
      expect(r!.abs(), lessThan(0.6));
    });

    test('null si hay menos de 3 puntos', () {
      expect(pearson([(x: 1, y: 2), (x: 2, y: 4)]), isNull);
    });

    test('null si una variable no tiene varianza', () {
      // Todos los y iguales: correlación indefinida, no 0 falso.
      expect(pearson([(x: 1, y: 5), (x: 2, y: 5), (x: 3, y: 5)]), isNull);
    });
  });

  group('correlacionar', () {
    VariableDiaria v(String id, String nombre, List<double> vals) {
      final base = DateTime(2026, 1, 1);
      return VariableDiaria(
        id: id,
        nombre: nombre,
        valores: {for (var i = 0; i < vals.length; i++) base.add(Duration(days: i)): vals[i]},
      );
    }

    test('detecta el par correlacionado e ignora el ruido', () {
      final sueno = v('sueno', 'Sueño', [6, 7, 8, 5, 9, 7.5, 6.5, 8.5, 7, 6]);
      // Volumen sube con el sueño (correlación fuerte).
      final volumen = v('vol', 'Volumen', [600, 700, 820, 480, 900, 760, 640, 860, 710, 610]);
      // Ruido sin relación.
      final ruido = v('ruido', 'Ruido', [3, 9, 1, 7, 2, 8, 4, 1, 9, 5]);

      final hallazgos = correlacionar([sueno, volumen, ruido]);
      expect(hallazgos, isNotEmpty);
      final top = hallazgos.first;
      expect({top.a.id, top.b.id}, {'sueno', 'vol'});
      expect(top.positiva, isTrue);
      expect(top.fuerza, anyOf('fuerte', 'moderada'));
      expect(top.n, 10);
    });

    test('no concluye con pocos días en común', () {
      // Solo 4 días solapados: por debajo del mínimo (8).
      final a = v('a', 'A', [1, 2, 3, 4]);
      final b = v('b', 'B', [2, 4, 6, 8]);
      expect(correlacionar([a, b]), isEmpty);
    });

    test('el texto habla de asociación, no de causa', () {
      final a = v('a', 'Pasos', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final b = v('b', 'Tiempo en rango', [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]);
      final h = correlacionar([a, b]).first;
      expect(h.texto.toLowerCase(), contains('suele'));
      expect(h.texto.toLowerCase(), isNot(contains('causa')));
    });
  });
}
