import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/widgets/app_scaffold.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:icons_plus/icons_plus.dart';

class CurrencySettingsView extends ConsumerStatefulWidget {
  const CurrencySettingsView({super.key});

  @override
  ConsumerState<CurrencySettingsView> createState() =>
      _CurrencySettingsViewState();
}

class _CurrencySettingsViewState extends ConsumerState<CurrencySettingsView> {
  String _searchQuery = '';
  String? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final currentCurrency = CurrencyService.getCurrency(settings.currency) ??
        CurrencyService.defaultCurrency;

    // Get unique regions
    final regions = CurrencyService.allCurrencies
        .map((c) => c.region)
        .toSet()
        .toList()
      ..sort();

    // Filter currencies
    var filteredCurrencies = CurrencyService.allCurrencies;
    if (_selectedRegion != null) {
      filteredCurrencies = filteredCurrencies
          .where((c) => c.region == _selectedRegion)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredCurrencies = filteredCurrencies
          .where((c) =>
              c.code.toLowerCase().contains(query) ||
              c.name.toLowerCase().contains(query) ||
              c.nameEs.toLowerCase().contains(query) ||
              c.symbol.contains(query))
          .toList();
    }

    return AppScaffold(
      title: localizations.currency,
      showBackButton: true,
      body: Column(
        children: [
          // Current selection card
          Container(
            margin: EdgeInsets.all(ResponsiveUtils.w(16)),
            padding: EdgeInsets.all(ResponsiveUtils.w(20)),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.w(12)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(10)),
                  ),
                  child: Text(
                    currentCurrency.flag,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.sp(32),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.localeName.startsWith('es')
                            ? currentCurrency.nameEs
                            : currentCurrency.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.h(4)),
                      Text(
                        '${currentCurrency.code} (${currentCurrency.symbol}) - ${currentCurrency.region}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.tick_circle_bold,
                  color: theme.colorScheme.primary,
                  size: ResponsiveUtils.w(24),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(16)),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: localizations.searchCurrency,
                    prefixIcon: Icon(
                      Iconsax.search_normal_outline,
                      size: ResponsiveUtils.w(20),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.w(16),
                      vertical: ResponsiveUtils.h(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: ResponsiveUtils.h(12)),

                // Region filter
                SizedBox(
                  height: ResponsiveUtils.h(40),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        context,
                        theme,
                        localizations.all,
                        null,
                      ),
                      ...regions.map((region) => _buildFilterChip(
                            context,
                            theme,
                            region,
                            region,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.h(8)),

          // Currency list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(16)),
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index];
                final isSelected = currency.code == currentCurrency.code;

                return Container(
                  margin: EdgeInsets.only(bottom: ResponsiveUtils.h(8)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.w(16),
                      vertical: ResponsiveUtils.h(8),
                    ),
                    leading: Container(
                      width: ResponsiveUtils.w(48),
                      height: ResponsiveUtils.w(48),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
                      ),
                      child: Center(
                        child: Text(
                          currency.flag,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(28),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      localizations.localeName.startsWith('es')
                          ? currency.nameEs
                          : currency.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      '${currency.code} (${currency.symbol}) - ${currency.region}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Iconsax.tick_circle_bold,
                            color: theme.colorScheme.primary,
                            size: ResponsiveUtils.w(24),
                          )
                        : null,
                    onTap: () async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .updateCurrency(currency.code);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${localizations.currencyUpdatedTo} ${currency.code}',
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    String label,
    String? region,
  ) {
    final isSelected = _selectedRegion == region;

    return Padding(
      padding: EdgeInsets.only(right: ResponsiveUtils.w(8)),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.sp(13),
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRegion = selected ? region : null;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: theme.colorScheme.onPrimary,
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
