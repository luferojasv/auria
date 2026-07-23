# Conectar Huawei Health Kit (datos reales de sueño, pulso y actividad)

Esta app lee biometría a través de un **puerto** (`FuenteDatosSalud`). Hoy
funciona con el adaptador de demostración (`MockHealthDataSource`). Para pasar a
tus datos reales hay que enchufar `HuaweiRestDataSource`, y para eso Huawei
exige antes una serie de pasos en su consola que **tardan días** (hay revisión
manual). Esta guía los ordena.

> **Por qué la vía REST y no el plugin `huawei_health`**
> El plugin oficial es solo Android, necesita HMS Core instalado y solo va con
> garantías en teléfonos Huawei. Como usas un Android no-Huawei, vamos por la
> **Health Kit REST API**: tu reloj sincroniza con la app Huawei Health → la
> nube de Huawei → nuestra app lee por HTTPS con OAuth. Funciona en cualquier
> marca.

## Lo que hace falta de tu lado (yo no puedo hacerlo por ti)

Todo esto vive en tu cuenta de desarrollador y requiere aceptar términos y pasar
revisiones — son acciones que debes hacer tú.

### 1. Proyecto y app en AppGallery Connect
1. Entra en <https://developer.huawei.com/consumer/en/console> con tu cuenta.
2. **AppGallery Connect → My projects → New project**.
3. Dentro del proyecto, **Add app** (plataforma Android). Apunta el **package
   name**: debe ser exactamente `com.luisarojas.appluisa` (el que ya usa el
   proyecto Flutter).

### 2. Huella SHA-256
Huawei valida tu app por su firma.
```bash
# Debug (para desarrollo). La contraseña del keystore de debug es "android".
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Copia la línea `SHA256:` y pégala en **AGC → tu app → Project settings →
General → SHA-256 certificate fingerprint**. Para publicar en tienda, repite con
tu keystore de release.

### 3. Activar Health Kit (el paso lento)
1. **AGC → tu proyecto → Manage APIs / API management**: activa **Health Kit**.
2. Ve a la consola de Health Kit y **solicita los permisos (scopes) de lectura**
   que necesitamos. Son **restringidos** y hay que justificarlos:
   - `.../healthkit/step.read` — pasos
   - `.../healthkit/heartrate.read` — ritmo cardíaco
   - `.../healthkit/sleep.read` — sueño
   - `.../healthkit/activity.read` — actividad / entrenamientos
3. Rellena el formulario de solicitud (descripción de la app, capturas, política
   de privacidad). **Huawei revisa esto a mano**: puede tardar de días a un par
   de semanas. Hasta que no lo aprueben, la API devuelve error de permisos.

### 4. Credenciales OAuth
En **AGC → tu app → General information**:
- Copia el **OAuth 2.0 Client ID** (o "App ID" según la pantalla).
- En **Authentication / OAuth**, registra el **redirect URI**:
  `com.luisarojas.appluisa:/oauth2redirect`
  (ya está declarado en `AndroidManifest.xml`).

### 5. Política de privacidad
Health Kit no aprueba una app sin una URL pública de política de privacidad que
explique qué datos lees y para qué. Hace falta incluso para uso personal.

## Lo que ya está hecho en el código

- `HuaweiAuth` — login con Huawei ID por **OAuth 2.0 + PKCE**, tokens en
  almacenamiento seguro (Keystore), refresco automático.
- `HuaweiRestDataSource` — traduce las respuestas de Health Kit a los modelos de
  la app (actividad, sueño por fases, pulso, sesiones).
- `AndroidManifest.xml` — permiso de INTERNET y la activity de callback OAuth.

## Cuando Huawei te apruebe: enchufarlo

Un solo cambio, en `lib/core/providers.dart`:

```dart
final fuenteSaludProvider = Provider<FuenteDatosSalud>((ref) {
  final auth = HuaweiAuth(
    clientId: 'TU_OAUTH_CLIENT_ID',          // del paso 4
    redirectScheme: 'com.luisarojas.appluisa',
  );
  return HuaweiRestDataSource(auth: auth);
});
```

Toda la UI (dashboard, gráficas, estadísticas) empieza a mostrar datos reales
sin ningún otro cambio: por eso existe el puerto.

## Pendiente de validar

`HuaweiRestDataSource` está escrito contra la documentación de Health Kit, pero
**no se ha podido probar contra el servicio real** porque las credenciales aún
no existen. Cuando tengas acceso, revisa contra la doc vigente:
- Los **identificadores de tipo de dato** (`com.huawei.continuous.steps.delta`,
  etc.), que Huawei ha renombrado entre versiones.
- La **forma exacta** de la respuesta de `sampleSet:polymerize` y el mapeo de
  los **códigos de fase de sueño** (`_fase()` en el adaptador).
- El endpoint de sesiones de ejercicio (`activityRecords`).

Están todos marcados con comentarios en el código para localizarlos rápido.
