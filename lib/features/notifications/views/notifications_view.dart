import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/features/notifications/models/notification_model.dart';
import 'package:facturo/features/notifications/providers/notifications_provider.dart';
import 'package:facturo/features/notifications/services/firebase_notification_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

// Helper functions for notification icons and colors
IconData _getNotificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.invoice:
      return PhosphorIcons.fileText();
    case NotificationType.estimate:
      return PhosphorIcons.note();
    case NotificationType.expense:
      return PhosphorIcons.moneyWavy();
    case NotificationType.payment:
      return PhosphorIcons.wallet();
    case NotificationType.subscription:
      return PhosphorIcons.crown();
    case NotificationType.reminder:
      return PhosphorIcons.clock();
    case NotificationType.system:
      return PhosphorIcons.info();
  }
}

Color _getNotificationColor(NotificationType type, ThemeData theme) {
  switch (type) {
    case NotificationType.invoice:
      return theme.colorScheme.primary;
    case NotificationType.estimate:
      return Colors.blue;
    case NotificationType.expense:
      return Colors.orange;
    case NotificationType.payment:
      return Colors.green;
    case NotificationType.subscription:
      return Colors.purple;
    case NotificationType.reminder:
      return Colors.amber;
    case NotificationType.system:
      return theme.colorScheme.secondary;
  }
}

class NotificationsView extends ConsumerStatefulWidget {
  static const String routeName = 'notifications';
  static const String routePath = '/notifications';

  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // Configurar timeago en español
    timeago.setLocaleMessages('es', timeago.EsMessages());
    
    // Limpiar badge de iOS cuando se abre la vista de notificaciones
    _clearBadge();
  }

  Future<void> _clearBadge() async {
    try {
      await FirebaseNotificationService().clearBadge();
    } catch (e) {
      debugPrint('⚠️ Error limpiando badge: $e');
    }
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'type':
        return AppLocalizations.of(context).type;
      case 'timestamp':
        return AppLocalizations.of(context).timestamp;
      case 'report_id':
        return AppLocalizations.of(context).reportId;
      case 'invoices_processed':
        return AppLocalizations.of(context).invoicesProcessed;
      case 'total_amount':
        return AppLocalizations.of(context).totalAmount;
      default:
        return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  String _formatMetadataValue(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is num) {
      if (value is int) {
        return value.toString();
      } else {
        return '\$${value.toStringAsFixed(2)}';
      }
    } else if (value is bool) {
      return value ? 'Sí' : 'No';
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.notifications),
        elevation: 0,
        actions: [
          if (notificationsState.notifications.isNotEmpty) ...[
            // Botón para marcar todas como leídas (siempre visible)
            IconButton(
              icon: Icon(
                notificationsState.unreadCount > 0 
                    ? PhosphorIcons.checkCircle() 
                    : PhosphorIcons.checkCircle(),
              ),
              tooltip: localizations.markAllAsRead,
              onPressed: () {
                if (notificationsState.unreadCount > 0) {
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                } else {
                  // Si ya están todas leídas, mostrar mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).allNotificationsAlreadyRead),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: notificationsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationsState.notifications.isEmpty
              ? _buildEmptyState(context, localizations)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationsProvider.notifier).loadNotifications();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.h(16),
                    ),
                    itemCount: notificationsState.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationsState.notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _deleteNotification(notification.id),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: notificationsState.notifications.isNotEmpty
          ? Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(ResponsiveUtils.w(16)),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.error,
                          theme.colorScheme.error.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showClearAllDialog(context, localizations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: theme.colorScheme.onError,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(PhosphorIcons.trash()),
                      label: Text(
                        localizations.clearAllNotifications,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.w(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.bell(),
              size: ResponsiveUtils.sp(80),
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            SizedBox(height: ResponsiveUtils.h(24)),
            Text(
              localizations.noNotifications,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.h(8)),
            Text(
              localizations.noNotificationsMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Marcar como leída
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Mostrar diálogo con información completa
    _showNotificationDetailDialog(notification);
  }

  void _showNotificationDetailDialog(AppNotification notification) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type, theme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type, theme),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: theme.textTheme.bodyLarge,
            ),
            
            // Mostrar datos adicionales si existen
            if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles adicionales:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...notification.metadata!.entries.where((e) => e.key != 'action_url').map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIcons.circle(),
                              size: 6,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_formatMetadataKey(entry.key)}: ${_formatMetadataValue(entry.value)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  PhosphorIcons.clock(),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  timeago.format(
                    notification.createdAt,
                    locale: localizations.localeName,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (notification.actionUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(notification.actionUrl!);
              },
              child: Text(localizations.viewDetails),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    ref.read(notificationsProvider.notifier).deleteNotification(notificationId);
  }

  void _showClearAllDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearAllNotifications),
        content: Text(localizations.clearAllNotificationsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ResponsiveUtils.w(20)),
        color: theme.colorScheme.error,
        child: Icon(
          PhosphorIcons.trash(),
          color: theme.colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.w(16),
            vertical: ResponsiveUtils.h(4),
          ),
          padding: EdgeInsets.all(ResponsiveUtils.sp(16)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono según tipo de notificación con indicador de no leído
              Stack(
                children: [
                  Container(
                    width: ResponsiveUtils.sp(40),
                    height: ResponsiveUtils.sp(40),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type, theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                      border: notification.isRead 
                          ? null 
                          : Border.all(
                              color: _getNotificationColor(notification.type, theme),
                              width: 2,
                            ),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      size: ResponsiveUtils.sp(20),
                      color: _getNotificationColor(notification.type, theme),
                    ),
                  ),
                  // Indicador de punto azul para no leídas
                  if (!notification.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: ResponsiveUtils.sp(12),
                        height: ResponsiveUtils.sp(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: ResponsiveUtils.w(12)),
              // Contenido estilo perfil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: notification.isRead
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.h(4)),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: notification.isRead
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.h(8)),
                    Text(
                      timeago.format(
                        notification.createdAt,
                        locale: localizations.localeName,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
