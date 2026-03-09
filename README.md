# Facturo

Aplicacion de facturacion profesional para freelancers y pequenas empresas en Latinoamerica. Crea facturas, cotizaciones y gestiona gastos desde tu movil.

## Caracteristicas

- **Facturas** - Creacion y envio con 8 estilos de PDF profesionales
- **Cotizaciones** - Genera estimados y conviertelos en facturas
- **Clientes** - Gestion completa de clientes y contactos
- **Gastos** - Registro y categorizacion de gastos
- **OCR** - Escaneo inteligente de recibos con ML Kit + Gemini AI
- **Reportes** - Graficas financieras interactivas
- **Bilingue** - Soporte completo espanol/ingles
- **PDF** - 8 estilos profesionales con adjuntos en cuadricula
- **Multiplataforma** - iOS, Android y Web

## Stack Tecnologico

| Tecnologia | Uso |
|---|---|
| Flutter 3.10+ | Framework UI multiplataforma |
| Riverpod 2.x | Gestion de estado |
| GoRouter | Navegacion y deep linking |
| Supabase | Auth, base de datos, storage |
| Google ML Kit | OCR offline |
| Gemini AI | Procesamiento inteligente de recibos |
| Firebase | Notificaciones push |

## Instalacion

```bash
# Clonar el repositorio
git clone https://github.com/lazarohernan/facturohn.git
cd facturohn

# Instalar dependencias
flutter pub get

# Configurar variables de entorno
# Crear archivo .env en la raiz del proyecto:
# SUPABASE_URL=tu_url_de_supabase
# SUPABASE_ANON_KEY=tu_anon_key
# GEMINI_API_KEY=tu_api_key_de_gemini

# Ejecutar la app
flutter run
```

## Estructura del Proyecto

```
lib/
├── core/           # Tema, providers globales, router, utilidades
├── features/       # Modulos por dominio
│   ├── auth/       # Login, registro, OAuth, sesiones anonimas
│   ├── invoices/   # Facturas y generacion de PDF
│   ├── estimates/  # Cotizaciones
│   ├── expenses/   # Gastos
│   ├── clients/    # Clientes
│   ├── dashboard/  # Pantalla principal
│   ├── reports/    # Reportes financieros
│   ├── profile/    # Perfil de negocio
│   ├── ocr/        # Escaneo de recibos
│   └── subscriptions/ # Sistema freemium
├── common/         # Widgets compartidos
└── l10n/           # Archivos de traduccion (en, es)
```

## Comandos Utiles

```bash
flutter pub get          # Instalar dependencias
flutter run              # Ejecutar app
flutter analyze          # Analizar codigo
flutter test             # Ejecutar tests
dart run build_runner build  # Regenerar providers de Riverpod
```

## Licencia

Este proyecto es privado y propietario.
