# Sistema de Notificaciones

Este módulo implementa un sistema completo de notificaciones para la aplicación Facturo.

## Estructura

```
notifications/
├── models/
│   └── notification_model.dart      # Modelo de datos de notificación
├── providers/
│   └── notifications_provider.dart  # Provider de Riverpod para estado
├── services/
│   └── notifications_service.dart   # Servicio de almacenamiento local
├── views/
│   └── notifications_view.dart      # Vista principal de notificaciones
├── widgets/
│   └── notification_icon_button.dart # Botón con badge para AppBar
└── README.md
```

## Características

- ✅ **Almacenamiento local** con SharedPreferences
- ✅ **Badge con contador** de notificaciones no leídas
- ✅ **Diferentes tipos** de notificaciones (factura, gasto, suscripción, etc.)
- ✅ **Swipe to dismiss** para eliminar notificaciones
- ✅ **Marcar como leída** individual o todas
- ✅ **Navegación** a pantallas específicas desde notificaciones
- ✅ **Timestamps** con formato relativo (hace 2 horas, etc.)
- ✅ **Completamente localizado** (ES/EN)

## Uso Básico

### 1. Agregar el icono de notificaciones al AppBar

```dart
import 'package:facturo/features/notifications/widgets/notification_icon_button.dart';

AppBar(
  title: Text('Mi Pantalla'),
  actions: [
    NotificationIconButton(), // Icono con badge
  ],
)
```

### 2. Crear una notificación

```dart
import 'package:facturo/features/notifications/models/notification_model.dart';
import 'package:facturo/features/notifications/providers/notifications_provider.dart';

// Desde un widget con Riverpod
final notification = AppNotification(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: '¡Nueva factura creada!',
  message: 'La factura #001 ha sido creada exitosamente',
  type: NotificationType.invoice,
  createdAt: DateTime.now(),
  actionUrl: '/invoices/001', // Opcional: navega aquí al tocar
);

ref.read(notificationsProvider.notifier).addNotification(notification);
```

### 3. Tipos de notificaciones disponibles

```dart
enum NotificationType {
  invoice,        // Facturas (azul)
  estimate,       // Cotizaciones (azul claro)
  expense,        // Gastos (naranja)
  payment,        // Pagos (verde)
  subscription,   // Suscripción (morado)
  reminder,       // Recordatorios (amarillo)
  system,         // Sistema (gris)
}
```

## Ejemplos de Uso

### Notificación de factura vencida

```dart
final notification = AppNotification(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: 'Factura por vencer',
  message: 'La factura #123 vence en 3 días',
  type: NotificationType.reminder,
  createdAt: DateTime.now(),
  actionUrl: '/invoices/123',
  metadata: {'invoiceId': '123', 'daysUntilDue': 3},
);

ref.read(notificationsProvider.notifier).addNotification(notification);
```

### Notificación de pago recibido

```dart
final notification = AppNotification(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: '¡Pago recibido!',
  message: 'Se ha registrado un pago de \$500 para la factura #123',
  type: NotificationType.payment,
  createdAt: DateTime.now(),
  actionUrl: '/invoices/123',
);

ref.read(notificationsProvider.notifier).addNotification(notification);
```

### Notificación de suscripción

```dart
final notification = AppNotification(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: 'Suscripción por renovar',
  message: 'Tu suscripción Pro se renovará en 5 días',
  type: NotificationType.subscription,
  createdAt: DateTime.now(),
  actionUrl: '/subscriptions',
);

ref.read(notificationsProvider.notifier).addNotification(notification);
```

## Integración Recomendada

### En el Dashboard

```dart
// lib/features/dashboard/views/dashboard_view.dart
AppBar(
  title: Text(localizations.dashboard),
  actions: [
    NotificationIconButton(), // ← Agregar aquí
  ],
)
```

### En pantallas principales

Agrega el `NotificationIconButton` en cualquier AppBar donde quieras que el usuario vea notificaciones.

## Gestión de Notificaciones

### Marcar como leída

```dart
ref.read(notificationsProvider.notifier).markAsRead(notificationId);
```

### Marcar todas como leídas

```dart
ref.read(notificationsProvider.notifier).markAllAsRead();
```

### Eliminar una notificación

```dart
ref.read(notificationsProvider.notifier).deleteNotification(notificationId);
```

### Eliminar todas

```dart
ref.read(notificationsProvider.notifier).clearAll();
```

### Obtener contador de no leídas

```dart
final unreadCount = ref.watch(unreadNotificationsCountProvider);
```

## Personalización

### Colores por tipo

Los colores se asignan automáticamente según el tipo:
- **invoice**: Color primario del tema
- **estimate**: Azul
- **expense**: Naranja
- **payment**: Verde
- **subscription**: Morado
- **reminder**: Amarillo
- **system**: Color secundario del tema

### Iconos por tipo

Cada tipo tiene su propio icono de Iconsax:
- **invoice**: document_text
- **estimate**: note_2
- **expense**: money_send
- **payment**: wallet_money
- **subscription**: crown
- **reminder**: clock
- **system**: info_circle

## Localización

Todas las cadenas están localizadas en:
- `lib/l10n/app_es.arb` (Español)
- `lib/l10n/app_en.arb` (Inglés)

Claves disponibles:
- `notifications`
- `noNotifications`
- `noNotificationsMessage`
- `markAllAsRead`
- `clearAllNotifications`
- `clearAllNotificationsConfirmation`
- `notificationDeleted`
- `allNotificationsCleared`

## Limitaciones

- Máximo 100 notificaciones almacenadas (las más antiguas se eliminan automáticamente)
- Almacenamiento local únicamente (no sincronización en la nube)
- No hay notificaciones push (solo in-app)

## Próximas Mejoras

- [ ] Notificaciones push con Firebase
- [ ] Sincronización con backend
- [ ] Filtros por tipo de notificación
- [ ] Búsqueda de notificaciones
- [ ] Notificaciones programadas
- [ ] Agrupación de notificaciones similares
