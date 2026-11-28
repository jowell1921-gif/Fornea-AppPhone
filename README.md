# FORNEA — App móvil

Aplicación móvil de **FORNEA** para clientes (Android e iOS), hecha con Flutter. Es el cliente móvil
de la plataforma existente: usa la misma API REST, los mismos usuarios (Supabase Auth), pedidos,
pagos y puntos que la web. **No tiene backend propio** y no calcula precios: todo lo decide el servidor.

## Requisitos

| Herramienta | Versión probada |
|---|---|
| Flutter (incluye Dart) | 3.50.1 estable · Dart 3.14.0 |
| Android Studio (SDK y emulador) | 2026.2.2 |
| VS Code + extensiones Dart y Flutter | 3.146 |
| Emulador Android | API 37 (x86_64) |

iOS solo se puede compilar en macOS con Xcode.

## Puesta en marcha

Desde la carpeta raíz del proyecto:

```powershell
flutter pub get      # descarga las dependencias
flutter run          # compila y abre la app en el emulador o el móvil conectado
```

En VS Code basta con elegir el dispositivo en la barra de estado y pulsar **F5**. Con la app en marcha,
al guardar un archivo se aplica la recarga en caliente.

## Comandos de calidad

| Comando | Qué hace |
|---|---|
| `dart format lib test` | Da formato al código |
| `flutter analyze` | Análisis estático (reglas en `analysis_options.yaml`) |
| `flutter test` | Ejecuta las pruebas de `test/` |

Antes de dar por terminada una tarea, los tres deben terminar sin errores.

## Estructura

```
lib/
├── main.dart              # arranque: licencias de fuentes + ProviderScope
├── app.dart               # widget raíz: tema y router
├── core/                  # piezas compartidas por todas las funcionalidades
│   ├── theme/             # colores, espaciados, tipografías y tema de Material 3
│   ├── navigation/        # rutas, GoRouter (provider de Riverpod) y barra inferior
│   ├── widgets/           # componentes comunes: estados vacío, carga y error, etiquetas, imagen
│   └── formatting/        # formato de importes (solo presentación)
├── features/              # una carpeta por funcionalidad
│   ├── home/  catalog/  cart/  orders/  profile/
│   │   └── presentation/  # pantallas y widgets (más adelante: data/ y domain/)
└── dev/                   # pantallas SOLO de desarrollo (no se incluyen en la versión publicada)
assets/fonts/              # Inter y Barlow Condensed con sus licencias OFL
test/                      # pruebas, con la misma estructura que lib/
docs/                      # documentación del proyecto
android/  ios/             # proyectos nativos (identificador io.fornea.app)
```

La arquitectura (por funcionalidades, con MVVM y Riverpod) se describe en
[`docs/auditoria-fase-0.md`](docs/auditoria-fase-0.md), apartado 6.

## Documentación

| Tema | Dónde |
|---|---|
| Auditoría del backend, endpoints, carencias y plan | `docs/auditoria-fase-0.md` |
| Contrato de la API y guía para Flutter (proyecto web) | `Pizzeria FORNO/docs/api/` y `Pizzeria FORNO/docs/flutter/` |
