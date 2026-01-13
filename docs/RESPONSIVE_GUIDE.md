# Guía de Diseño Responsive - Facturo App

## 📱 Implementación de flutter_screenutil

Esta aplicación utiliza `flutter_screenutil` para hacer que todos los widgets se adapten automáticamente a diferentes tamaños de pantalla.

## 🚀 Cómo usar las utilidades responsive

### 1. Importar las utilidades

```dart
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/constants/app_sizes.dart';
```

### 2. Tamaños responsivos básicos

```dart
// Ancho responsive
double width = ResponsiveUtils.w(100);

// Alto responsive  
double height = ResponsiveUtils.h(50);

// Tamaño de fuente responsive
double fontSize = ResponsiveUtils.sp(16);

// Radio de borde responsive
double radius = ResponsiveUtils.r(8);
```

### 3. Usando AppSizes con utilidades responsive

```dart
// Padding responsive
EdgeInsets padding = AppSizes.responsivePaddingAll(16);

// Padding simétrico responsive
EdgeInsets paddingSym = AppSizes.responsivePaddingSymmetric(
  horizontal: 16,
  vertical: 8,
);

// Radio de borde responsive
BorderRadius borderRadius = AppSizes.responsiveRadius(12);
```

### 4. Detección de tipo de pantalla

```dart
// Verificar tipo de dispositivo
if (ResponsiveUtils.isMobile) {
  // Código para móviles
} else if (ResponsiveUtils.isTablet) {
  // Código para tablets
} else if (ResponsiveUtils.isDesktop) {
  // Código para desktop
}

// O usar las propiedades de tamaño
if (ResponsiveUtils.isSmallScreen) {
  // Pantalla pequeña (< 600px)
} else if (ResponsiveUtils.isMediumScreen) {
  // Pantalla mediana (600-900px)
} else if (ResponsiveUtils.isLargeScreen) {
  // Pantalla grande (> 900px)
}
```

### 5. Ejemplos prácticos

#### Widget de texto responsive
```dart
Text(
  'Mi texto',
  style: TextStyle(
    fontSize: AppSizes.responsiveSp(18),
    fontWeight: FontWeight.w600,
  ),
)
```

#### Container responsive
```dart
Container(
  width: ResponsiveUtils.isMobile 
      ? ResponsiveUtils.screenWidth - AppSizes.responsiveW(32)
      : AppSizes.responsiveW(400),
  height: AppSizes.responsiveH(200),
  padding: AppSizes.responsivePaddingAll(16),
  decoration: BoxDecoration(
    borderRadius: AppSizes.responsiveRadius(12),
  ),
  child: // tu contenido
)
```

#### Botón responsive
```dart
SizedBox(
  width: ResponsiveUtils.isMobile 
      ? double.infinity 
      : AppSizes.responsiveW(200),
  height: AppSizes.responsiveH(48),
  child: ElevatedButton(
    onPressed: () {},
    child: Text(
      'Mi Botón',
      style: TextStyle(
        fontSize: AppSizes.responsiveSp(16),
      ),
    ),
  ),
)
```

#### Grid responsive
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.isMobile ? 2 : 4,
    crossAxisSpacing: AppSizes.responsiveW(8),
    mainAxisSpacing: AppSizes.responsiveH(8),
    childAspectRatio: ResponsiveUtils.isMobile ? 1.2 : 1.5,
  ),
  // ... resto del código
)
```

## 📐 Tamaño de diseño base

La aplicación está configurada con un tamaño de diseño base de **375x812** (iPhone X), lo que significa que todos los tamaños se escalan proporcionalmente desde esta referencia.

## 🎯 Mejores prácticas

1. **Siempre usa las utilidades responsive** en lugar de valores fijos
2. **Usa `ResponsiveUtils.isMobile/Tablet/Desktop`** para lógica condicional
3. **Aplica `AppSizes.responsiveSp()`** a todos los tamaños de fuente
4. **Usa `AppSizes.responsivePadding()`** para espaciado
5. **Aplica `AppSizes.responsiveRadius()`** para bordes redondeados

## 🔧 Configuración

La configuración se encuentra en `lib/main.dart`:

```dart
ScreenUtilInit(
  designSize: const Size(375, 812), // iPhone X design size
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return // tu app
  },
)
```

## 📱 Dispositivos soportados

- ✅ iPhone SE (375x667)
- ✅ iPhone 12/13/14 (390x844)
- ✅ iPhone 12/13/14 Pro Max (428x926)
- ✅ iPhone 16 Pro Max (430x932)
- ✅ iPad (768x1024)
- ✅ iPad Pro (1024x1366)
- ✅ Android phones (varios tamaños)
- ✅ Android tablets (varios tamaños)

## 🚨 Notas importantes

- **No uses valores fijos** como `width: 100` o `fontSize: 16`
- **Siempre usa las utilidades responsive** para mantener consistencia
- **Prueba en diferentes dispositivos** para verificar la adaptación
- **Usa hot reload** para ver cambios rápidamente

## 📖 Ejemplo completo

Revisa `lib/common/widgets/responsive_example_widget.dart` para ver un ejemplo completo de implementación responsive. 