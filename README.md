# Mi progreso

App móvil en Flutter para centralizar tu **entrenamiento**, tu **sueño**, tu
**ritmo cardíaco** y tu **actividad** en un solo sitio, con estética
*glassmorphism* (fondo aurora animado + tarjetas de cristal). Los datos
biométricos vienen de tu perfil Huawei; el catálogo de ejercicios, del dataset
abierto [exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)
(1.324 ejercicios con GIF, músculos e instrucciones en español).

## Estado

| Parte | Estado |
|---|---|
| Dashboard con anillos de progreso | ✅ |
| Catálogo de 1.324 ejercicios (búsqueda ES↔EN, filtros, GIF) | ✅ |
| Registro de entrenamientos (rutinas, series, cronómetro de descanso) | ✅ |
| Estadísticas y gráficas (volumen, músculo, pasos, sueño, 1RM) | ✅ |
| `flutter analyze` | ✅ limpio |
| Pruebas de lógica | ✅ 22/22 |
| Datos de salud | 🟡 mock realista · adaptador Huawei escrito, pendiente de aprobación de Health Kit |
| Compilar/ejecutar en este PC | 🔴 bloqueado por config del sistema — ver abajo |

## ⚠️ Dos cosas que debes desbloquear en tu equipo

El código está completo y verificado, pero **este PC no puede compilar todavía**
por dos ajustes del sistema que requieren permisos de administrador (no los puedo
cambiar yo):

### 1. Activar el Modo de desarrollador de Windows
Flutter necesita crear *symlinks* para los plugins.
- Abre **Configuración → Privacidad y seguridad → Para desarrolladores**, o ejecuta:
  ```
  start ms-settings:developers
  ```
- Activa **Modo de desarrollador**.

Con esto ya puedes **ver la app en el escritorio** (no necesita el teléfono):
```bash
flutter run -d windows
```

### 2. Reparar los sockets de loopback (solo para compilar a Android)
En este equipo, Java no puede hacer `connect()` sobre sockets AF_UNIX, y Gradle
9 los usa para hablar con su daemon. Síntoma:
`java.io.IOException: Unable to establish loopback connection`.
Suele deberse a un catálogo Winsock dañado o a un LSP/EDR corporativo.
- En una terminal **como administrador**:
  ```
  netsh winsock reset
  ```
- **Reinicia** el equipo.
- Si tras reiniciar sigue igual, es probable que sea software de seguridad
  corporativo interceptando Winsock; habría que consultarlo con IT. Mientras
  tanto, `flutter run -d windows` no se ve afectado.

Después:
```bash
flutter run -d android      # con el teléfono conectado por USB y depuración activada
```

> El teléfono real es imprescindible de todos modos para leer datos de Huawei:
> el emulador no tiene la app Huawei Health.

## Entorno ya instalado en `D:\dev`

- Flutter 3.44.7 (Dart 3.12.2) · `D:\dev\flutter`
- JDK 17.0.19 (Temurin) · `D:\dev\jdk17`
- Android SDK (platform 36, build-tools 36) · `D:\dev\android-sdk`

Las variables de entorno (`JAVA_HOME`, `ANDROID_HOME`, PATH) ya están
persistidas. Abre una terminal **nueva** para que las tome.

## Arquitectura

```
lib/
├── main.dart                    # arranque, locale es, edge-to-edge
├── app/
│   ├── router.dart              # go_router; 4 pestañas + detalle + sesión
│   └── shell.dart               # aurora + barra de navegación de cristal
├── theme/
│   ├── glass_tokens.dart        # TODO el sistema de diseño (color, cristal, ritmo)
│   └── app_theme.dart
├── core/providers.dart          # Riverpod; aquí se cambia mock → Huawei
├── data/db/                     # Drift (SQLite): sesiones, series, rutinas, peso
├── shared/widgets/              # GlassCard, anillos, aurora, nav, chips…
└── features/
    ├── dashboard/               # anillos del día, pulso, sueño
    ├── exercises/               # catálogo + ficha; taxonomía y alias ES
    ├── workouts/                # sesión activa, cronómetro de descanso
    ├── stats/                   # gráficas con fl_chart
    └── health/
        ├── domain/              # modelos + puerto FuenteDatosSalud
        └── data/                # MockHealthDataSource · HuaweiRestDataSource + OAuth
```

**Idea clave — el puerto de salud.** Ninguna pantalla habla con Huawei
directamente: todas consumen la interfaz `FuenteDatosSalud`. Eso permite
construir y probar la app entera contra datos simulados y, cuando Huawei apruebe
Health Kit, activar los datos reales cambiando **una línea** en
`core/providers.dart`. Ver [`docs/huawei-health-kit.md`](docs/huawei-health-kit.md).

## El dataset

`tool/slim_dataset.mjs` reduce el JSON original de **16,6 MB → 0,96 MB**:
descarta 9 idiomas, el campo `category` (duplicado de `body_part`) y las rutas
de media (derivables de `id`+`media_id`). Las imágenes y GIF **no** se
empaquetan (son 2.648 ficheros): se sirven desde el CDN de jsDelivr con caché en
disco. Regenerar:
```bash
node tool/slim_dataset.mjs entrada/exercises.json assets/data/exercises_es.json
```

> Nota de licencia: el código del dataset es MIT, pero los GIF/imágenes son
> © Gym visual y se rigen por sus términos. Para uso personal está bien; para
> publicar en una tienda habría que revisarlo.

## Comandos útiles

```bash
flutter test                     # 22 pruebas de lógica (no necesita compilar)
flutter analyze                  # análisis estático
dart run build_runner build      # regenerar el código de Drift tras tocar la BD
flutter run -d windows           # ver la app en el escritorio (tras Modo desarrollador)
```
