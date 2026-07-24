import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'theme/app_theme.dart';
import 'theme/glass_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sin esto, DateFormat(..., 'es') lanza al formatear: los simbolos de cada
  // locale se cargan bajo demanda.
  await initializeDateFormatting('es');

  // De borde a borde: el fondo aurora debe llegar bajo las barras del sistema.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Tema claro: los iconos de las barras del sistema van OSCUROS para que se
  // vean sobre el fondo luminoso de la app.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: AppLuisa()));
}

class AppLuisa extends StatelessWidget {
  const AppLuisa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Auria',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Acotamos la escala de texto: por encima de 1.3 las tarjetas de
        // metricas se rompen, y la app ya parte de cuerpos grandes.
        final escala = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: escala),
          child: ColoredBox(color: G.fondo, child: child!),
        );
      },
    );
  }
}
