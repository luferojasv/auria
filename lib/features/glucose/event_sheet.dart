import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../theme/glass_tokens.dart';

/// Abre la hoja para registrar un evento nuevo.
Future<void> abrirNuevoEvento(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _HojaEvento(),
  );
}

class _HojaEvento extends ConsumerStatefulWidget {
  const _HojaEvento();

  @override
  ConsumerState<_HojaEvento> createState() => _HojaEventoState();
}

class _HojaEventoState extends ConsumerState<_HojaEvento> {
  TipoEvento _tipo = TipoEvento.comida;
  TimeOfDay _hora = TimeOfDay.now();

  final _titulo = TextEditingController();
  final _detalle = TextEditingController();
  final _dosis = TextEditingController();
  final _carbos = TextEditingController();
  final _proteina = TextEditingController();
  final _grasa = TextEditingController();
  final _calorias = TextEditingController();
  int _nivel = 5;

  @override
  void dispose() {
    for (final c in [_titulo, _detalle, _dosis, _carbos, _proteina, _grasa, _calorias]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _guardar() async {
    final ahora = DateTime.now();
    final momento = DateTime(ahora.year, ahora.month, ahora.day, _hora.hour, _hora.minute);
    final titulo = _titulo.text.trim().isEmpty ? _tipo.etiqueta : _titulo.text.trim();

    await ref.read(baseDatosProvider).anadirEvento(
          EventosCompanion.insert(
            momento: momento,
            tipo: _tipo,
            titulo: titulo,
            detalle: Value(_detalle.text.trim().isEmpty ? null : _detalle.text.trim()),
            carbos: Value(_tipo == TipoEvento.comida ? _num(_carbos) : null),
            proteina: Value(_tipo == TipoEvento.comida ? _num(_proteina) : null),
            grasa: Value(_tipo == TipoEvento.comida ? _num(_grasa) : null),
            calorias: Value(_tipo == TipoEvento.comida ? _num(_calorias) : null),
            nivel: Value(
              _tipo == TipoEvento.estres || _tipo == TipoEvento.ejercicio ? _nivel : null,
            ),
            dosis: Value(
              (_tipo == TipoEvento.medicamento || _tipo == TipoEvento.suplemento) &&
                      _dosis.text.trim().isNotEmpty
                  ? _dosis.text.trim()
                  : null,
            ),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(G.radioL)),
        child: Container(
          color: G.fondoAlto,
          padding: const EdgeInsets.fromLTRB(G.e5, G.e3, G.e5, G.e8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: G.e5),
                    decoration: BoxDecoration(
                      color: G.cristalBordeAlto,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text('Nuevo evento', style: T.titulo),
                const SizedBox(height: G.e5),

                // Tipo.
                Wrap(
                  spacing: G.e2,
                  runSpacing: G.e2,
                  children: [
                    for (final t in TipoEvento.values)
                      GlassChip(
                        texto: t.etiqueta,
                        activo: _tipo == t,
                        onTap: () => setState(() => _tipo = t),
                      ),
                  ],
                ),
                const SizedBox(height: G.e5),

                // Título + hora.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titulo,
                        style: T.cuerpo.copyWith(color: G.textoAlto),
                        cursorColor: G.acentoEjercicio,
                        decoration: InputDecoration(hintText: _hintTitulo()),
                      ),
                    ),
                    const SizedBox(width: G.e3),
                    GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _hora);
                        if (t != null) setState(() => _hora = t);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: G.e4, vertical: G.e4),
                        decoration: BoxDecoration(
                          borderRadius: G.brS,
                          color: G.cristalRelleno,
                          border: Border.all(color: G.cristalBorde),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16, color: G.textoBajo),
                            const SizedBox(width: 5),
                            Text(_hora.format(context), style: T.cuerpoFuerte.copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: G.e5),

                // Campos según tipo.
                ..._camposDeTipo(),

                const SizedBox(height: G.e6),
                BotonGlass(texto: 'Guardar evento', expandido: true, onTap: _guardar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _hintTitulo() => switch (_tipo) {
        TipoEvento.comida => 'Ej. Avena con fruta',
        TipoEvento.ejercicio => 'Ej. Caminata',
        TipoEvento.estres => 'Ej. Reunión',
        TipoEvento.medicamento => 'Ej. Metformina',
        TipoEvento.suplemento => 'Ej. Creatina',
      };

  List<Widget> _camposDeTipo() {
    switch (_tipo) {
      case TipoEvento.comida:
        return [
          Text('Macros (opcional)', style: T.overline),
          const SizedBox(height: G.e3),
          Row(
            children: [
              Expanded(child: _CampoMacro(c: _carbos, etiqueta: 'Carbos', unidad: 'g')),
              const SizedBox(width: G.e2),
              Expanded(child: _CampoMacro(c: _proteina, etiqueta: 'Proteína', unidad: 'g')),
            ],
          ),
          const SizedBox(height: G.e2),
          Row(
            children: [
              Expanded(child: _CampoMacro(c: _grasa, etiqueta: 'Grasa', unidad: 'g')),
              const SizedBox(width: G.e2),
              Expanded(child: _CampoMacro(c: _calorias, etiqueta: 'Calorías', unidad: 'kcal')),
            ],
          ),
          const SizedBox(height: G.e3),
          Text(
            'Pronto podrás estimar los macros con una foto del plato.',
            style: T.etiqueta.copyWith(fontSize: 10.5, color: G.textoTenue),
          ),
        ];
      case TipoEvento.estres:
      case TipoEvento.ejercicio:
        return [
          Row(
            children: [
              Text(_tipo == TipoEvento.estres ? 'Nivel de estrés' : 'Intensidad', style: T.overline),
              const Spacer(),
              Text('$_nivel / 10', style: T.cuerpoFuerte.copyWith(color: G.acentoPulso, fontSize: 18)),
            ],
          ),
          Slider(
            value: _nivel.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => setState(() => _nivel = v.round()),
          ),
          if (_tipo == TipoEvento.estres)
            TextField(
              controller: _detalle,
              style: T.cuerpo.copyWith(color: G.textoAlto),
              cursorColor: G.acentoEjercicio,
              decoration: const InputDecoration(hintText: 'Motivo (opcional)'),
            ),
        ];
      case TipoEvento.medicamento:
      case TipoEvento.suplemento:
        return [
          TextField(
            controller: _dosis,
            style: T.cuerpo.copyWith(color: G.textoAlto),
            cursorColor: G.acentoEjercicio,
            decoration: const InputDecoration(hintText: 'Dosis (ej. 500 mg, 1 cápsula)'),
          ),
        ];
    }
  }
}

class _CampoMacro extends StatelessWidget {
  const _CampoMacro({required this.c, required this.etiqueta, required this.unidad});

  final TextEditingController c;
  final String etiqueta;
  final String unidad;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: T.cuerpoFuerte.copyWith(fontSize: 14),
      cursorColor: G.acentoEjercicio,
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: T.etiqueta,
        suffixText: unidad,
        suffixStyle: T.etiqueta,
        isDense: true,
      ),
    );
  }
}
