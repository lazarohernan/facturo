# 📚 Documentación del Proyecto Facturo

## 📋 Índice de Documentos

### 🔍 **OCR (Reconocimiento Óptico de Caracteres)**
- **[OCR_USING_EXISTING_TABLE.md](OCR_USING_EXISTING_TABLE.md)** - Implementación completa del sistema OCR usando receipt_reader
  - Integración con Google ML Kit
  - Procesamiento offline de facturas
  - Almacenamiento en tabla `ocr_scans` de Supabase
  - Límite freemium (3 usos gratuitos)

### 💰 **Sistema Freemium**
- **[FREEMIUM_IMPLEMENTATION_COMPLETE.md](FREEMIUM_IMPLEMENTATION_COMPLETE.md)** - Implementación del sistema de límites freemium
  - Límites por entidad (clientes, facturas, gastos, OCR)
  - Integración con UI y navegación
  - Paywall automático
  - Gestión de suscripciones

## 🚀 **Estado Actual del Proyecto**

### ✅ **Funcionalidades Implementadas:**
- **OCR Offline**: Procesamiento de facturas con receipt_reader
- **Sistema Freemium**: Límites y paywalls automáticos
- **Base de Datos**: Supabase con RLS activado
- **UI/UX**: Interfaz moderna y responsive
- **Navegación**: Go Router con autenticación

### 🔧 **Tecnologías Usadas:**
- **Flutter**: Framework principal
- **Supabase**: Backend y base de datos
- **receipt_reader**: OCR offline
- **Google ML Kit**: Procesamiento de imágenes
- **Riverpod**: State management
- **Go Router**: Navegación

## 📱 **Cómo Usar**

### 1. **Procesamiento OCR**
```bash
# Navegar a la funcionalidad OCR
flutter run
# Ir a /receipt-reader
```

### 2. **Límites Freemium**
- Clientes: 3 gratuitos
- Facturas: 5 gratuitos
- Gastos: 5 gratuitos
- OCR: 3 gratuitos

### 3. **Base de Datos**
- Tabla principal: `ocr_scans`
- Autenticación: Supabase Auth
- RLS: Row Level Security activado

## 📖 **Referencias**

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [receipt_reader Package](https://pub.dev/packages/receipt_reader)

---

**Última actualización**: Diciembre 2024
**Versión**: 1.0.0
