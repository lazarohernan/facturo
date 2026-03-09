import 'package:flutter/material.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/constants/app_sizes.dart';

/// Widget de ejemplo que muestra cómo usar las utilidades responsive
class ResponsiveExampleWidget extends StatelessWidget {
  const ResponsiveExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ejemplo Responsive',
          style: TextStyle(fontSize: AppSizes.responsiveSp(18)),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSizes.responsivePaddingAll(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ejemplo de texto responsive
            Text(
              'Título Principal',
              style: TextStyle(
                fontSize: AppSizes.responsiveSp(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.responsiveH(16)),

            // Ejemplo de tarjeta responsive
            Container(
              width: ResponsiveUtils.isMobile
                  ? ResponsiveUtils.screenWidth - AppSizes.responsiveW(32)
                  : AppSizes.responsiveW(400),
              padding: AppSizes.responsivePaddingAll(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppSizes.responsiveRadius(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarjeta Responsive',
                    style: TextStyle(
                      fontSize: AppSizes.responsiveSp(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSizes.responsiveH(8)),
                  Text(
                    'Esta tarjeta se adapta automáticamente al tamaño de la pantalla. En móviles ocupa todo el ancho disponible, en tablets y desktop tiene un ancho fijo.',
                    style: TextStyle(
                      fontSize: AppSizes.responsiveSp(14),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.responsiveH(16)),

            // Ejemplo de botón responsive
            SizedBox(
              width: ResponsiveUtils.isMobile
                  ? double.infinity
                  : AppSizes.responsiveW(200),
              height: AppSizes.responsiveH(48),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSizes.responsiveRadius(8),
                  ),
                ),
                child: Text(
                  'Botón Responsive',
                  style: TextStyle(
                    fontSize: AppSizes.responsiveSp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.responsiveH(24)),

            // Información del dispositivo
            Container(
              padding: AppSizes.responsivePaddingAll(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppSizes.responsiveRadius(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Dispositivo',
                    style: TextStyle(
                      fontSize: AppSizes.responsiveSp(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: AppSizes.responsiveH(8)),
                  _buildInfoRow('Tipo de pantalla:', _getScreenType()),
                  _buildInfoRow('Ancho:',
                      '${ResponsiveUtils.screenWidth.toStringAsFixed(1)}px'),
                  _buildInfoRow('Alto:',
                      '${ResponsiveUtils.screenHeight.toStringAsFixed(1)}px'),
                  _buildInfoRow('Densidad de píxeles:',
                      ResponsiveUtils.pixelRatio.toStringAsFixed(2)),
                  _buildInfoRow('Status bar:',
                      '${ResponsiveUtils.statusBarHeight.toStringAsFixed(1)}px'),
                ],
              ),
            ),
            SizedBox(height: AppSizes.responsiveH(24)),

            // Grid responsive
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.isMobile ? 2 : 4,
                crossAxisSpacing: AppSizes.responsiveW(8),
                mainAxisSpacing: AppSizes.responsiveH(8),
                childAspectRatio: ResponsiveUtils.isMobile ? 1.2 : 1.5,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: AppSizes.responsiveRadius(8),
                  ),
                  child: Center(
                    child: Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: AppSizes.responsiveSp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppSizes.responsivePaddingSymmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.responsiveSp(12),
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(width: AppSizes.responsiveW(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.responsiveSp(12),
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenType() {
    if (ResponsiveUtils.isMobile) return 'Móvil';
    if (ResponsiveUtils.isTablet) return 'Tablet';
    return 'Desktop';
  }
}
