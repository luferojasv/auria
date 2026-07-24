import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/widgets/glass_bits.dart';
import '../../theme/glass_tokens.dart';

/// Vinculación con LibreLinkUp para leer la glucosa real del sensor.
Future<void> abrirVinculoGlucosa(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // Sobre el navegador raíz: si no, el panel se abre dentro del contenido y
    // la barra de navegación flotante queda montada encima, tapando sus botones.
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _HojaVinculo(),
  );
}

class _HojaVinculo extends ConsumerStatefulWidget {
  const _HojaVinculo();

  @override
  ConsumerState<_HojaVinculo> createState() => _HojaVinculoState();
}

class _HojaVinculoState extends ConsumerState<_HojaVinculo> {
  final _email = TextEditingController();
  final _clave = TextEditingController();
  bool _ocultarClave = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _vincular() async {
    final email = _email.text.trim();
    final clave = _clave.text;
    if (email.isEmpty || clave.isEmpty) {
      setState(() => _error = 'Escribe tu correo y tu contraseña de LibreLinkUp.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });

    final fallo = await ref.read(glucosaVinculadaProvider.notifier).vincular(email, clave);

    if (!mounted) return;
    if (fallo == null) {
      // En cuanto hay sesión, borramos la contraseña de memoria.
      _clave.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conectado a LibreLinkUp')),
      );
    } else {
      setState(() {
        _cargando = false;
        _error = fallo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vinculada = ref.watch(glucosaVinculadaProvider).value ?? false;

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

                Text('Origen de la glucosa', style: T.titulo),
                const SizedBox(height: G.e2),
                _Estado(vinculada: vinculada),
                const SizedBox(height: G.e6),

                if (vinculada) ...[
                  Text(
                    'Auria está leyendo tu sensor FreeStyle Libre a través de '
                    'LibreLinkUp. Si desvinculas, volverá a mostrar datos de '
                    'demostración.',
                    style: T.cuerpo,
                  ),
                  const SizedBox(height: G.e6),
                  BotonGlass(
                    texto: 'Desvincular',
                    icono: Icons.link_off_rounded,
                    color: G.error,
                    expandido: true,
                    onTap: () async {
                      await ref.read(glucosaVinculadaProvider.notifier).desvincular();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ] else ...[
                  Text(
                    'Conecta tu cuenta de LibreLinkUp para ver la glucosa real de '
                    'tu sensor. Es la misma cuenta con la que compartes tus lecturas '
                    'desde la app LibreLink.',
                    style: T.cuerpo,
                  ),
                  const SizedBox(height: G.e5),

                  Text('Correo', style: T.overline),
                  const SizedBox(height: G.e2),
                  TextField(
                    controller: _email,
                    enabled: !_cargando,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: T.cuerpo.copyWith(color: G.textoAlto),
                    cursorColor: G.acentoEjercicio,
                    decoration: const InputDecoration(hintText: 'tu@correo.com'),
                  ),
                  const SizedBox(height: G.e4),

                  Text('Contraseña', style: T.overline),
                  const SizedBox(height: G.e2),
                  TextField(
                    controller: _clave,
                    enabled: !_cargando,
                    obscureText: _ocultarClave,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: T.cuerpo.copyWith(color: G.textoAlto),
                    cursorColor: G.acentoEjercicio,
                    onSubmitted: (_) => _vincular(),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarClave
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                          color: G.textoBajo,
                        ),
                        onPressed: () => setState(() => _ocultarClave = !_ocultarClave),
                      ),
                    ),
                  ),

                  const SizedBox(height: G.e4),
                  // Aviso de privacidad: importante que se vea antes de escribir.
                  Container(
                    padding: const EdgeInsets.all(G.e3),
                    decoration: BoxDecoration(
                      borderRadius: G.brS,
                      color: G.exito.withValues(alpha: 0.10),
                      border: Border.all(color: G.exito.withValues(alpha: 0.30)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: G.exito),
                        const SizedBox(width: G.e2),
                        Expanded(
                          child: Text(
                            'Tu contraseña no se guarda. Solo se usa para iniciar '
                            'sesión; lo que queda en el teléfono es un token cifrado, '
                            'y puedes revocarlo desvinculando.',
                            style: T.etiqueta.copyWith(fontSize: 11.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: G.e4),
                    Container(
                      padding: const EdgeInsets.all(G.e3),
                      decoration: BoxDecoration(
                        borderRadius: G.brS,
                        color: G.error.withValues(alpha: 0.12),
                        border: Border.all(color: G.error.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: G.error),
                          const SizedBox(width: G.e2),
                          Expanded(
                            child: Text(
                              _error!,
                              style: T.etiqueta.copyWith(fontSize: 11.5, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: G.e6),
                  if (_cargando)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: G.e4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    BotonGlass(
                      texto: 'Conectar',
                      icono: Icons.link_rounded,
                      color: G.exito,
                      expandido: true,
                      onTap: _vincular,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  const _Estado({required this.vinculada});

  final bool vinculada;

  @override
  Widget build(BuildContext context) {
    final color = vinculada ? G.exito : G.acentoCalorias;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: G.e2),
        Text(
          vinculada ? 'FreeStyle Libre · conectado' : 'Datos de demostración',
          style: T.etiqueta.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
