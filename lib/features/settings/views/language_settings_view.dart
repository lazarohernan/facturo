import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/widgets/app_scaffold.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/core/providers/locale_provider.dart';
import 'package:icons_plus/icons_plus.dart';

class LanguageSettingsView extends ConsumerStatefulWidget {
  const LanguageSettingsView({super.key});

  @override
  ConsumerState<LanguageSettingsView> createState() =>
      _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends ConsumerState<LanguageSettingsView> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);

    // Convert settings to display format
    final selectedLanguage = settings.language == 'es' ? AppLocalizations.of(context).spanish : AppLocalizations.of(context).english;
    final selectedDateFormat = settings.dateFormat;

    return AppScaffold(
      title: localizations.languageAndRegion,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.w(16)),
        child: Column(
          children: [
            // Language Section
            _buildSection(
              context,
              theme,
              localizations,
              title: AppLocalizations.of(context).language,
              subtitle: AppLocalizations.of(context).selectYourPreferredLanguage,
              icon: Iconsax.language_square_outline,
              value: selectedLanguage,
              onTap: () => _showLanguageSelector(context, localizations),
            ),

            SizedBox(height: ResponsiveUtils.h(24)),

            // Date Format Section
            _buildSection(
              context,
              theme,
              localizations,
              title: AppLocalizations.of(context).dateFormat,
              subtitle: AppLocalizations.of(context).chooseHowDatesShouldBeDisplayed,
              icon: Iconsax.calendar_outline,
              value: selectedDateFormat,
              onTap: () => _showDateFormatSelector(context, localizations),
            ),

            SizedBox(height: ResponsiveUtils.h(40)),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: ResponsiveUtils.h(56),
              child: ElevatedButton(
                onPressed: () => _saveChanges(context, localizations),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context).saveChanges,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.sp(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.sp(18),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(4)),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.sp(14),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(ResponsiveUtils.r(12)),
              bottomRight: Radius.circular(ResponsiveUtils.r(12)),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveUtils.w(20)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: ResponsiveUtils.w(24),
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: ResponsiveUtils.w(16)),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: ResponsiveUtils.sp(16),
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_down_1_outline,
                    size: ResponsiveUtils.w(24),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  void _showLanguageSelector(
      BuildContext context, AppLocalizations localizations) {
    final settings = ref.read(appSettingsProvider);
    final currentLanguage = settings.language == 'es' ? AppLocalizations.of(context).spanish : AppLocalizations.of(context).english;

    final languages = [
      AppLocalizations.of(context).english,
      AppLocalizations.of(context).spanish,
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.r(20)),
        ),
      ),
      builder: (context) => _buildSelector(
        context,
        AppLocalizations.of(context).selectLanguage,
        languages,
        currentLanguage,
        (value) async {
          final languageCode = value == AppLocalizations.of(context).spanish ? 'es' : 'en';
          await ref
              .read(appSettingsProvider.notifier)
              .updateLanguage(languageCode);
          // Update app locale
          ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
        },
      ),
    );
  }

  void _showDateFormatSelector(
      BuildContext context, AppLocalizations localizations) {
    final settings = ref.read(appSettingsProvider);

    final formats = [
      'MM/DD/YYYY',
      'DD/MM/YYYY',
      'YYYY/MM/DD',
      'DD-MM-YYYY',
      'MM-DD-YYYY',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.r(20)),
        ),
      ),
      builder: (context) => _buildSelector(
        context,
        AppLocalizations.of(context).selectDateFormat,
        formats,
        settings.dateFormat,
        (value) async {
          await ref.read(appSettingsProvider.notifier).updateDateFormat(value);
        },
      ),
    );
  }

  
  
  Widget _buildSelector(
    BuildContext context,
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.w(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveUtils.w(40),
            height: ResponsiveUtils.h(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(2)),
            ),
          ),
          SizedBox(height: ResponsiveUtils.h(20)),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.sp(18),
            ),
          ),
          SizedBox(height: ResponsiveUtils.h(20)),
          ...options.map((option) => ListTile(
                title: Text(
                  option,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveUtils.sp(16),
                  ),
                ),
                trailing: selectedValue == option
                    ? Icon(
                        Iconsax.tick_circle_outline,
                        color: theme.colorScheme.primary,
                        size: ResponsiveUtils.w(24),
                      )
                    : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              )),
          SizedBox(height: ResponsiveUtils.h(20)),
        ],
      ),
    );
  }

  void _saveChanges(BuildContext context, AppLocalizations localizations) {
    // Settings are already saved automatically when changed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).settingsSavedSuccessfully),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
        ),
      ),
    );

    // Navigate back after saving
    context.pop();
  }
}
