import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/firebase_notification_provider.dart';

class NotificationSettingsView extends ConsumerWidget {
  static const String routeName = 'notification-settings';
  static const String routePath = '/notification-settings';

  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final settingsState = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final settings = settingsState.settings;

    // Mostrar indicador de carga mientras se cargan las configuraciones
    if (settingsState.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(localizations.notificationSettings),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mostrar error si hay alguno
    if (settingsState.error != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(localizations.notificationSettings),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: ResponsiveUtils.h(16)),
              Text(
                localizations.error,
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: ResponsiveUtils.h(8)),
              Text(
                settingsState.error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.h(16)),
              ElevatedButton(
                onPressed: () => notifier.refresh(),
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.notificationSettings),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(ResponsiveUtils.w(16)),
        children: [
          // Sección: Notificaciones Push
          _buildSectionHeader(
            context,
            icon: PhosphorIcons.bellRinging(),
            title: AppLocalizations.of(context).notificationsPush,
            subtitle: AppLocalizations.of(context).notificationsPushDescription,
          ),
          
          Card(
            margin: EdgeInsets.only(bottom: ResponsiveUtils.h(24)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    PhosphorIcons.bell(),
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(AppLocalizations.of(context).enablePushNotifications),
                  subtitle: Text(AppLocalizations.of(context).enablePushNotificationsDescription),
                  value: settings?.pushEnabled ?? false,
                  onChanged: (value) async {
                    if (value) {
                      try {
                        // Solicitar permiso con Firebase
                        final firebaseService = ref.read(firebaseNotificationServiceProvider);
                        await firebaseService.initialize();
                        
                        final hasPermissions = await firebaseService.requestPermissions();
                        if (hasPermissions) {
                          await notifier.setPushEnabled(true);
                          
                          // Mostrar mensaje de éxito
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).pushNotificationsEnabledSuccessfully),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          // Mostrar mensaje de error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).permissionDeniedEnableInSettings),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Firebase no configurado
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context).pushNotificationsNotAvailable),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    } else {
                      await notifier.setPushEnabled(false);
                      
                      // Mostrar mensaje
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).pushNotificationsDisabled),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Sección: Resumen Semanal
          if (settings?.pushEnabled == true) ...[
            _buildSectionHeader(
              context,
              icon: PhosphorIcons.chartBar(),
              title: AppLocalizations.of(context).weeklySummary,
              subtitle: AppLocalizations.of(context).weeklySummaryDescription,
            ),
            
            Card(
              margin: EdgeInsets.only(bottom: ResponsiveUtils.h(24)),
              child: SwitchListTile(
                secondary: Icon(
                  PhosphorIcons.chartBar(),
                  color: Colors.blue,
                ),
                title: Text(AppLocalizations.of(context).enableWeeklyDigest),
                subtitle: Text(AppLocalizations.of(context).enableWeeklyDigestDescription),
                value: settings?.weeklyDigestEnabled ?? false,
                onChanged: (value) => notifier.setWeeklyDigestEnabled(value),
              ),
            ),

            // Configuración de resumen semanal
            if (settings?.weeklyDigestEnabled == true) ...[
              _buildSectionHeader(
                context,
                icon: PhosphorIcons.calendarCheck(),
                title: AppLocalizations.of(context).weeklyDigestConfiguration,
                subtitle: AppLocalizations.of(context).whenWouldYouLikeToReceiveSummary,
              ),
              
              Card(
                margin: EdgeInsets.only(bottom: ResponsiveUtils.h(24)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        PhosphorIcons.calendar(),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(AppLocalizations.of(context).dayOfWeek),
                      subtitle: Text(_getWeekdayName(context, settings?.weeklyDigestDay ?? 1)),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => _showWeekdayPicker(context, ref, settings?.weeklyDigestDay ?? 1),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        PhosphorIcons.clock(),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(AppLocalizations.of(context).selectTime),
                      subtitle: Text('${(settings?.weeklyDigestHour ?? 9).toString().padLeft(2, '0')}:00'),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => _showHourPicker(context, ref, settings?.weeklyDigestHour ?? 9),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Información adicional
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.w(16)),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.info(),
                    color: theme.colorScheme.primary,
                    size: ResponsiveUtils.sp(24),
                  ),
                  SizedBox(width: ResponsiveUtils.w(12)),
                  Expanded(
                    child: Text(
                      localizations.pushNotificationsRequirePermissions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveUtils.w(8),
        bottom: ResponsiveUtils.h(12),
        top: ResponsiveUtils.h(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.sp(20),
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: ResponsiveUtils.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(BuildContext context, int day) {
    final localizations = AppLocalizations.of(context);
    switch (day) {
      case 1: return localizations.monday;
      case 2: return localizations.tuesday;
      case 3: return localizations.wednesday;
      case 4: return localizations.thursday;
      case 5: return localizations.friday;
      case 6: return localizations.saturday;
      case 7: return localizations.sunday;
      default: return localizations.monday;
    }
  }

  void _showWeekdayPicker(BuildContext context, WidgetRef ref, int currentDay) {
    final theme = Theme.of(context);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectDay),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final day = index + 1;
            final isSelected = day == currentDay;
            
            return ListTile(
              title: Text(_getWeekdayName(context, day)),
              trailing: isSelected
                  ? Icon(PhosphorIcons.check(), color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                notifier.setWeeklyDigestDay(day);
                Navigator.pop(context);
              },
            );
          }),
        ),
      ),
    );
  }

  void _showHourPicker(BuildContext context, WidgetRef ref, int currentHour) {
    final theme = Theme.of(context);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectTime),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              final isSelected = index == currentHour;
              
              return ListTile(
                title: Text('${index.toString().padLeft(2, '0')}:00'),
                trailing: isSelected
                    ? Icon(PhosphorIcons.check(), color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  notifier.setWeeklyDigestHour(index);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
