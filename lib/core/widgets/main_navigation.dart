import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/features/dashboard/views/dashboard_view.dart';
import 'package:facturo/features/invoices/views/invoices_view.dart';
import 'package:facturo/features/estimates/views/estimates_view.dart';
import 'package:facturo/features/reports/views/reports_view.dart';
import 'package:facturo/features/expenses/views/expenses_view.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

/// Provider que expone el índice de la pestaña actual de navegación
final currentNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Widget principal que contiene el BottomNavigationBar
/// y gestiona la navegación entre las pantallas principales
class MainNavigation extends ConsumerStatefulWidget {
  final Widget child;
  final int initialIndex;

  const MainNavigation({
    super.key,
    required this.child,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  // Lista de pantallas principales
  final List<Widget> _mainScreens = [
    const DashboardView(),
    const InvoicesView(),
    const EstimatesView(),
    const ExpensesView(),
    const ReportsView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Si es el botón de Más (índice 5), mostrar menú de opciones
    if (index == 5) {
      _showMoreOptions();
      return;
    }
    
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      ref.read(currentNavigationIndexProvider.notifier).state = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showMoreOptions() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final navigatorContext = context; // Capturar el contexto correcto
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                localizations.moreOptions,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(PhosphorIcons.users(PhosphorIconsStyle.regular)),
                title: Text(localizations.clients),
                trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                onTap: () {
                  Navigator.pop(modalContext);
                  navigatorContext.push('/clients');
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.scan(PhosphorIconsStyle.regular)),
                title: Text(localizations.scanReceipt),
                trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                onTap: () {
                  Navigator.pop(modalContext);
                  navigatorContext.push('/receipt-uploader');
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.scribble(PhosphorIconsStyle.regular)),
                title: Text(localizations.digitalSignature),
                trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                onTap: () {
                  Navigator.pop(modalContext);
                  navigatorContext.push('/digital-signature');
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
                title: Text(localizations.profile),
                trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                onTap: () {
                  Navigator.pop(modalContext);
                  navigatorContext.push('/profile');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              ref.read(currentNavigationIndexProvider.notifier).state = index;
            },
            children: _mainScreens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isSmallScreen 
                ? _buildScrollableNavigationBar(theme) 
                : _buildBottomNavigationBar(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.7),
                    theme.colorScheme.surface.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
      child: Row(
        children: [
          // Botón 1: Inicio
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
              label: localizations.home,
              index: 0,
              theme: theme,
            ),
          ),
          // Botón 2: Facturas
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.fileText(PhosphorIconsStyle.fill),
              label: localizations.invoices,
              index: 1,
              theme: theme,
            ),
          ),
          // Botón 3: Cotizaciones
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.clipboardText(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.clipboardText(PhosphorIconsStyle.fill),
              label: localizations.estimates,
              index: 2,
              theme: theme,
            ),
          ),
          // Botón 4: Gastos
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.wallet(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
              label: localizations.expenses,
              index: 3,
              theme: theme,
            ),
          ),
          // Botón 5: Reportes
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
              label: localizations.reports,
              index: 4,
              theme: theme,
            ),
          ),
          // Botón 6: Más
          Expanded(
            child: _buildCustomNavItem(
              icon: PhosphorIcons.dotsThree(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.dotsThree(PhosphorIconsStyle.fill),
              label: localizations.more,
              index: 5,
              theme: theme,
            ),
          ),
        ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableNavigationBar(ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    
    final scrollableItems = [
      {'icon': PhosphorIcons.house(PhosphorIconsStyle.regular), 'activeIcon': PhosphorIcons.house(PhosphorIconsStyle.fill), 'label': localizations.home, 'index': 0},
      {'icon': PhosphorIcons.fileText(PhosphorIconsStyle.regular), 'activeIcon': PhosphorIcons.fileText(PhosphorIconsStyle.fill), 'label': localizations.invoices, 'index': 1},
      {'icon': PhosphorIcons.clipboardText(PhosphorIconsStyle.regular), 'activeIcon': PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), 'label': localizations.estimates, 'index': 2},
      {'icon': PhosphorIcons.wallet(PhosphorIconsStyle.regular), 'activeIcon': PhosphorIcons.wallet(PhosphorIconsStyle.fill), 'label': localizations.expenses, 'index': 3},
      {'icon': PhosphorIcons.chartBar(PhosphorIconsStyle.regular), 'activeIcon': PhosphorIcons.chartBar(PhosphorIconsStyle.fill), 'label': localizations.reports, 'index': 4},
    ];
    
    final moreItem = {
      'icon': PhosphorIcons.dotsThree(PhosphorIconsStyle.regular), 
      'activeIcon': PhosphorIcons.dotsThree(PhosphorIconsStyle.fill), 
      'label': localizations.more, 
      'index': 5
    };
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.7),
                    theme.colorScheme.surface.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Sección scrollable para los primeros 5 items
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child: Row(
                        children: scrollableItems.map((item) {
                          final isSelected = _currentIndex == item['index'];
                          final label = item['label'] as String;
                          return Semantics(
                            label: label,
                            button: true,
                            selected: isSelected,
                            hint: isSelected ? 'Currently selected' : 'Double tap to navigate',
                            child: GestureDetector(
                              onTap: () async {
                                final canVibrate = await Haptics.canVibrate();
                                if (canVibrate) {
                                  await Haptics.vibrate(HapticsType.medium);
                                }
                                _onTabTapped(item['index'] as int);
                              },
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    const SizedBox(height: 2),
                                    Flexible(
                                      child: ExcludeSemantics(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // Línea separadora
                  Container(
                    width: 1,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                  
                  // Botón Más fijo con fondo azul
                  Semantics(
                    label: moreItem['label'] as String,
                    button: true,
                    hint: AppLocalizations.of(context).doubleTapToOpenMoreOptions,
                    child: Container(
                      width: 80,
                      constraints: const BoxConstraints.expand(width: 80),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(23),
                          bottomRight: Radius.circular(23),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final canVibrate = await Haptics.canVibrate();
                          if (canVibrate) {
                            await Haptics.vibrate(HapticsType.medium);
                          }
                          _onTabTapped(moreItem['index'] as int);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentIndex == moreItem['index']
                                  ? moreItem['activeIcon'] as IconData
                                  : moreItem['icon'] as IconData,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            ExcludeSemantics(
                              child: Text(
                                moreItem['label'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final bool isSelected = _currentIndex == index;

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      hint: isSelected ? 'Currently selected' : 'Double tap to navigate',
      child: GestureDetector(
        onTap: () async {
          // Haptic feedback - usando medium para que sea más perceptible
          final canVibrate = await Haptics.canVibrate();
          if (canVibrate) {
            await Haptics.vibrate(HapticsType.medium);
          }
          _onTabTapped(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 2),
              ExcludeSemantics(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Widget para pantallas que no deben mostrar el BottomNavigationBar
/// (como pantallas de detalle, configuración, etc.)
class SecondaryNavigation extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const SecondaryNavigation({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: child,
    );
  }
}
