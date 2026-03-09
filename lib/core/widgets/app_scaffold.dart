import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A reusable scaffold without drawer
/// This helps maintain consistency across all screens
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final bool? showBackButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton,
  });

  Widget? _buildLeading(BuildContext context) {
    // Si showBackButton está explícitamente definido, usarlo
    if (showBackButton != null) {
      if (showBackButton!) {
        // Verificar si podemos hacer pop antes de mostrar el botón
        final canPop = context.canPop();
        if (canPop) {
          return IconButton(
            icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular)),
            onPressed: () {
              try {
                context.pop();
              } catch (e) {
                // Si falla el pop, intentar navegar a la ruta anterior conocida
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
          );
        }
        // Si no podemos hacer pop, no mostrar el botón
        return null;
      }
      return null;
    }
    
    // Si podemos regresar, mostrar botón de regresar
    if (context.canPop()) {
      return IconButton(
        icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular)),
        onPressed: () {
          try {
            context.pop();
          } catch (e) {
            // Si falla el pop, intentar navegar a la ruta anterior conocida
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
      );
    }
    
    // En otros casos, no mostrar leading
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: _buildLeading(context),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
