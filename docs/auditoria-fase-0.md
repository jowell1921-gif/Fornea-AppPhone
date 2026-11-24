# Fase 0 — Auditoría y planificación

Fecha: 2026-11-23 · Estado: **aprobada**

Auditoría del proyecto web existente (`C:\Users\User\Desktop\LOWBIT KODE\Pizzeria FORNO`) realizada sin
modificar nada. Fuentes principales: `docs/flutter/`, `docs/api/openapi.json`, `docs/api/README.md`,
`docs/decisions/`, `docs/security/supabase-auth.md`, `docs/deployment/produccion-actual.md` y el código
de `backend/src/`.

## Decisiones aprobadas

| Tema | Decisión |
|---|---|
| Identificador de la app | `io.fornea.app` (Android `applicationId`, iOS bundle ID y esquema de enlaces profundos `io.fornea.app://`) |
| Modelos de datos | Escritos a mano (`fromJson`), usando `openapi.json` del backend como referencia. Sin generador de cliente |
| Arquitectura | Feature-first con MVVM (Riverpod `Notifier` como ViewModel), repositorios concretos, sin capa *domain* abstracta inicial |
| Cambios en el backend | Autorizado **proponer** G1, G2 y G3 al llegar a su fase. No se modifica nada sin una nueva aprobación expresa del cambio concreto |

## 1. Arquitectura existente

```
App Flutter (nueva) ─┐
Web Next.js (Vercel) ─┼──► API REST Express + TypeScript   https://api.forneapizzeria.es/api/v1
                      │       ├─► PostgreSQL (Supabase) mediante Prisma
                      │       ├─► Stripe (modo PRUEBA) ◄── webhook firmado
                      │       ├─► Resend (correos de pedido)
                      │       └─► Gemini (PizzAI)
                      └──► Supabase Auth (correo y Google, compartido web + app)
```

| Pieza | Detalle |
|---|---|
| Backend | Express modular (`catalog`, `cart`, `checkout`, `orders`, `payments`, `loyalty`, `me`, `addresses`, `store`, `delivery`, `promotions`, `assistant`); más de 90 operaciones con `operationId` estable |
| Autenticación | Supabase Auth emite un JWT; la API verifica la firma con el JWKS público (ES256/RS256) en cada petición. Roles y permisos en la base de datos de FORNEA, nunca en el token |
| Respuestas | Éxito `{ "data": … }` (paginadas con `meta`); error `{ "error": { code, message, details?, requestId } }`. La app decide por `code` y usa sus propios textos |
| Importes | Cadenas con dos decimales (`"9.50"`), IVA incluido. Nunca `double` |
| Fechas | ISO 8601 UTC; horarios del local en minutos desde las 00:00 en `timezone` del local |
| Límites | 300 pet./min por IP, 240/min por usuario, 30 escrituras/min por usuario (`429` + `Retry-After`) |
| Producción | Demostración pública en https://forneapizzeria.es (Vercel + Railway + Supabase gratuito, Stripe en modo prueba) |

## 2. Funcionalidades reutilizables

| Funcionalidad | Soporte en backend |
|---|---|
| Registro, login, Google, recuperar contraseña | Sí, Supabase Auth (ver G4) |
| Perfil (`profileComplete` exige nombre de usuario y teléfono para pedir) y direcciones | Sí |
| Catálogo: categorías, destacados (`popular`), disponibilidad, ingredientes, alérgenos, imágenes | Sí |
| Personalización: grupos de opciones `SIZE`, `DOUGH`, `EXTRA_INGREDIENT`, `EXTRA` con `priceDelta`, más `notes` libres | Sí (no existe «quitar ingrediente») |
| Carrito en servidor (`GET/PUT /cart`: producto, opciones, cantidad, notas; nunca precios) | Sí |
| Presupuesto del servidor (`POST /checkout/quote`): líneas, descuentos, envío, IVA, total, `pointsToEarn` | Sí |
| Recogida/domicilio, franjas, zonas por código postal, pedido mínimo, tiempo estimado | Sí |
| Pedido idempotente (`Idempotency-Key`) | Sí |
| Efectivo (`CASH_PICKUP`, `CASH_DELIVERY`) y Stripe Checkout (`ONLINE`, confirmado solo por webhook) | Sí |
| Historial, estado y cancelación (mientras `NEW` o `PENDING_PAYMENT`) | Sí |
| Ticket y factura en PDF (solo pedidos cobrados) | Sí |
| FORNEA CLUB: saldo, movimientos, recompensas, canjes, aplicar con `redemptionId` | Sí |
| Promociones y cupones (`couponCode`) | Sí |
| PizzAI | Sí (opcional) |

## 3. Endpoints disponibles para la app de cliente

Base `/api/v1`. Los de administración y cocina quedan fuera de la app.

| Área | Endpoints | Sesión |
|---|---|---|
| Catálogo | `GET /categories`, `GET /products`, `GET /products/{idOrSlug}` | No |
| Local | `GET /store/settings`, `GET /store/slots`, `GET /delivery-zones`, `GET /delivery-zones/check` | No |
| Promociones | `GET /promotions`, `GET /loyalty/program` | No |
| Presupuesto | `POST /checkout/quote` | No (sí con cupón o recompensa) |
| Perfil | `GET/PATCH /me`, `GET/POST /me/addresses`, `PATCH/DELETE /me/addresses/{id}` | Sí |
| Carrito | `GET/PUT /cart` | Sí |
| Pedidos | `POST /orders` (`Idempotency-Key`), `GET /orders/me`, `GET /orders/{id}`, `POST /orders/{id}/cancel` | Sí |
| Pago | `POST /orders/{id}/payment-session` (URL de Stripe Checkout) | Sí |
| Documentos | `GET /orders/{id}/documents`, `GET /orders/{id}/documents/{ticket\|invoice}`, `POST /orders/{id}/invoice` | Sí |
| Fidelización | `GET /loyalty/account`, `/loyalty/transactions`, `/loyalty/rewards`, `/loyalty/redemptions`, `POST /loyalty/redemptions` (`Idempotency-Key`) | Sí |
| Asistente | `GET /assistant/status`, `POST /assistant/chat` | No |

Estados del pedido: `PENDING_PAYMENT` (tarjeta) → `NEW` → `ACCEPTED` → `PREPARING` → `READY` →
(`OUT_FOR_DELIVERY` →) `COMPLETED`; además `REJECTED` y `CANCELLED`. La app solo los muestra y debe tener
un caso por defecto para valores nuevos. No hay tiempo real para clientes: consulta periódica (~20 s).

## 4. Carencias del backend

| # | Carencia | Impacto | Propuesta | Fase |
|---|---|---|---|---|
| **G1** | No existe eliminación de cuenta (`DELETE /me`) | **Bloquea la publicación**: Apple y Google exigen borrar la cuenta desde la app; Google pide además una URL web | `DELETE /me` (anonimizar pedidos por obligación fiscal y borrar el usuario en Supabase) + página web | 9 (obligatorio) |
| **G2** | `successUrl`/`cancelUrl` de Stripe apuntan siempre a la web (`/pedido/{id}`) | El usuario termina el pago en la web, no vuelve a la app | Provisional: la app consulta el pedido al volver a primer plano. Mejora: `payment-session` acepta un destino «app» de una lista permitida que vuelve a `io.fornea.app://…` | 6 (opcional) |
| **G3** | Sin notificaciones push (ni tokens de dispositivo ni FCM) | Sin avisos de cambios de estado | Tabla de dispositivos, endpoint de registro y envío por FCM desde `order-events` | 7 (si se aprueba) |
| **G4** | Plantillas de correo de Supabase usan `{{ .SiteURL }}` | Confirmación y restablecimiento de contraseña terminan en la web; el `redirectTo` de la app no se usa | MVP: la app solicita el correo e indica que se complete en el enlace. Más adelante, App Links / Universal Links | 5 |

## 5. Riesgos técnicos y particularidades

1. **Sesión segura.** `supabase_flutter` guarda la sesión por defecto en SharedPreferences (sin cifrar). Se le dará un almacenamiento basado en `flutter_secure_storage` (Keystore / Keychain).
2. **Sin «quitar ingrediente».** Solo existen opciones añadidas y `notes`. Las retiradas se expresan en notas, igual que en la web.
3. **Imágenes relativas.** Las URL que empiezan por `/` son relativas a la web: la app necesita la URL base de la web además de la de la API.
4. **Producción es una demo compartida.** El desarrollo usa el backend local (Docker + `npm run dev`). Desde el emulador Android, el `localhost` del PC es `10.0.2.2`.
5. **Supabase gratuito se pausa** tras una semana sin actividad: errores de red con mensaje amable y reintento.
6. **Google Sign-In** por navegador (`signInWithOAuth`); solo requiere registrar `io.fornea.app://login-callback` en Supabase → Authentication → URL Configuration.
7. **iOS** no se puede compilar ni probar desde Windows: hará falta un Mac con Xcode (Fases 8–10).
8. **Fragmentos Dart de `docs/flutter/`** son orientativos y no están compilados.
9. **Funciones de demostración** (`selfAdminAvailable`, roles de personal) no se muestran en la app de cliente.
10. **Perfil incompleto.** `GET /me` crea el perfil; hasta que `profileComplete` sea `true` el servidor responde `PROFILE_INCOMPLETE` al pedir.
11. **Sesión caducada.** Ante `401 TOKEN_EXPIRED`: renovar una vez y reintentar; otro `401`: cerrar sesión.

## 6. Arquitectura Flutter

```
lib/
├── main.dart                  # arranque: entorno, Supabase, ProviderScope
├── app.dart                   # MaterialApp.router + tema
├── core/
│   ├── config/                # entorno (API, web, Supabase) vía --dart-define-from-file
│   ├── network/               # Dio, interceptores (token, 401), ApiException por error.code
│   ├── router/                # GoRouter + redirecciones según sesión
│   ├── theme/                 # colores FORNEA (variantes accesibles), tipografías, espaciados
│   ├── utils/                 # Money (decimal), formato de euros y fechas
│   └── widgets/               # botones, estados vacío/carga/error, tarjetas
└── features/
    ├── auth/  catalog/  cart/  checkout/  orders/  loyalty/  profile/  store/
    └── <feature>/
        ├── data/              # modelos (fromJson a mano), api, repository
        └── presentation/      # viewmodels (Notifier), screens, widgets
```

Colores accesibles heredados de la web (decisión 0002): botones y texto pequeño sobre blanco con
`#BF3F2A`; sobre crema `#A53320`; dorado solo sobre carbón; texto secundario `#5C5148`.

## 7. Plan de desarrollo

| Fase | Contenido | Backend |
|---|---|---|
| 1 | Entorno: Flutter, Android Studio, emulador, VS Code, `flutter doctor` | – |
| 2 | Fundamentos de Dart y Flutter con ejemplos de FORNEA | – |
| 3 | Proyecto `io.fornea.app`, carpetas, tema, router, Riverpod, linter, `.gitignore` de Flutter | – |
| 4 | Interfaz con datos de prueba claramente identificados | – |
| 5 | Dio, entornos, auth, catálogo, perfil, carrito, pedidos y club contra el backend local | – |
| 6 | Checkout, efectivo, Stripe (test), polling del pago | G2 (opcional) |
| 7 | Documentos PDF, seguimiento, push | G3 (si se aprueba) |
| 8 | Pruebas unitarias, de widgets e integración | – |
| 9 | Producción: iconos, splash, eliminación de cuenta | **G1** |
| 10 | Publicación (iOS requiere Mac) | – |

## 8. Dependencias previstas

Versión y compatibilidad se comprueban al añadir cada una.

| Paquete | Uso | Fase |
|---|---|---|
| `flutter_riverpod` | Estado e inyección de dependencias | 3 |
| `go_router` | Navegación | 3 |
| `intl` | Formato de euros y fechas | 4 |
| `shared_preferences` | Carrito local y preferencias no sensibles | 4–5 |
| `dio` | Cliente HTTP | 5 |
| `supabase_flutter` | Autenticación | 5 |
| `flutter_secure_storage` | Sesión cifrada | 5 |
| `decimal` | Importes exactos | 5 |
| `cached_network_image` | Imágenes con caché | 5 |
| `uuid` | `Idempotency-Key` | 6 |
| `url_launcher` | Stripe Checkout y textos legales | 6 |
| `firebase_messaging` | Push (solo si se aprueba G3) | 7 |
| `mocktail` (dev) | Pruebas | 8 |
| `flutter_launcher_icons`, `flutter_native_splash` (dev) | Icono y splash | 9 |

Barlow Condensed e Inter se incluyen como recursos de la app. No se usa `flutter_stripe`.
