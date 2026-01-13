# 🚀 Pasos Finales para Publicar en App Store

## ✅ Correcciones Implementadas

Las siguientes correcciones críticas ya están implementadas:

1. ✅ **Permisos agregados a Info.plist:**
   - `NSPhotoLibraryAddUsageDescription` - Guardar imágenes
   - `NSFaceIDUsageDescription` - Autenticación biométrica

2. ✅ **PrivacyInfo.xcprivacy creado:**
   - Declaración de datos recopilados
   - APIs sensibles declaradas
   - Cumple con iOS 17+ requirements

3. ✅ **Entitlements de producción configurados:**
   - `aps-environment` = production en RunnerRelease.entitlements
   - Apple Sign In configurado

4. ✅ **Descripción actualizada:**
   - pubspec.yaml con descripción profesional

5. ✅ **Metadata template creado:**
   - `docs/APP_STORE_METADATA.md` con toda la información necesaria

---

## ⚠️ ACCIONES REQUERIDAS ANTES DE SUBIR

### 1. Configurar Google Client ID (CRÍTICO)

**Archivo:** `ios/Runner/Info.plist`

**Línea 39:**
```xml
<key>GIDClientID</key>
<string>YOUR_GOOGLE_CLIENT_ID_HERE</string>
```

**Acción requerida:**
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a "Credenciales"
4. Copia el Client ID de iOS
5. Reemplaza `YOUR_GOOGLE_CLIENT_ID_HERE` con el ID real

**Ejemplo:**
```xml
<key>GIDClientID</key>
<string>123456789-abcdefghijklmnop.apps.googleusercontent.com</string>
```

---

### 2. Crear URLs Requeridas

Necesitas crear y publicar las siguientes páginas web:

#### A. Privacy Policy (OBLIGATORIO)
- **URL sugerida:** `https://facturo.app/privacy` o `https://tudominio.com/privacy`
- **Contenido mínimo:**
  - Qué datos recopilas (email, nombre, fotos, datos financieros)
  - Cómo los usas
  - Cómo los proteges
  - Derechos del usuario
  - Contacto

#### B. Support URL (OBLIGATORIO)
- **URL sugerida:** `https://facturo.app/support` o email: `support@facturo.app`
- **Contenido mínimo:**
  - FAQ
  - Formulario de contacto
  - Email de soporte

#### C. Terms of Service (RECOMENDADO)
- **URL sugerida:** `https://facturo.app/terms`
- **Contenido mínimo:**
  - Términos de uso
  - Condiciones de suscripción
  - Política de reembolsos

**Plantillas disponibles:**
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
- [Terms Generator](https://www.termsandconditionsgenerator.com/)

---

### 3. Preparar Screenshots

**Requerido por App Store:**

#### iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)
- Resolución: 1290 x 2796 pixels
- Cantidad: 3-10 screenshots
- **Sugeridos:**
  1. Dashboard con métricas
  2. Crear factura
  3. Lista de facturas
  4. OCR escaneando
  5. Gestión de clientes
  6. Reportes

#### iPhone 5.5" (iPhone 8 Plus)
- Resolución: 1242 x 2208 pixels
- Cantidad: 3-10 screenshots
- Mismos screenshots optimizados

**Herramientas recomendadas:**
- Simulator de Xcode
- [Screenshot Framer](https://www.screenshotframer.com/)
- [App Store Screenshot Generator](https://www.appstorescreenshot.com/)

---

### 4. Configurar App Store Connect

#### A. Crear App en App Store Connect
1. Ve a [App Store Connect](https://appstoreconnect.apple.com/)
2. Click en "My Apps" → "+" → "New App"
3. Completa:
   - Platform: iOS
   - Name: Facturo
   - Primary Language: Spanish
   - Bundle ID: (selecciona el de tu proyecto)
   - SKU: facturo-ios-app

#### B. Completar Información de la App
Usa el archivo `docs/APP_STORE_METADATA.md` para completar:
- App Name
- Subtitle
- Description (Spanish & English)
- Keywords
- Support URL
- Privacy Policy URL
- Screenshots
- App Icon (1024x1024)

#### C. Configurar In-App Purchases
1. Ve a "Features" → "In-App Purchases"
2. Crea dos productos:
   - **ID:** `facturo_pro_monthly`
     - Type: Auto-Renewable Subscription
     - Price: $9.99
   - **ID:** `facturo_pro_annual`
     - Type: Auto-Renewable Subscription
     - Price: $99.99

#### D. Configurar Subscription Groups
1. Crea grupo: "Facturo Pro"
2. Agrega ambas suscripciones al grupo
3. Configura niveles (Annual > Monthly)

---

### 5. Generar Build de Producción

#### A. Actualizar Version y Build Number
```bash
# En pubspec.yaml, incrementa la versión
version: 1.0.0+1  # Ya está configurado
```

#### B. Limpiar y Generar Build
```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Generar localizations
flutter gen-l10n

# Crear build de iOS
flutter build ios --release
```

#### C. Abrir en Xcode
```bash
open ios/Runner.xcworkspace
```

#### D. Configurar Signing
1. En Xcode, selecciona el target "Runner"
2. Ve a "Signing & Capabilities"
3. Selecciona tu Team
4. Verifica que "Automatically manage signing" esté activado
5. Verifica que el Bundle Identifier sea correcto

#### E. Archivar y Subir
1. En Xcode: Product → Archive
2. Espera a que termine el archive
3. Click en "Distribute App"
4. Selecciona "App Store Connect"
5. Sigue el wizard hasta subir

---

### 6. Testing Pre-Submission

#### A. TestFlight (RECOMENDADO)
1. Sube el build a App Store Connect
2. Espera procesamiento (15-30 min)
3. Agrega testers internos
4. Prueba todas las funcionalidades:
   - ✓ Login (Email, Google, Apple)
   - ✓ Crear factura
   - ✓ OCR scanning
   - ✓ In-App Purchases (sandbox)
   - ✓ Gestión de clientes
   - ✓ Reportes
   - ✓ Sincronización

#### B. Sandbox Testing para IAP
1. Crea usuarios de prueba en App Store Connect
2. Cierra sesión de App Store en el dispositivo
3. Prueba compras con usuarios sandbox
4. Verifica que las suscripciones se activen correctamente

---

### 7. Enviar para Revisión

#### A. Completar App Review Information
1. Contact Information (tu email y teléfono)
2. Demo Account (si es necesario)
3. Notes for Review:
```
Facturo es una app de gestión de facturas y finanzas para pequeños negocios.

Funcionalidades principales:
- Creación de facturas y cotizaciones
- Escaneo OCR de documentos
- Gestión de clientes y gastos
- Suscripción Pro para features ilimitados

Login de prueba (opcional):
Email: demo@facturo.app
Password: Demo123!

Notas:
- Apple Sign In está completamente implementado
- In-App Purchases configurados en sandbox
- Todos los permisos tienen justificación clara
```

#### B. Export Compliance
- Does your app use encryption? **YES**
- Is it exempt? **YES** (HTTPS only)

#### C. Submit for Review
1. Revisa toda la información
2. Click "Submit for Review"
3. Espera 24-48 horas para la revisión

---

## 📋 Checklist Final

Antes de enviar, verifica:

### Configuración
- [ ] Google Client ID configurado en Info.plist
- [ ] Privacy Policy URL agregada
- [ ] Support URL agregada
- [ ] Terms URL agregada (opcional)
- [ ] Screenshots preparados (6.7" y 5.5")
- [ ] App Icon 1024x1024 listo

### App Store Connect
- [ ] App creada en App Store Connect
- [ ] Metadata completado (ES + EN)
- [ ] Screenshots subidos
- [ ] In-App Purchases configurados
- [ ] Subscription Group creado
- [ ] Pricing configurado

### Testing
- [ ] Build de release funciona
- [ ] Apple Sign In probado
- [ ] Google Sign In probado
- [ ] In-App Purchases probados en sandbox
- [ ] OCR funciona correctamente
- [ ] Todas las features probadas
- [ ] Probado en dispositivo real

### Legal
- [ ] Privacy Policy publicada
- [ ] Terms of Service publicados
- [ ] Contact information correcta
- [ ] Tax forms completados (si aplica)
- [ ] Banking info agregada (para IAP)

### Build
- [ ] Version number correcto
- [ ] Build number incrementado
- [ ] Signing configurado
- [ ] Archive creado exitosamente
- [ ] Build subido a App Store Connect
- [ ] Build procesado sin errores

---

## 🎯 Timeline Estimado

1. **Configuración URLs y screenshots:** 2-4 horas
2. **Configurar App Store Connect:** 1-2 horas
3. **Testing en TestFlight:** 1-3 días
4. **Revisión de Apple:** 24-48 horas
5. **Total:** 3-7 días

---

## 🆘 Soporte y Recursos

### Si Apple rechaza la app:

**Razones comunes:**
1. **Privacy Policy no accesible** → Verifica que la URL funcione
2. **Screenshots no representativos** → Usa screenshots reales de la app
3. **IAP no funciona** → Prueba en sandbox primero
4. **Metadata engañoso** → Asegúrate que la descripción sea precisa
5. **Permisos sin justificación** → Ya están configurados correctamente

### Recursos útiles:
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Common App Rejections](https://developer.apple.com/app-store/review/rejections/)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)

---

## ✅ Estado Actual

**Configuración técnica:** ✅ COMPLETA
**Permisos iOS:** ✅ COMPLETOS
**Privacy Manifest:** ✅ CREADO
**Entitlements:** ✅ CONFIGURADOS

**Pendiente (requiere acción manual):**
- ⏳ Configurar Google Client ID
- ⏳ Crear y publicar Privacy Policy
- ⏳ Crear y publicar Support URL
- ⏳ Preparar screenshots
- ⏳ Configurar App Store Connect
- ⏳ Subir build

**Tiempo estimado para completar pendientes:** 4-6 horas

---

**¡La app está técnicamente lista para la App Store!**
Solo faltan los pasos administrativos y de contenido que requieren acción manual.

**Última actualización:** 27 de Diciembre, 2024
