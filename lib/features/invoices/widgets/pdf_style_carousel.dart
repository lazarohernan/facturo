import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../services/pdf_generator_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class PDFStyleCarousel extends StatefulWidget {
  final PDFStyle selectedStyle;
  final Function(PDFStyle) onStyleChanged;
  final VoidCallback? onToggleHide;
  final bool isShown;

  const PDFStyleCarousel({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
    this.onToggleHide,
    this.isShown = true,
  });

  @override
  State<PDFStyleCarousel> createState() => _PDFStyleCarouselState();
}

class _PDFStyleCarouselState extends State<PDFStyleCarousel> {
  late PageController _pageController;
  late PDFStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.selectedStyle;
    final initialPage = PDFStyle.values.indexOf(_currentStyle);
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.32,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getStyleColor(PDFStyle style) {
    switch (style) {
      case PDFStyle.executive:
        return const Color(0xFF1a1a2e);
      case PDFStyle.corporate:
        return const Color(0xFF003d82);
      case PDFStyle.elegant:
        return const Color(0xFF4a4a4a);
      case PDFStyle.tech:
        return const Color(0xFF00d4ff);
      case PDFStyle.creative:
        return const Color(0xFFff6b6b);
      case PDFStyle.professional:
        return const Color(0xFF2c3e50);
      case PDFStyle.boutique:
        return const Color(0xFFc9a959);
      case PDFStyle.bold:
        return const Color(0xFFe63946);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.palette(PhosphorIconsStyle.fill),
                  size: 20,
                  color: _getStyleColor(_currentStyle),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).pdfStyle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStyleColor(_currentStyle).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    PDFGeneratorService.styleNames[_currentStyle] ?? '',
                    style: TextStyle(
                      color: _getStyleColor(_currentStyle),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.onToggleHide != null)
                  InkWell(
                    onTap: widget.onToggleHide,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.isShown ? 'Ocultar' : 'Estilos',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            widget.isShown ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 110,
              child: PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.none,
                onPageChanged: (index) {
                  final newStyle = PDFStyle.values[index];
                  setState(() {
                    _currentStyle = newStyle;
                  });
                  widget.onStyleChanged(newStyle);
                },
                itemCount: PDFStyle.values.length,
                itemBuilder: (context, index) {
                  final style = PDFStyle.values[index];
                  final isSelected = style == _currentStyle;
                  
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _StyleCard(
                      style: style,
                      isSelected: isSelected,
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final PDFStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getStyleIcon() {
    switch (style) {
      case PDFStyle.executive:
        return PhosphorIcons.crown(PhosphorIconsStyle.fill);
      case PDFStyle.corporate:
        return PhosphorIcons.buildings(PhosphorIconsStyle.fill);
      case PDFStyle.elegant:
        return PhosphorIcons.diamond(PhosphorIconsStyle.fill);
      case PDFStyle.tech:
        return PhosphorIcons.lightning(PhosphorIconsStyle.fill);
      case PDFStyle.creative:
        return PhosphorIcons.palette(PhosphorIconsStyle.fill);
      case PDFStyle.professional:
        return PhosphorIcons.briefcase(PhosphorIconsStyle.fill);
      case PDFStyle.boutique:
        return PhosphorIcons.sparkle(PhosphorIconsStyle.fill);
      case PDFStyle.bold:
        return PhosphorIcons.fire(PhosphorIconsStyle.fill);
    }
  }

  LinearGradient _getGradient() {
    switch (style) {
      case PDFStyle.executive:
        return const LinearGradient(
          colors: [Color(0xFF2c3e6b), Color(0xFFd4af37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.corporate:
        return const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.elegant:
        return const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFFD7CCC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.tech:
        return const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.creative:
        return const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.professional:
        return const LinearGradient(
          colors: [Color(0xFF455A64), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.boutique:
        return const LinearGradient(
          colors: [Color(0xFFD4A843), Color(0xFF8D6E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PDFStyle.bold:
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _PatternPainter(style),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with elevated background
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getStyleIcon(),
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    PDFGeneratorService.styleNames[style] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.25,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Selected indicator
                  if (isSelected) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final PDFStyle style;

  _PatternPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (style) {
      case PDFStyle.executive:
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(size.width * 0.7, size.height * 0.2 + i * 15),
            3 + i * 2,
            paint,
          );
        }
        break;
      case PDFStyle.corporate:
        for (var i = 0; i < 5; i++) {
          canvas.drawLine(
            Offset(size.width * 0.6 + i * 8, 0),
            Offset(size.width * 0.6 + i * 8, size.height),
            paint,
          );
        }
        break;
      case PDFStyle.elegant:
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(size.width * 0.5, i * 20.0),
            Offset(size.width, i * 20.0),
            paint,
          );
        }
        break;
      case PDFStyle.tech:
        for (var i = 0; i < 4; i++) {
          canvas.drawCircle(
            Offset(size.width * 0.6 + i * 12, size.height * 0.3),
            2,
            paint,
          );
        }
        break;
      case PDFStyle.creative:
        for (var i = 0; i < 4; i++) {
          for (var j = 0; j < 3; j++) {
            canvas.drawCircle(
              Offset(size.width * 0.5 + i * 10, j * 20.0),
              1.5,
              paint..style = PaintingStyle.fill,
            );
          }
        }
        break;
      case PDFStyle.professional:
        for (var i = 0; i < 4; i++) {
          canvas.drawLine(
            Offset(size.width * 0.6, i * 15.0),
            Offset(size.width, i * 15.0),
            paint,
          );
        }
        break;
      case PDFStyle.boutique:
        canvas.drawCircle(
          Offset(size.width * 0.75, size.height * 0.25),
          8,
          paint,
        );
        break;
      case PDFStyle.bold:
        for (var i = 0; i < 3; i++) {
          canvas.drawRect(
            Rect.fromLTWH(size.width * 0.6 + i * 10, size.height * 0.2, 6, 6),
            paint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
