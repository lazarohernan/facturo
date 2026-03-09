import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import '../providers/notifications_provider.dart';
import '../views/notifications_view.dart';

/// Botón de notificaciones con badge para mostrar notificaciones no leídas
class NotificationIconButton extends ConsumerWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final theme = Theme.of(context);

    // Construir label accesible para VoiceOver
    final String accessibilityLabel = unreadCount > 0
        ? 'Notifications, $unreadCount unread'
        : 'Notifications';

    return Semantics(
      label: accessibilityLabel,
      button: true,
      hint: AppLocalizations.of(context).doubleTapToViewNotifications,
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Iconsax.notification_outline),
            tooltip: accessibilityLabel,
            onPressed: () {
              context.push(NotificationsView.routePath);
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
