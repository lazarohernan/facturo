// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Facturo';

  @override
  String get profile => 'Perfil';

  @override
  String get profileInformation => 'Información del Perfil';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get businessName => 'Nombre del Negocio';

  @override
  String get businessNumber => 'Número del Negocio';

  @override
  String get address => 'Dirección';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get email => 'Email';

  @override
  String get website => 'Sitio Web';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get businessInformation => 'Información de Empresa';

  @override
  String get digitalSignature => 'Firma Digital';

  @override
  String get profilePhoto => 'Foto de Perfil';

  @override
  String get selectProfilePhoto => 'Seleccionar Foto de Perfil';

  @override
  String get profileImageCleared => 'Imagen de perfil eliminada exitosamente';

  @override
  String get businessLogo => 'Logo del Negocio';

  @override
  String get selectLogo => 'Seleccionar Logo';

  @override
  String get deleteLogo => 'Eliminar Logo';

  @override
  String get changeLogo => 'Cambiar Logo';

  @override
  String get edit => 'Editar';

  @override
  String get editing => 'Editando';

  @override
  String get viewMode => 'Modo Visualización';

  @override
  String get editMode => 'Modo Edición';

  @override
  String get businessInfoSaved =>
      'Información del negocio guardada exitosamente';

  @override
  String get errorSavingBusinessInfo =>
      'Error al guardar la información del negocio';

  @override
  String get selectImageError => 'Error al seleccionar imagen';

  @override
  String get businessInfoUpdated =>
      'Información del negocio actualizada exitosamente';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado exitosamente';

  @override
  String get errorSavingProfile => 'Error al guardar el perfil';

  @override
  String get invoices => 'Facturas';

  @override
  String get clients => 'Clientes';

  @override
  String get expenses => 'Gastos';

  @override
  String get categories => 'Categorías';

  @override
  String get estimates => 'Cotizaciones';

  @override
  String get dashboard => 'Panel';

  @override
  String get home => 'Inicio';

  @override
  String get more => 'Más';

  @override
  String get scan => 'Escanear';

  @override
  String get languageSettings => 'Configuración de Idioma';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get changeLanguageDescription =>
      'Cambia el idioma de toda la aplicación';

  @override
  String get reports => 'Reportes';

  @override
  String get generateReports => 'Generar Reportes';

  @override
  String get selectDateRangeAndReportType =>
      'Selecciona un rango de fechas y tipo de reporte para generar reportes.';

  @override
  String get availableReports => 'Reportes Disponibles';

  @override
  String get invoicesReport => 'Reporte de Facturas';

  @override
  String get invoicesReportDescription =>
      'Exporta todos los datos de facturas incluyendo detalles del cliente, montos y estado de pago.';

  @override
  String get estimatesReport => 'Reporte de Cotizaciones';

  @override
  String get estimatesReportDescription =>
      'Exporta todos los datos de cotizaciones incluyendo detalles del cliente y montos.';

  @override
  String get expensesReport => 'Reporte de Gastos';

  @override
  String get expensesReportDescription =>
      'Exporta todos los datos de gastos incluyendo categorías y montos.';

  @override
  String get dateRange => 'Rango de Fechas';

  @override
  String get selectDateRange => 'Seleccionar Rango de Fechas';

  @override
  String get noInvoicesFoundInRange =>
      'No se encontraron facturas en el rango de fechas seleccionado';

  @override
  String get noEstimatesFoundInRange =>
      'No se encontraron cotizaciones en el rango de fechas seleccionado';

  @override
  String get noExpensesFoundInRange =>
      'No se encontraron gastos en el rango de fechas seleccionado';

  @override
  String get errorExportingInvoices => 'Error al exportar facturas';

  @override
  String get errorExportingEstimates => 'Error al exportar cotizaciones';

  @override
  String get errorExportingExpenses => 'Error al exportar gastos';

  @override
  String get profileAndSettings => 'Perfil y Configuración';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get confirmLogout => 'Confirmar Cierre de Sesión';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get anonymousLogoutWarning => '⚠️ Advertencia: Usuario Anónimo';

  @override
  String get anonymousLogoutMessage =>
      'Estás usando una cuenta anónima. Si cierras sesión, NO podrás recuperar tus datos (facturas, clientes, gastos, etc.) porque no hay forma de volver a iniciar sesión como usuario anónimo.\n\n¿Deseas crear una cuenta permanente antes de cerrar sesión para no perder tus datos?';

  @override
  String get preserveYourData => 'Preserva tus datos';

  @override
  String get paymentSuccessful => '¡Pago Exitoso!';

  @override
  String get createAccountToActivate =>
      'Crea tu cuenta para activar\ntu suscripción premium';

  @override
  String get convertAnonymousAccount =>
      'Convierte tu cuenta anónima en una permanente\npara no perder tus facturas y clientes';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get enterYourEmail => 'Ingresa tu correo electrónico';

  @override
  String get enterValidEmail => 'Por favor ingrese un email válido';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => 'Mínimo 6 caracteres';

  @override
  String get enterPassword => 'Ingresa una contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get confirmPasswordHint => 'Repite tu contraseña';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get acceptTermsAndPrivacy =>
      'Acepto los términos y condiciones y la política de privacidad';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get or => 'O';

  @override
  String get createAccountBeforeLogout => 'Crear Cuenta';

  @override
  String get logoutAnyway => 'Cerrar Sesión de Todas Formas';

  @override
  String get anonymousDataInfo =>
      'Nota: Si creas un nuevo usuario anónimo después de cerrar sesión, no recuperarás los datos de tu cuenta anterior.';

  @override
  String get noEmail => 'Sin email';

  @override
  String get noInformation => 'Sin información';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get freeVersion => 'Versión Gratuita';

  @override
  String get freemiumProgress => 'Progreso Freemium';

  @override
  String get upgradeToPro => 'Upgrade a Pro';

  @override
  String get nearLimit => '¡Cerca del límite!';

  @override
  String get upgradeToFacturoPro => 'Upgrade a Facturo Pro';

  @override
  String get unlockPremiumFeatures =>
      'Desbloquea todas las funcionalidades premium y haz crecer tu negocio';

  @override
  String get noActiveSubscription => 'No hay suscripción activa';

  @override
  String get selectPlanToAccess =>
      'Selecciona un plan para acceder a todas las funciones de Facturo';

  @override
  String get activeSubscription => 'Suscripción activa';

  @override
  String get expires => 'Vence';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get annualPlan => 'Plan Anual';

  @override
  String get unlimitedInvoicingMonthly =>
      'Facturación ilimitada renovada mensualmente';

  @override
  String get unlimitedInvoicingAnnual =>
      'Facturación ilimitada renovada anualmente';

  @override
  String get bestValue => 'Mejor valor';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get perMonth => '/mes';

  @override
  String get perYear => '/año';

  @override
  String savePercent(Object percent) {
    return 'Ahorra $percent%';
  }

  @override
  String get whatYouGetWithPro => '¿Qué obtienes con Pro?';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get storeNotAvailable =>
      'La tienda no está disponible en este momento. Inténtalo de nuevo más tarde.';

  @override
  String get purchaseRestoration => 'Restauración de compras iniciada';

  @override
  String get chooseThePlan =>
      'Elige el plan que mejor se adapte a tus necesidades';

  @override
  String get subscriptionPlans => 'Planes de Suscripción';

  @override
  String get autoRenewalIOS =>
      'Las suscripciones se renuevan automáticamente a menos que se cancelen al menos 24 horas antes del final del período actual. La cancelación se puede realizar en la configuración de tu cuenta de App Store.';

  @override
  String get autoRenewalAndroid =>
      'Las suscripciones se renuevan automáticamente a menos que se cancelen al menos 24 horas antes del final del período actual. La cancelación se puede realizar en la configuración de tu cuenta de Google Play.';

  @override
  String get sendingEmail => 'Enviando correo electrónico...';

  @override
  String get emailSentSuccessfully => 'Correo electrónico enviado con éxito';

  @override
  String get errorSendingEmail => 'Error al enviar email';

  @override
  String get noClientEmail =>
      'No hay correo electrónico del cliente disponible. Por favor actualice el correo electrónico del cliente primero.';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPasswordInstructions =>
      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña';

  @override
  String get emailAddress => 'Correo Electrónico';

  @override
  String get sendResetLink => 'Enviar Enlace de Restablecimiento';

  @override
  String get passwordResetEmailSent => 'Correo de restablecimiento enviado';

  @override
  String get passwordResetSuccess =>
      'Se ha enviado un enlace de restablecimiento a tu correo electrónico';

  @override
  String get tryAnotherEmail => 'Intentar con otro correo';

  @override
  String get rememberPassword => '¿Recuerdas tu contraseña?';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get resetLinkSent =>
      'Enlace de restablecimiento enviado a tu correo electrónico';

  @override
  String get errorSendingResetLink =>
      'Error al enviar enlace de restablecimiento';

  @override
  String get emailSent => 'Correo Enviado';

  @override
  String get checkYourEmail => 'Revisa tu correo electrónico para continuar';

  @override
  String get enterEmailToResetPassword =>
      'Ingresa tu email y te enviaremos instrucciones para restablecer tu contraseña';

  @override
  String get passwordResetInstructions =>
      'Hemos enviado un correo con instrucciones para restablecer tu contraseña. Por favor revisa tu bandeja de entrada y sigue los pasos indicados.';

  @override
  String get backToLogin => 'Volver a Iniciar Sesión';

  @override
  String get didntReceiveEmail => '¿No recibiste el correo? Reenviar';

  @override
  String get refreshData => 'Actualizar datos';

  @override
  String get financialOverview => 'Resumen Financiero';

  @override
  String get year => 'Año';

  @override
  String get outstanding => 'Pendiente';

  @override
  String get received => 'Recibido';

  @override
  String get netIncome => 'Ingreso Neto';

  @override
  String get incomeVsExpenses => 'Ingresos vs. Gastos';

  @override
  String get income => 'Ingresos';

  @override
  String get net => 'Neto';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get newInvoice => 'Nueva Factura';

  @override
  String get newEstimate => 'Nuevo Estimado';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get newClient => 'Nuevo Cliente';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get recentInvoices => 'Facturas Recientes';

  @override
  String get recentEstimates => 'Cotizaciones Recientes';

  @override
  String get seeAll => 'Ver Todo';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get noRecentInvoices => 'No hay facturas recientes';

  @override
  String get noDate => 'Sin fecha';

  @override
  String get noRecentEstimates => 'No hay cotizaciones recientes';

  @override
  String get totalClients => 'Total de\\nClientes';

  @override
  String get activeClients => 'Clientes\\nActivos';

  @override
  String get unpaidInvoices => 'Facturas\\nPendientes';

  @override
  String get paid => 'Pagado';

  @override
  String get unpaid => 'No pagado';

  @override
  String get active => 'Activa';

  @override
  String get expired => 'Vencida';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get addInvoice => 'Añadir Factura';

  @override
  String get searchInvoices => 'Buscar facturas...';

  @override
  String get searchByInvoiceNumber => 'Buscar por número de factura o notas...';

  @override
  String get noInvoicesFound => 'No se encontraron facturas';

  @override
  String get noInvoicesMatchSearch =>
      'Ninguna factura coincide con tu búsqueda';

  @override
  String get addYourFirstInvoice => 'Agregue su primer artículo a la factura';

  @override
  String get loadingInvoices => 'Cargando facturas...';

  @override
  String get invoiceMarkedAsPaid => 'Factura marcada como pagada';

  @override
  String get invoiceMarkedAsUnpaid => 'Factura marcada como pendiente';

  @override
  String get invoiceCreatedUpdated =>
      'Factura creada / actualizada exitosamente';

  @override
  String get deleteInvoice => 'Eliminar Factura';

  @override
  String get deleteInvoiceConfirmation =>
      '¿Estás seguro de que quieres eliminar esta factura?';

  @override
  String get deleteInvoiceWarning =>
      '¿Está seguro que desea eliminar este artículo?';

  @override
  String get invoiceDeletedSuccess => 'Factura eliminada exitosamente';

  @override
  String get view => 'Ver';

  @override
  String get delete => 'Eliminar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get search => 'Buscar';

  @override
  String get clear => 'Limpiar';

  @override
  String get noInvoiceNumber => 'Sin número de factura';

  @override
  String get addEstimate => 'Añadir Cotización';

  @override
  String get searchEstimates => 'Buscar cotizaciones...';

  @override
  String get searchByEstimateNumber =>
      'Buscar por número de cotización o notas...';

  @override
  String get noEstimatesFound => 'No se encontraron cotizaciones';

  @override
  String get noEstimatesMatchSearch =>
      'Ninguna cotización coincide con tu búsqueda';

  @override
  String get addYourFirstEstimate =>
      'Añade tu primera cotización pulsando el botón +';

  @override
  String get loadingEstimates => 'Cargando cotizaciones...';

  @override
  String get estimateMarkedAsActive => 'Cotización marcada como activa';

  @override
  String get estimateMarkedAsExpired => 'Cotización marcada como vencida';

  @override
  String get estimateCreatedUpdated =>
      'Cotización creada / actualizada exitosamente';

  @override
  String get deleteEstimate => 'Eliminar Cotización';

  @override
  String get deleteEstimateConfirmation =>
      '¿Estás seguro de que quieres eliminar esta cotización?';

  @override
  String get deleteEstimateWarning => 'Esta acción no se puede deshacer.';

  @override
  String get estimateDeletedSuccess => 'Cotización eliminada exitosamente';

  @override
  String get noEstimateNumber => 'Sin Número de Cotización';

  @override
  String get convertToInvoice => 'Convertir a Factura';

  @override
  String get estimateDetails => 'Detalles de Cotización';

  @override
  String get estimatePreview => 'Vista Previa';

  @override
  String get fillEstimateDetails =>
      'Por favor completa primero los detalles de la cotización';

  @override
  String get resetZoom => 'Restablecer Zoom';

  @override
  String get generatePDF => 'Generar PDF';

  @override
  String get sendInvoice => 'Enviar Factura';

  @override
  String get sendByEmail => 'Enviar por Email';

  @override
  String get printEstimate => 'Imprimir Cotización';

  @override
  String get downloadPDF => 'Descargar PDF';

  @override
  String get shareEstimate => 'Compartir Cotización';

  @override
  String get estimateNumber => 'Número de Cotización';

  @override
  String get estimateDate => 'Fecha de Cotización';

  @override
  String get expiryDate => 'Fecha de Vencimiento';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get clientInformation => 'Información del Cliente';

  @override
  String get selectClient => 'Seleccionar un cliente';

  @override
  String get noClientSelected => 'No hay cliente seleccionado';

  @override
  String get items => 'Ítems';

  @override
  String get addItem => 'Agregar Artículo';

  @override
  String get description => 'Descripción';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unitPrice => 'Precio Unitario';

  @override
  String get discount => 'Descuento';

  @override
  String get tax => 'Impuesto';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get totalAmount => 'Monto Total';

  @override
  String get notes => 'Notas';

  @override
  String get addNotes => 'Notas Adicionales';

  @override
  String get signature => 'Firma';

  @override
  String get addSignature => 'Añadir Firma';

  @override
  String get clearSignature => 'Limpiar Firma';

  @override
  String get scanInvoice => 'Escanear factura';

  @override
  String get processingInvoice => 'Procesando factura...';

  @override
  String get loadingImage => 'Cargando imagen...';

  @override
  String get imageLoaded => 'Imagen cargada';

  @override
  String get uploadingImage => 'Subiendo imagen';

  @override
  String get analyzingText => 'Analizando texto';

  @override
  String get textExtracted => 'Texto extraído';

  @override
  String get extractingData => 'Extrayendo datos...';

  @override
  String get dataExtracted => 'Datos extraídos';

  @override
  String get savingDocument => 'Guardando documento';

  @override
  String get processingCompleted => 'Procesamiento completado';

  @override
  String get processingError => 'Error en el procesamiento';

  @override
  String get goBack => 'Volver';

  @override
  String get selectImageToScan => 'Selecciona una imagen para escanear';

  @override
  String get processingImage => 'Procesando imagen...';

  @override
  String get ocrScanFromCamera => 'Escanear con la cámara';

  @override
  String get ocrScanFromCameraSubtitle =>
      'Toma una foto del recibo y escanéalo en segundos.';

  @override
  String get ocrUploadFromGallery => 'Cargar desde galería';

  @override
  String get ocrUploadFromGallerySubtitle =>
      'Selecciona una imagen existente para procesarla.';

  @override
  String get ocrPreviewTitle => 'Vista previa del documento';

  @override
  String get ocrAiProcessingTitle => 'Procesamiento inteligente';

  @override
  String get ocrAiProcessingSubtitle =>
      'Utilizamos IA para detectar datos relevantes y construir tu factura automáticamente.';

  @override
  String get tipsForPerfectScanning => 'Consejos para un escaneo perfecto';

  @override
  String get ocrTipGoodLighting =>
      'Asegúrate de que la imagen tenga buena iluminación';

  @override
  String get ocrTipAlignReceipt =>
      'Alinea el recibo dentro del marco y mantén la cámara firme.';

  @override
  String get ocrTipForBestResults =>
      'Utiliza el botón Escanear para procesar el documento.';

  @override
  String get usePhoto => 'Usar Foto';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get errorLoadingClient => 'Error al cargar cliente';

  @override
  String get errorImportingContact => 'Error al importar contacto';

  @override
  String get from => 'De';

  @override
  String get to => 'Para';

  @override
  String get phone => 'Teléfono';

  @override
  String get poNumber => 'Número de PO';

  @override
  String get errorSendingEstimate => 'Error al enviar la cotización';

  @override
  String get detail => 'Detalle';

  @override
  String get invoiceDetails => 'Detalles de Factura';

  @override
  String get invoicePreview => 'Vista Previa';

  @override
  String get fillInvoiceDetails =>
      'Por favor completa primero los detalles de la factura';

  @override
  String get printInvoice => 'Imprimir Factura';

  @override
  String get shareInvoice => 'Compartir Factura';

  @override
  String get invoiceNumber => 'Número de Factura';

  @override
  String get invoiceDate => 'Fecha de Factura';

  @override
  String get dueDate => 'Fecha de Vencimiento';

  @override
  String get markAsPaid => 'Marcar Pagado';

  @override
  String get markAsUnpaid => 'Marcar Pendiente';

  @override
  String get errorSendingInvoice => 'Error al enviar la factura';

  @override
  String get editClient => 'Editar Cliente';

  @override
  String get clientDetails => 'Detalles del Cliente';

  @override
  String get clientName => 'Nombre del Cliente';

  @override
  String get clientEmail => 'Email del Cliente';

  @override
  String get clientPhone => 'Teléfono del Cliente';

  @override
  String get clientAddress => 'Dirección del Cliente';

  @override
  String get clientCompany => 'Empresa del Cliente';

  @override
  String get clientNotes => 'Notas del Cliente';

  @override
  String get searchClients => 'Buscar clientes...';

  @override
  String get loadingClients => 'Cargando clientes...';

  @override
  String get clientCreatedUpdated =>
      'Cliente creado / actualizado exitosamente';

  @override
  String get deleteClient => 'Eliminar Cliente';

  @override
  String get deleteClientConfirmation =>
      '¿Estás seguro de que quieres eliminar este cliente?';

  @override
  String get deleteClientWarning => 'Esta acción no se puede deshacer.';

  @override
  String get clientDeletedSuccess => 'Cliente eliminado exitosamente';

  @override
  String get updateClient => 'Actualizar Cliente';

  @override
  String get enterClientName => 'Ingrese el nombre del cliente';

  @override
  String get pleaseEnterClientName => 'Por favor ingrese el nombre del cliente';

  @override
  String get pleaseEnterYourFullName => 'Por favor ingrese su nombre completo';

  @override
  String get enterClientEmail => 'Ingrese el email del cliente';

  @override
  String get enterClientPhone => 'Ingrese el teléfono del cliente';

  @override
  String get enterClientAddress => 'Ingrese la dirección del cliente';

  @override
  String get secondaryEmail => 'Email Secundario';

  @override
  String get enterSecondaryEmail => 'Ingrese email secundario (opcional)';

  @override
  String get mobile => 'Móvil';

  @override
  String get enterMobileNumber => 'Ingrese número de móvil';

  @override
  String get enterPhoneNumber => 'Ingrese número de teléfono';

  @override
  String get addressLine1 => 'Línea de Dirección 1';

  @override
  String get enterAddressLine1 => 'Ingrese línea de dirección 1';

  @override
  String get addressLine2 => 'Línea de Dirección 2';

  @override
  String get enterAddressLine2 => 'Ingrese línea de dirección 2 (opcional)';

  @override
  String get contactInformation => 'Información de Contacto';

  @override
  String get name => 'Nombre';

  @override
  String get addClient => 'Añadir Cliente';

  @override
  String get clientNotFound => 'Cliente no encontrado';

  @override
  String get retry => 'Reintentar';

  @override
  String get anErrorOccurred => 'Ha ocurrido un error';

  @override
  String get pleaseEnterValidEmail => 'Por favor ingresa un email válido';

  @override
  String get errorDeletingClient => 'Error al eliminar el cliente';

  @override
  String get selectExistingClient => 'Seleccionar cliente existente';

  @override
  String get orCreateNewClient => 'O crear nuevo cliente';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get expenseDetails => 'Detalles del Gasto';

  @override
  String get expenseName => 'Nombre del Gasto';

  @override
  String get expenseCategory => 'Categoría del Gasto';

  @override
  String get expenseAmount => 'Monto del Gasto';

  @override
  String get expenseDate => 'Fecha del Gasto';

  @override
  String get expenseNotes => 'Notas del Gasto';

  @override
  String get searchExpenses => 'Buscar gastos...';

  @override
  String get loadingExpenses => 'Cargando gastos...';

  @override
  String get expenseCreatedUpdated => 'Gasto creado / actualizado exitosamente';

  @override
  String get deleteExpense => 'Eliminar gasto';

  @override
  String get deleteExpenseConfirmation =>
      '¿Estás seguro de que quieres eliminar este gasto?';

  @override
  String get deleteExpenseWarning => 'Esta acción no se puede deshacer.';

  @override
  String get expenseDeletedSuccess => 'Gasto eliminado exitosamente';

  @override
  String get updateExpense => 'Actualizar Gasto';

  @override
  String get pleaseEnterExpenseName => 'Por favor ingrese el nombre del gasto';

  @override
  String get pleaseEnterExpenseAmount => 'Por favor ingrese el monto del gasto';

  @override
  String get invalidAmount => 'Monto inválido';

  @override
  String get pleaseSelectCategory => 'Por favor selecciona una categoría';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get overdue => 'Vencido';

  @override
  String get jan => 'Ene';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Abr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Ago';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dic';

  @override
  String get invoice => 'Factura';

  @override
  String get client => 'Cliente';

  @override
  String get expense => 'Gasto';

  @override
  String get estimate => 'Cotización';

  @override
  String get save20 => 'Ahorra 20%';

  @override
  String get notNow => 'Ahora no';

  @override
  String get errorLoadingData => 'Error al cargar los datos';

  @override
  String get pleaseTryAgainLater => 'Por favor, inténtalo de nuevo más tarde.';

  @override
  String get welcomeToFacturoPro => '¡Bienvenido a Facturo Pro!';

  @override
  String get discoverPremiumFeatures =>
      'Descubre todas las funcionalidades premium y haz crecer tu negocio.';

  @override
  String get limitReached => '¡Has alcanzado tu límite!';

  @override
  String usedAllFreeInvoices(int count) {
    return 'Has usado todas tus $count facturas gratuitas.';
  }

  @override
  String get almostAtLimit => '¡Casi en el límite!';

  @override
  String remainingFreeInvoices(int count) {
    return 'Te quedan $count facturas gratuitas.';
  }

  @override
  String get yourCurrentUsage => 'Tu Uso Actual';

  @override
  String get unlimitedInvoices => 'Facturas Ilimitadas';

  @override
  String get unlimitedClients => 'Clientes Ilimitados';

  @override
  String get cloudSync => 'Sincronización en la nube';

  @override
  String get pdfExport => 'Exportación PDF';

  @override
  String get advancedReports => 'Reportes avanzados';

  @override
  String get prioritySupport => 'Soporte prioritario';

  @override
  String get allPlansInclude => 'Todos los planes incluyen:';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get subscriptionRenewalInfo =>
      'Las suscripciones se renuevan automáticamente a menos que se cancelen. Gestiona en la configuración de tu cuenta de la tienda.';

  @override
  String get unlockFullPotential => 'Desbloquea Todo el Potencial';

  @override
  String get reachedFreeInvoiceLimit =>
      'Has alcanzado el límite de facturas gratuitas. Actualiza para continuar facturando sin restricciones.';

  @override
  String get chooseYourPlan => 'Elige tu plan';

  @override
  String get upgradeNow => 'Actualizar Ahora';

  @override
  String get popular => 'POPULAR';

  @override
  String get save17Percent => 'Ahorra 17%';

  @override
  String get noInvoiceLimits => 'Sin límite de facturas';

  @override
  String get manageAllClients => 'Gestiona todos tus clientes';

  @override
  String get professionalFormat => 'Formato profesional';

  @override
  String get advancedReportsFeature => 'Reportes Avanzados';

  @override
  String get analyzeYourBusiness => 'Analiza tu negocio';

  @override
  String get subscriptionsRenewAutomatically =>
      'El pago se realizará en tu cuenta de Apple ID al confirmar la compra. Las suscripciones se renuevan automáticamente a menos que se cancelen al menos 24 horas antes de que finalice el período actual. Tu cuenta será cobrada por la renovación dentro de las 24 horas previas al fin del período actual. Administra o cancela tu suscripción en los Ajustes de tu cuenta de App Store.';

  @override
  String get planNotAvailableInStore =>
      'Este plan no está disponible actualmente en la tienda.';

  @override
  String get purchasesRestoredSuccessfully =>
      'Compras restauradas exitosamente';

  @override
  String errorRestoringPurchases(Object error) {
    return 'Error al restaurar compras: $error';
  }

  @override
  String get monthlyBilling => 'Facturación mensual';

  @override
  String get tryFree => 'Probar Gratis';

  @override
  String get creatingInvoice => 'Creando factura...';

  @override
  String get updatingInvoice => 'Actualizando factura...';

  @override
  String get goToDetailsTabToCreateInvoice =>
      'Vaya a la pestaña \"Detalles\" para crear la factura';

  @override
  String get goToDetails => 'Ir a Detalles';

  @override
  String get noItemsAdded => 'No hay artículos añadidos';

  @override
  String get clickPlusButtonToAddItems =>
      'Haga clic en el botón \"+\" para agregar ítems';

  @override
  String noClientsMatchingSearch(String query) {
    return 'No se encontraron clientes que coincidan con \"$query\"';
  }

  @override
  String get dismiss => 'Descartar';

  @override
  String get noClientsYet => 'No hay clientes todavía';

  @override
  String get addYourFirstClient => 'Añade tu primer cliente';

  @override
  String get noClientsFound => 'No se encontraron clientes';

  @override
  String get tryAnotherSearch => 'Intenta con otra búsqueda';

  @override
  String get date => 'Fecha';

  @override
  String get enterInvoiceNumber => 'Ingrese el número de factura';

  @override
  String get pleaseEnterInvoiceNumber =>
      'Por favor ingrese un número de factura';

  @override
  String get changeInvoicePrefix => 'Cambiar prefijo de factura';

  @override
  String get customInvoicePrefix => 'Prefijo personalizado';

  @override
  String get invoicePrefixHelper =>
      'Elige un prefijo rápido o escribe uno propio para generar el correlativo.';

  @override
  String get generateInvoiceNumber => 'Generar número automáticamente';

  @override
  String get invoiceNumberAutoGeneratedHelper =>
      'Se genera automáticamente, pero puedes editarlo manualmente.';

  @override
  String get enterPoNumber => 'Ingrese el número de orden';

  @override
  String get discountsAndTaxes => 'Descuentos e Impuestos';

  @override
  String get enterNotes => 'Ingrese notas adicionales';

  @override
  String get attachImage => 'Adjuntar Imagen';

  @override
  String get createInvoice => 'Crear Factura';

  @override
  String get updateInvoice => 'Actualizar Factura';

  @override
  String get discountType => 'Tipo de Descuento';

  @override
  String get percentage => 'Porcentaje';

  @override
  String get fixedAmount => 'Monto Fijo';

  @override
  String get taxType => 'Tipo de Impuesto';

  @override
  String get noImageSelected => 'No hay imagen seleccionada';

  @override
  String get newExpense => 'Nuevo Gasto';

  @override
  String get reviewData => 'Revisar Datos';

  @override
  String get rescanDocument => 'Reescanear Documento';

  @override
  String get scannedDocument => 'Documento Escaneado';

  @override
  String get reviewAndEditData => 'Revisa y edita los datos extraídos';

  @override
  String get basicInformation => 'Información Básica';

  @override
  String get vendorName => 'Nombre del Vendedor';

  @override
  String get noItemsDetected => 'No se detectaron productos';

  @override
  String get rate => 'Precio Unitario';

  @override
  String get amount => 'Monto';

  @override
  String get totals => 'Totales';

  @override
  String get invoiceCreatedSuccessfully => 'Factura creada exitosamente';

  @override
  String get subscriptionActivatedSuccessfully =>
      'Tu suscripción ha sido activada exitosamente. Ahora tienes acceso a todas las funciones premium.';

  @override
  String get nowYouCanEnjoy => 'Ahora puedes disfrutar de:';

  @override
  String get startCreatingInvoices =>
      'Comienza a crear facturas y gestionar tu negocio de manera profesional';

  @override
  String get redirectingAutomatically =>
      'Redirigiendo automáticamente en unos segundos...';

  @override
  String get subscription => 'Suscripción';

  @override
  String get account => 'Cuenta';

  @override
  String get businessInfo => 'Información de Empresa';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get preferences => 'Preferencias';

  @override
  String get languageAndRegion => 'Idioma y Región';

  @override
  String get theme => 'Tema';

  @override
  String get support => 'Soporte';

  @override
  String get contactSupport => 'Contactar Soporte';

  @override
  String get rateUs => 'Califícanos';

  @override
  String get shareApp => 'Compartir App';

  @override
  String get shareAppMessage =>
      'Mira Facturo, la mejor app de facturación! Descárgala aquí:';

  @override
  String get problemTitle => 'Título del problema';

  @override
  String get problemDescription => 'Descripción del problema';

  @override
  String get problemTitleHint => 'Ej: Error al crear factura';

  @override
  String get problemDescriptionHint =>
      'Describe detalladamente el problema que estás experimentando...';

  @override
  String get titleRequired => 'El título es requerido';

  @override
  String get titleMinLength => 'El título debe tener al menos 5 caracteres';

  @override
  String get descriptionRequired => 'Por favor ingrese una descripción';

  @override
  String get descriptionMinLength =>
      'La descripción debe tener al menos 20 caracteres';

  @override
  String get send => 'Enviar';

  @override
  String get supportRequestSent => 'Solicitud de soporte enviada correctamente';

  @override
  String get supportRequestError => 'Error al enviar la solicitud de soporte';

  @override
  String get rateAppTitle => 'Calificar Facturo';

  @override
  String get rateAppMessageIOS =>
      '¿Te gustaría calificar Facturo en la App Store?';

  @override
  String get rateAppMessageAndroid =>
      '¿Te gustaría calificar Facturo en Google Play Store?';

  @override
  String get rateAppCancel => 'Cancelar';

  @override
  String get rateAppRate => 'Calificar';

  @override
  String get purchaseLoadingTitle => 'Preparando tu compra';

  @override
  String get purchaseLoadingMessage =>
      'Espera un momento mientras conectamos con la tienda...';

  @override
  String get freePlan => 'PLAN GRATUITO';

  @override
  String get guestPlan => 'Invitado';

  @override
  String get proPlan => 'Plan Pro';

  @override
  String get getAccessToAllFeatures => 'Accede a todas las funciones';

  @override
  String get allFeaturesUnlocked => 'Todas las funciones desbloqueadas';

  @override
  String get ocrScannerTitle => 'Nueva Factura';

  @override
  String get ocrWelcomeTitle => 'Captura Inteligente';

  @override
  String get ocrWelcomeSubtitle =>
      'Toma una foto o selecciona una imagen de tu factura para procesarla automáticamente';

  @override
  String get ocrTakePhoto => 'Tomar Foto';

  @override
  String get ocrTakePhotoSubtitle => 'Usar cámara';

  @override
  String get ocrImportFile => 'Importar Archivo';

  @override
  String get ocrImportFileDescription => 'PDF o documento digital';

  @override
  String get ocrSelectImage => 'Seleccionar';

  @override
  String get ocrSelectImageSubtitle => 'De galería';

  @override
  String get ocrImageReady => '¡Perfecto! Tu imagen está lista';

  @override
  String get ocrImageReadySubtitle =>
      'Verifica que se vea bien y toca \"Procesar\" para continuar';

  @override
  String get ocrProcessInvoice => 'Procesar Factura';

  @override
  String get ocrChangeImage => 'Cambiar Imagen';

  @override
  String get ocrAnalyzing => '¡Analizando tu factura!';

  @override
  String get ocrAnalyzingSubtitle =>
      'Estamos extrayendo automáticamente\\ntodos los datos de tu factura';

  @override
  String get ocrTipsTitle => 'Consejos para mejores resultados';

  @override
  String get ocrTipsButton => 'Tips para escaneo perfecto';

  @override
  String get ocrTipLighting => 'Asegúrate de que la imagen esté bien iluminada';

  @override
  String get ocrTipStable => 'Mantén la cámara estable al tomar la foto';

  @override
  String get ocrTipFocus => 'Enfoca claramente el texto de la factura';

  @override
  String get ocrTipShadows => 'Evita sombras y reflejos en la imagen';

  @override
  String get ocrTip1 => 'Asegúrate de que la factura esté bien iluminada';

  @override
  String get ocrTip2 => 'Mantén la factura recta y desplegada';

  @override
  String get ocrTip3 => 'Incluye toda la factura en la imagen';

  @override
  String get ocrTip4 => 'Evita sombras y reflejos';

  @override
  String get ocrTip5 => 'Mantén la cámara estable al tomar la foto';

  @override
  String get ocrTip6 => 'Mejor calidad = Mejor reconocimiento';

  @override
  String get ocrUnderstood => 'Entendido';

  @override
  String get ocrImageDarkWarning =>
      'La imagen parece muy oscura. Intenta con mejor iluminación.';

  @override
  String get ocrImageBlurryWarning =>
      'La imagen podría estar borrosa. Intenta tomar otra foto.';

  @override
  String get ocrCameraTooltip =>
      'Asegúrate de que la factura esté bien iluminada y sin sombras';

  @override
  String get ocrGalleryTooltip =>
      'Selecciona una imagen clara y nítida de tu factura';

  @override
  String get ocrErrorSelectingImage => 'Error al seleccionar imagen';

  @override
  String get ocrErrorProcessingImage => 'Error al procesar imagen';

  @override
  String waitBeforeRefresh(int seconds) {
    return 'Espera $seconds segundos antes de actualizar nuevamente';
  }

  @override
  String get updating => 'Actualizando...';

  @override
  String get update => 'Actualizar';

  @override
  String get paidInvoices => 'Facturas Pagadas';

  @override
  String get pendingInvoices => 'Facturas Pendientes';

  @override
  String get yourBusiness => 'Tu Negocio';

  @override
  String get responsiveDesign => 'Diseño Responsive';

  @override
  String get testResponsiveDesign => 'Prueba el diseño responsive';

  @override
  String get howAppAdapts =>
      'Ve cómo se adapta la aplicación a diferentes tamaños de pantalla';

  @override
  String get viewResponsiveExample => 'Ver Ejemplo Responsive';

  @override
  String get noDataToShow => 'No hay datos para mostrar';

  @override
  String get addInvoicesOrExpenses =>
      'Agrega facturas pagadas o gastos\\npara ver el gráfico';

  @override
  String get summary => 'Resumen';

  @override
  String get digitalSignatureScreen => 'Firma Digital';

  @override
  String get signHere => 'Firma aquí';

  @override
  String get saveSignature => 'Guardar firma';

  @override
  String get signatureCleared => 'Firma borrada';

  @override
  String get signatureSaved => 'Firma guardada exitosamente';

  @override
  String get pleaseSignFirst => 'Por favor agrega tu firma primero';

  @override
  String get signatureInstructions =>
      'Usa tu dedo o stylus para crear tu firma digital en el área de abajo';

  @override
  String get signatureOptional => 'Firma (Opcional)';

  @override
  String get addYourSignature => 'Agrega tu firma';

  @override
  String get signatureAdded => 'Firma agregada exitosamente';

  @override
  String get extractedData => 'Información Extraída';

  @override
  String get actions => 'Acciones';

  @override
  String get export => 'Exportar';

  @override
  String get manageYourBusiness => 'Gestiona tu negocio\nde manera inteligente';

  @override
  String get businessDescription =>
      'Crea facturas, gestiona gastos y mantén\norganizado tu negocio desde cualquier lugar';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get onboardingWhatBusinessType => '¿Qué tipo de negocio tienes?';

  @override
  String get onboardingSelectBusinessType =>
      'Selecciona el tipo que mejor describa tu negocio para personalizar tu experiencia.';

  @override
  String get onboardingCreateAccount => 'Crea tu cuenta';

  @override
  String get onboardingConfigureProfile =>
      'Configura tu perfil personal para acceder a todas las funciones de la aplicación.';

  @override
  String get onboardingBusinessInfo => 'Información de tu negocio';

  @override
  String get onboardingTellUsAboutBusiness =>
      'Cuéntanos sobre tu negocio para personalizar tu experiencia';

  @override
  String get onboardingBusinessCategory => '¿A qué se dedica tu negocio?';

  @override
  String get onboardingSelectCategory =>
      'Selecciona la categoría que mejor describe tu actividad';

  @override
  String get onboardingStep2Of4 => 'Paso 2 de 4';

  @override
  String get onboardingStep3Of4 => 'Paso 3 de 4';

  @override
  String get onboardingStep4Of4 => 'Paso 4 de 4';

  @override
  String get onboardingUploadLogo => 'Subir logo';

  @override
  String get onboardingChangeLogo => 'Cambiar logo';

  @override
  String get onboardingBusinessName => 'Nombre del negocio';

  @override
  String get onboardingBusinessNameHint => 'Ej: Mi Tienda';

  @override
  String get onboardingBusinessNameRequired =>
      'Por favor ingresa el nombre de tu negocio';

  @override
  String get onboardingBusinessInfoSubtitle =>
      'Cuéntanos sobre tu negocio para personalizar tu experiencia';

  @override
  String get onboardingLogoRemoved => 'Logo removido';

  @override
  String get onboardingBusinessPhone => 'Teléfono del Negocio';

  @override
  String get onboardingBusinessPhoneHint => 'Ej: +506 8888-8888';

  @override
  String get onboardingBusinessPhoneInvalid =>
      'Ingrese un número de teléfono válido';

  @override
  String get onboardingBusinessAddress => 'Dirección del Negocio';

  @override
  String get onboardingBusinessAddressHint => 'Dirección';

  @override
  String get onboardingAddPhoto => 'Agregar foto';

  @override
  String get onboardingSearchCategory => 'Buscar categoría...';

  @override
  String get onboardingAlmostDone => '¡Casi terminamos!';

  @override
  String get onboardingReviewInfo =>
      'Revisa la información que has configurado antes de crear tu cuenta.';

  @override
  String get onboardingBusinessType => 'Tipo de Negocio';

  @override
  String get onboardingTypeSelected => 'Tipo seleccionado';

  @override
  String get onboardingNotSelected => 'No seleccionado';

  @override
  String get onboardingAccountInfo => 'Información de Cuenta';

  @override
  String get onboardingFullName => 'Nombre completo';

  @override
  String get onboardingNotSpecified => 'No especificado';

  @override
  String get onboardingEmail => 'Correo electrónico';

  @override
  String get onboardingPassword => 'Contraseña';

  @override
  String get onboardingNotSpecifiedPassword => 'No especificada';

  @override
  String get onboardingNextSteps => 'Próximos Pasos';

  @override
  String get onboardingInitialPlan => 'Plan inicial';

  @override
  String get onboardingFreePlan => 'Plan Gratuito (5 facturas)';

  @override
  String get onboardingAdditionalConfig => 'Configuración adicional';

  @override
  String get onboardingAvailableFromProfile => 'Disponible desde tu perfil';

  @override
  String get businessTypeRetail => 'Tienda/Retail';

  @override
  String get businessTypeRetailDesc => 'Venta de productos físicos';

  @override
  String get businessTypeServices => 'Servicios';

  @override
  String get businessTypeServicesDesc => 'Consultoría, reparaciones, etc.';

  @override
  String get businessTypeRestaurant => 'Restaurante/Bar';

  @override
  String get businessTypeRestaurantDesc => 'Comida y bebidas';

  @override
  String get businessTypeFreelance => 'Freelance';

  @override
  String get businessTypeFreelanceDesc => 'Trabajo independiente';

  @override
  String get businessTypeEcommerce => 'E-commerce';

  @override
  String get businessTypeEcommerceDesc => 'Venta online';

  @override
  String get businessTypeOther => 'Otro';

  @override
  String get businessTypeOtherDesc => 'Tipo personalizado';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String onboardingStep(Object step, Object total) {
    return 'Paso $step de $total';
  }

  @override
  String get onboardingWhatKindOfBusiness => '¿Qué tipo de negocio tienes?';

  @override
  String get onboardingSetupProfile => 'Configura tu perfil para comenzar';

  @override
  String get onboardingWhatDoesBusinessDo => '¿A qué se dedica tu negocio?';

  @override
  String get onboardingBusinessTypeRetail => 'Tienda/Retail';

  @override
  String get onboardingBusinessTypeServices => 'Servicios';

  @override
  String get onboardingBusinessTypeRestaurant => 'Restaurante/Bar';

  @override
  String get onboardingBusinessTypeFreelance => 'Freelance';

  @override
  String get onboardingBusinessTypeEcommerce => 'E-commerce';

  @override
  String get onboardingBusinessTypeOther => 'Otro';

  @override
  String get onboardingBusinessTypeRetailDesc => 'Venta de productos físicos';

  @override
  String get onboardingBusinessTypeServicesDesc => 'Prestación de servicios';

  @override
  String get onboardingBusinessTypeRestaurantDesc => 'Comida y bebidas';

  @override
  String get onboardingBusinessTypeFreelanceDesc => 'Trabajo independiente';

  @override
  String get onboardingBusinessTypeEcommerceDesc => 'Venta en línea';

  @override
  String get onboardingBusinessTypeOtherDesc => 'Otro tipo de negocio';

  @override
  String get businessCategoryRetail => 'Comercio Minorista';

  @override
  String get businessCategoryRetailDesc =>
      'Venta de productos físicos y retail';

  @override
  String get businessCategoryFoodBeverage => 'Alimentos y Bebidas';

  @override
  String get businessCategoryFoodBeverageDesc =>
      'Restaurantes, cafeterías, bares y servicios de catering';

  @override
  String get businessCategoryProfessionalServices => 'Servicios Profesionales';

  @override
  String get businessCategoryProfessionalServicesDesc =>
      'Consultoría, legal, contabilidad y servicios empresariales';

  @override
  String get businessCategoryHealthBeauty => 'Salud y Belleza';

  @override
  String get businessCategoryHealthBeautyDesc =>
      'Salones, spas, gimnasios y servicios de bienestar';

  @override
  String get businessCategoryConstruction => 'Construcción y Contratistas';

  @override
  String get businessCategoryConstructionDesc =>
      'Servicios de construcción, remodelación y mantenimiento';

  @override
  String get businessCategoryAutomotive => 'Automotriz';

  @override
  String get businessCategoryAutomotiveDesc =>
      'Talleres, venta de repuestos y servicios automotrices';

  @override
  String get businessCategoryTechnology => 'Tecnología';

  @override
  String get businessCategoryTechnologyDesc =>
      'Servicios informáticos, desarrollo de software y reparaciones';

  @override
  String get businessCategoryEducation => 'Educación y Capacitación';

  @override
  String get businessCategoryEducationDesc =>
      'Escuelas, academias y centros de formación';

  @override
  String get businessCategoryRealEstate => 'Bienes Raíces';

  @override
  String get businessCategoryRealEstateDesc =>
      'Venta, alquiler y administración de propiedades';

  @override
  String get businessCategoryManufacturing => 'Manufactura';

  @override
  String get businessCategoryManufacturingDesc =>
      'Producción y fabricación de productos';

  @override
  String get businessCategoryAgriculture => 'Agricultura y Ganadería';

  @override
  String get businessCategoryAgricultureDesc =>
      'Producción agrícola, ganadera y servicios relacionados';

  @override
  String get businessCategoryTransportation => 'Transporte y Logística';

  @override
  String get businessCategoryTransportationDesc =>
      'Servicios de transporte, envíos y almacenamiento';

  @override
  String get businessCategoryEntertainment => 'Entretenimiento y Eventos';

  @override
  String get businessCategoryEntertainmentDesc =>
      'Organización de eventos, entretenimiento y recreación';

  @override
  String get businessCategoryWholesale => 'Comercio Mayorista';

  @override
  String get businessCategoryWholesaleDesc =>
      'Distribución y venta al por mayor';

  @override
  String get businessCategoryCreative => 'Servicios Creativos';

  @override
  String get shareBusinessProfile => 'Compartir negocio';

  @override
  String get warningOcrDataNotLoaded =>
      'Advertencia: Algunos datos OCR no pudieron cargarse';

  @override
  String get errorExportingImage => 'Error al exportar imagen';

  @override
  String get exportAsJpg => 'Exportar como JPG';

  @override
  String get exportAsCsv => 'Exportar como CSV';

  @override
  String get downloadCsvFile => 'Descargar archivo CSV';

  @override
  String get regPromptFirstInvoiceTitle => '¡Primera factura creada!';

  @override
  String get regPromptFirstInvoiceSubtitle =>
      '¡Excelente trabajo! Creaste tu primera factura. ¿No crees que es hora de guardarla?';

  @override
  String get regPromptFirstInvoiceBenefit1 => 'No pierdas tus facturas';

  @override
  String get regPromptFirstInvoiceBenefit2 =>
      'Accede desde cualquier dispositivo';

  @override
  String get regPromptFirstInvoiceBenefit3 => 'Mejora tu organización';

  @override
  String get regPromptFirstInvoiceCta => 'Guardar mi factura';

  @override
  String get regPromptFirstInvoiceDismiss => 'Seguir probando';

  @override
  String get regPromptTimeTitle => '¡Qué gusto tenerte aquí!';

  @override
  String get regPromptTimeSubtitle =>
      'Vemos que le estás sacando provecho a la app. Crea tu cuenta gratis para respaldar tu información y acceder a más beneficios.';

  @override
  String get regPromptTimeCta => 'Crear mi cuenta';

  @override
  String get regPromptTimeDismiss => 'Más tarde';

  @override
  String get activePlan => 'Plan Activo';

  @override
  String get close => 'Cerrar';

  @override
  String get manageInAppStore => 'Gestionar en App Store';

  @override
  String errorRestoringPurchasesWithMessage(Object error) {
    return 'Error al restaurar compras: $error';
  }

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get createPermanentAccount => 'Crear cuenta permanente';

  @override
  String get deleteDataAndLogout => 'Eliminar datos y cerrar sesión';

  @override
  String get profileCompletedSuccessfully => '¡Perfil completado exitosamente!';

  @override
  String get accountConnectedWithGoogleActivating =>
      '¡Cuenta conectada con Google! Activando suscripción...';

  @override
  String get accountConnectedWithGoogleSuccess =>
      '¡Cuenta conectada con Google exitosamente!';

  @override
  String get accountConnectedWithAppleActivating =>
      '¡Cuenta conectada con Apple! Activando suscripción...';

  @override
  String get accountConnectedWithAppleSuccess =>
      '¡Cuenta conectada con Apple exitosamente!';

  @override
  String errorActivatingSubscription(Object error) {
    return 'Error al activar suscripción: $error';
  }

  @override
  String get howDoYouWantToShare => '¿Cómo quieres compartir?';

  @override
  String get textMessage => 'Mensaje de texto';

  @override
  String get textMessageDescription => 'Enviar por WhatsApp, SMS o email';

  @override
  String get contactFile => 'Archivo de contacto';

  @override
  String get contactFileDescription => 'Para que otros te guarden en su agenda';

  @override
  String get errorSharingProfile => 'Error al compartir';

  @override
  String get completeProfile => 'Completar perfil';

  @override
  String get completeYourProfileTitle => '¡Completa tu perfil!';

  @override
  String get completeYourProfileTooltipBody =>
      'Agrega tu información personal y de empresa para que tus facturas y documentos se vean más profesionales.';

  @override
  String get completeYourProfileTooltipCta => 'Toca aquí para comenzar →';

  @override
  String profileCompletionStatus(int percentage) {
    return 'Perfil $percentage% completado';
  }

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar Cuenta';

  @override
  String get deleteAccountWarning =>
      '¿Estás seguro de que quieres eliminar tu cuenta?';

  @override
  String get deleteAccountDescription =>
      'Esta acción es permanente y no se puede deshacer. Todos tus datos serán eliminados permanentemente:';

  @override
  String get deleteAccountDataList =>
      '• Todas las facturas y cotizaciones\n• Todos los clientes y gastos\n• Información del negocio\n• Todas las configuraciones y preferencias';

  @override
  String get deleteAccountSubscriptionWarning =>
      '⚠️ No puedes eliminar tu cuenta mientras tengas una suscripción activa.\n\nPrimero debes cancelar tu suscripción en:\nConfiguraciones > Apple ID > Suscripciones > Facturo\n\nUna vez cancelada, podrás eliminar tu cuenta.';

  @override
  String get deleteAccountConfirmation => 'Escribe ELIMINAR para confirmar';

  @override
  String get deleteAccountConfirmationHint => 'Escribe ELIMINAR';

  @override
  String get deleteAccountButton => 'Eliminar Mi Cuenta';

  @override
  String get accountDeletedSuccessfully =>
      'Tu cuenta ha sido eliminada exitosamente';

  @override
  String errorDeletingAccount(Object error) {
    return 'Error al eliminar cuenta: $error';
  }

  @override
  String get confirmationTextDoesNotMatch =>
      'El texto de confirmación no coincide';

  @override
  String get warning => 'Advertencia';

  @override
  String get guestUserWarning =>
      'Estás usando una cuenta de invitado. Si cierras sesión, perderás todos tus datos.';

  @override
  String get onboardingPage1Title => 'Factura Fácil y Rápido';

  @override
  String get onboardingPage1Subtitle => 'Crea facturas profesionales';

  @override
  String get onboardingPage1Description =>
      'Genera facturas personalizadas en segundos. Envía a tus clientes al instante y lleva un control total de tus finanzas.';

  @override
  String get onboardingPage2Title => 'Control de Gastos Inteligente';

  @override
  String get onboardingPage2Subtitle => 'Escanea y organiza';

  @override
  String get onboardingPage2Description =>
      'Escanea tus recibos con nuestra tecnología de escaneo inteligente. Digitaliza y organiza tus gastos automáticamente sin esfuerzo manual.';

  @override
  String get onboardingPage3Title => 'Impulsa tu Negocio';

  @override
  String get onboardingPage3Subtitle => 'Visualiza tu crecimiento';

  @override
  String get onboardingPage3Description =>
      'Gestiona tus clientes y visualiza el crecimiento de tu negocio con reportes detallados y estadísticas en tiempo real.';

  @override
  String get onboardingPage4Title => 'Comienza Gratis';

  @override
  String get onboardingPage4Subtitle => 'Plan gratuito incluido';

  @override
  String get onboardingPage4Description =>
      'Disfruta de todas las funciones básicas sin costo. Actualiza cuando quieras para desbloquear todo el potencial.';

  @override
  String get continueForFree => 'Continuar Gratis';

  @override
  String get skip => 'Omitir';

  @override
  String get appName => 'Facturo';

  @override
  String get enablePushNotifications => 'Activar Notificaciones Push';

  @override
  String get enablePushNotificationsDescription =>
      'Recibe notificaciones cuando la app está cerrada';

  @override
  String get pushNotificationsEnabledSuccessfully =>
      '¡Notificaciones push activadas exitosamente!';

  @override
  String get permissionDeniedEnableInSettings =>
      'Permiso denegado. Por favor activa las notificaciones en Configuración.';

  @override
  String get pushNotificationsNotAvailable =>
      'Las notificaciones push no están disponibles aún. Se requiere configuración de Firebase.';

  @override
  String get enableWeeklyDigest => 'Activar Resumen Semanal';

  @override
  String get enableWeeklyDigestDescription =>
      'Recibe un resumen de tu actividad cada semana';

  @override
  String get weeklyDigestConfiguration => 'Configuración de Resumen Semanal';

  @override
  String get whenWouldYouLikeToReceiveSummary =>
      '¿Cuándo te gustaría recibir tu resumen?';

  @override
  String get dayOfWeek => 'Día de la semana';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get copyLinkDescription => 'Copiar enlace seguro al portapapeles';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get shareLinkDescription =>
      'Compartir enlace en línea a través de aplicaciones';

  @override
  String get generateNewLink => 'Generar nuevo enlace';

  @override
  String get generateNewLinkDescription => 'Crear un enlace nuevo';

  @override
  String get allNotificationsAlreadyRead =>
      'Todas las notificaciones ya están leídas';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get selectImageDescription => 'Elige de tu galería';

  @override
  String get newReport => 'Nuevo Reporte';

  @override
  String get pushNotificationsDisabled => 'Notificaciones push desactivadas';

  @override
  String get unknownCategory => 'Categoría desconocida';

  @override
  String get notificationsPush => 'Notificaciones Push';

  @override
  String get notificationsPushDescription =>
      'Recibe alertas fuera de la aplicación';

  @override
  String get weeklySummary => 'Resumen Semanal';

  @override
  String get weeklySummaryDescription =>
      'Estadísticas y resumen de actividad semanal';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get education => 'Educación';

  @override
  String get professionalServices => 'Servicios Profesionales';

  @override
  String get services => 'Servicios';

  @override
  String get restaurant => 'Restaurante';

  @override
  String get construction => 'Construcción';

  @override
  String get technology => 'Tecnología';

  @override
  String get health => 'Salud';

  @override
  String get retail => 'Retail';

  @override
  String get retailStore => 'Comercio Minorista';

  @override
  String get foodAndBeverage => 'Alimentos y Bebidas';

  @override
  String get fileFormat => 'Formato de archivo';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get invoicesProcessed => 'Facturas Procesadas';

  @override
  String get type => 'Tipo';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get reportId => 'ID del Reporte';

  @override
  String get ocrItem => 'Ítem OCR';

  @override
  String get status => 'Estado';

  @override
  String get other => 'Otro';

  @override
  String get goToDashboard => 'Ir al Panel';

  @override
  String get createNewAccount => 'Crear cuenta nueva';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get discountOff => 'de descuento';

  @override
  String get totalLabel => 'TOTAL';

  @override
  String get taxLabel => 'IMPUESTO';

  @override
  String get discountLabel => 'DESCUENTO';

  @override
  String get fixed => 'Fijo';

  @override
  String get insufficientInfoToShare =>
      'No hay información suficiente para compartir';

  @override
  String get failedToCreateContactFile =>
      'No se pudo crear el archivo de contacto. Compartiendo como texto...';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get failedToSaveCategory => 'Error al guardar categoría';

  @override
  String get deleteReceipt => 'Eliminar recibo';

  @override
  String get deleteReceiptConfirmation =>
      '¿Estás seguro de que quieres eliminar esta factura?';

  @override
  String get createInvoiceFromScan => 'Crear factura desde escaneo';

  @override
  String get initializationErrorTitle => 'Error Crítico de Inicialización';

  @override
  String get initializationErrorHelp =>
      'Por favor, verifica tu configuración (archivo .env) y la conexión a internet. Luego, reinicia la aplicación.';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get accept => 'Aceptar';

  @override
  String get done => 'Listo';

  @override
  String get cropProfilePhoto => 'Recortar foto de perfil';

  @override
  String get cropBusinessLogo => 'Recortar logo de empresa';

  @override
  String get cropDocument => 'Recortar documento';

  @override
  String get saveScannedReceiptOnly => 'Guardar solo recibo escaneado';

  @override
  String get saveScannedReceipt => 'Guardar Recibo Escaneado';

  @override
  String get chooseHowToSave => 'Elige cómo deseas guardar este recibo';

  @override
  String get saveAsExpense => 'Guardar como Gasto';

  @override
  String get saveAsInvoice => 'Guardar como Factura';

  @override
  String get saveReceiptOnlyDescription =>
      'Solo guardar el recibo sin crear gasto o factura';

  @override
  String get rescan => 'Reescanear';

  @override
  String get editItem => 'Editar ítem';

  @override
  String get sendEstimate => 'Enviar Cotización';

  @override
  String get resetView => 'Restablecer Vista';

  @override
  String deleteCategoryConfirmation(Object categoryName) {
    return '¿Estás seguro de que quieres eliminar la categoría \"$categoryName\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'Esta acción no se puede deshacer y puede afectar los gastos existentes.';

  @override
  String get itemsLabel => 'Ítems';

  @override
  String get estimateLabel => 'COTIZACIÓN';

  @override
  String get billToLabel => 'FACTURAR A';

  @override
  String get dateLabel => 'FECHA';

  @override
  String get validUntilLabel => 'VÁLIDO HASTA';

  @override
  String get descriptionLabel => 'Descripción *';

  @override
  String get rateLabel => 'TARIFA';

  @override
  String get qtyLabel => 'CANT';

  @override
  String get amountLabel => 'MONTO';

  @override
  String get subtotalLabel => 'SUBTOTAL';

  @override
  String get notAvailableLabel => 'N/A';

  @override
  String get yourBusinessNameLabel => 'Nombre de tu empresa';

  @override
  String get businessAddressLabel => 'Dirección de la empresa';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get applicable => 'Aplicable';

  @override
  String get descriptionHint => 'Ingrese la descripción';

  @override
  String get unitPriceLabel => 'Precio Unitario';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get additionalDetailsLabel => 'Detalles Adicionales';

  @override
  String get additionalDetailsHint => 'Ingrese cualquier detalle adicional';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get estimateInformation => 'Información de Cotización';

  @override
  String get estimateNumberRequired => 'Número de Cotización *';

  @override
  String get enterEstimateNumber => 'Ingrese el número de cotización';

  @override
  String get pleaseEnterEstimateNumber =>
      'Por favor ingrese un número de cotización';

  @override
  String get estimateDateRequired => 'Fecha de Cotización *';

  @override
  String get selectEstimateDate => 'Seleccionar fecha de cotización';

  @override
  String get validUntilRequired => 'Válido Hasta *';

  @override
  String get selectExpiryDate => 'Seleccionar fecha de vencimiento';

  @override
  String get poNumberOptional => 'Número de Orden';

  @override
  String get enterPoNumberOptional => 'Ingrese el número de orden (opcional)';

  @override
  String get clientRequired => 'Cliente *';

  @override
  String get pleaseSelectClient => 'Por favor seleccione un cliente';

  @override
  String get additionalInformation => 'Información Adicional';

  @override
  String get additionalNotesOptional => 'Notas adicionales (opcional)';

  @override
  String get estimateItems => 'Ítems de Cotización';

  @override
  String get createEstimate => 'Crear Cotización';

  @override
  String get updateEstimate => 'Actualizar Cotización';

  @override
  String get clientNoLongerAvailable =>
      'El cliente seleccionado ya no está disponible';

  @override
  String get pdfStyle => 'Estilo PDF';

  @override
  String get choosePdfStyle => 'Elegir Estilo PDF';

  @override
  String get exportOptions => 'Opciones de Exportación';

  @override
  String get sendViaEmail => 'Enviar por Email';

  @override
  String get sendPdfViaEmail => 'Enviar PDF por email';

  @override
  String get sendViaTextMessage => 'Enviar por Mensaje de Texto';

  @override
  String get sendPdfViaTextMessage => 'Enviar PDF por mensaje de texto';

  @override
  String get sendViaLink => 'Enviar por Link';

  @override
  String get ready => 'Listo';

  @override
  String get linkReadyTapToShare => 'Enlace listo - toca para compartir';

  @override
  String get generateAndShareOnlineLink =>
      'Generar y compartir enlace en línea';

  @override
  String get exportAsPdf => 'Exportar como PDF';

  @override
  String get downloadPdfFile => 'Descargar archivo PDF';

  @override
  String get exportAsImage => 'Exportar como Imagen';

  @override
  String get downloadAsPngImage => 'Descargar como imagen PNG';

  @override
  String get generatingPngImage => 'Generando imagen PNG...';

  @override
  String get noExpensesFound => 'No se encontraron gastos';

  @override
  String get noExpensesMatchSearchCriteria =>
      'No hay gastos que coincidan con tu criterio de búsqueda';

  @override
  String get addFirstExpenseToGetStarted =>
      'Agrega tu primer gasto para comenzar';

  @override
  String get noSearchResults => 'Sin resultados de búsqueda';

  @override
  String noExpensesForYear(String year) {
    return 'Sin gastos para $year';
  }

  @override
  String get tryDifferentSearchTerm =>
      'Prueba con un término de búsqueda diferente';

  @override
  String get tryDifferentYearOrAddExpense =>
      'Prueba seleccionar un año diferente o agrega un nuevo gasto';

  @override
  String get unknown => 'Desconocido';

  @override
  String areYouSureDeleteExpense(String merchant) {
    return '¿Estás seguro de que quieres eliminar el gasto de $merchant?';
  }

  @override
  String get selectYear => 'Seleccionar Año';

  @override
  String get dateRequired => 'Fecha *';

  @override
  String get merchant => 'Comerciante';

  @override
  String get merchantRequired => 'Comerciante *';

  @override
  String get enterMerchantName => 'Ingresa el nombre del comerciante';

  @override
  String get pleaseEnterMerchantName =>
      'Por favor ingresa un nombre de comerciante';

  @override
  String get category => 'Categoría';

  @override
  String get categoryRequired => 'Categoría *';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get financialInformation => 'Información Financiera';

  @override
  String get totalAmountRequired => 'Monto Total *';

  @override
  String get enterTotalAmount => 'Ingresa el monto total';

  @override
  String get pleaseEnterTotalAmount => 'Por favor ingresa el monto total';

  @override
  String get amountMustBeGreaterThanZero => 'El monto debe ser mayor a cero';

  @override
  String get pleaseEnterValidAmount => 'Por favor ingresa un monto válido';

  @override
  String get taxAmount => 'Monto de Impuesto';

  @override
  String get taxAmountOptional => 'Monto de Impuesto (Opcional)';

  @override
  String get enterTaxAmount => 'Ingresa el monto del impuesto';

  @override
  String get pleaseEnterTotalAmountFirst =>
      'Por favor ingresa el monto total primero';

  @override
  String get taxCannotBeNegative => 'El impuesto no puede ser negativo';

  @override
  String get taxCannotBeGreaterThanTotal =>
      'El impuesto no puede ser mayor al total';

  @override
  String get descriptionOptional => 'Descripción (Opcional)';

  @override
  String get enterDescription => 'Ingresa la descripción';

  @override
  String get receiptImage => 'Imagen del Recibo';

  @override
  String get addReceiptImage => 'Agregar Imagen del Recibo';

  @override
  String get noReceiptImage => 'Sin imagen de recibo';

  @override
  String get language => 'Idioma';

  @override
  String get selectYourPreferredLanguage =>
      'Selecciona tu idioma preferido para la aplicación';

  @override
  String get dateFormat => 'Formato de Fecha';

  @override
  String get chooseHowDatesShouldBeDisplayed =>
      'Elige cómo se deben mostrar las fechas';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get selectDateFormat => 'Seleccionar Formato de Fecha';

  @override
  String get selectDay => 'Seleccionar día';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get taxRateLabel => 'Tasa (%)';

  @override
  String get required => 'Requerido';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get loginWelcome => '¡Bienvenido de nuevo!';

  @override
  String get socialLoginGoogle => 'Continuar con Google';

  @override
  String get socialLoginApple => 'Continuar con Apple';

  @override
  String renewingInDays(int days) {
    return 'Renovando en $days días';
  }

  @override
  String get autoRenewalActive => 'Renovación automática activa';

  @override
  String get manageSubscriptionHelp =>
      'Para gestionar tu suscripción, ve a la configuración de tu cuenta en la tienda de aplicaciones.';

  @override
  String get currentPlanLabel => 'Plan Actual';

  @override
  String changePlanInstruction(String planName) {
    return 'Para cambiar a $planName, cancela tu plan actual y suscríbete al nuevo plan desde la tienda.';
  }

  @override
  String get managingKeychain => 'Gestionando llavero...';

  @override
  String get alreadyHaveAccountAction => 'Iniciar Sesión';

  @override
  String get noCategoriesTitle => 'No hay categorías';

  @override
  String get addFirstCategoryMessage => 'Añade tu primera categoría de gastos';

  @override
  String get noAnonymousUserToConvert =>
      'No hay usuario anónimo para convertir';

  @override
  String get noAnonymousUserToLink => 'No hay usuario anónimo para enlazar';

  @override
  String get pleaseEnterFullName => 'Por favor ingresa tu nombre completo';

  @override
  String get pleaseEnterEmail => 'Por favor ingresa tu email';

  @override
  String get pleaseEnterValidEmailAddress =>
      'Por favor ingresa un email válido';

  @override
  String get pleaseEnterBusinessName =>
      'Por favor ingresa el nombre de tu negocio';

  @override
  String get pleaseEnterPhone => 'Por favor ingresa un teléfono';

  @override
  String get pleaseEnterAddress => 'Por favor ingresa una dirección';

  @override
  String get selectHowToCapture => 'Selecciona cómo quieres capturar';

  @override
  String get selectHowToCaptureInvoice =>
      'Selecciona cómo quieres capturar la factura';

  @override
  String get selectImageFromGallery => 'Seleccionar Imagen';

  @override
  String get chooseFromGalleryDescription => 'Elige de tu galería';

  @override
  String get noNotifications => 'No hay notificaciones';

  @override
  String get noNotificationsMessage =>
      'Cuando tengas notificaciones, aparecerán aquí';

  @override
  String get markAllAsRead => 'Marcar todas como leídas';

  @override
  String get clearAllNotifications => 'Eliminar todas las notificaciones';

  @override
  String get clearAllNotificationsConfirmation =>
      '¿Estás seguro de que quieres eliminar todas las notificaciones? Esta acción no se puede deshacer.';

  @override
  String get notificationDeleted => 'Notificación eliminada';

  @override
  String get allNotificationsCleared =>
      'Todas las notificaciones han sido eliminadas';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get errorInMyApp => 'Error en la aplicación';

  @override
  String get envMissingError =>
      'SUPABASE_URL y SUPABASE_ANON_KEY deben estar definidos en tu archivo .env';

  @override
  String get businessNameRequired => 'El nombre del negocio es requerido';

  @override
  String get fullNameRequired => 'El nombre es requerido';

  @override
  String get emailRequired => 'El correo es requerido';

  @override
  String get invalidEmail => 'Ingresa un correo válido';

  @override
  String get sendPdfFile => 'Enviar Archivo PDF';

  @override
  String get downloadAndSharePdf => 'Descargar y compartir PDF';

  @override
  String get exportAsPng => 'Exportar como PNG';

  @override
  String get downloadAsImage => 'Descargar como imagen';

  @override
  String get deleteOnlineLink => 'Eliminar Link Online';

  @override
  String get removeSharedLink => 'Eliminar link compartido';

  @override
  String get sharePngFile => 'Compartir archivo PNG';

  @override
  String get shareViaOtherApps => 'Compartir vía otras apps';

  @override
  String get saveToDevice => 'Guardar en dispositivo';

  @override
  String get downloadToLocalStorage => 'Descargar a almacenamiento local';

  @override
  String get deleteOnlineLinkConfirmation =>
      '¿Estás seguro de que quieres eliminar el enlace online? Esta acción no se puede deshacer.';

  @override
  String get copySecureLinkToClipboard =>
      'Copiar enlace seguro al portapapeles';

  @override
  String get shareOnlineLinkViaApps => 'Compartir enlace online vía otras apps';

  @override
  String get createFreshLink => 'Crear un enlace nuevo';

  @override
  String get sharePdfFile => 'Compartir archivo PDF';

  @override
  String get couldNotAccessDownloads =>
      'No se pudo acceder al directorio de Descargas';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get linkShared => 'Enlace compartido';

  @override
  String get pdfSaved => 'PDF guardado';

  @override
  String get pngSaved => 'PNG guardado';

  @override
  String get linkDeleted => 'Enlace eliminado';

  @override
  String get linkGenerated => 'Enlace generado';

  @override
  String get deleteItem => 'Eliminar Item';

  @override
  String get deleteItemConfirmation =>
      '¿Estás seguro de que quieres eliminar este item?';

  @override
  String get taxable => 'Gravable';

  @override
  String get signatureSavedSuccessfully => 'Firma guardada exitosamente';

  @override
  String get noSignatureAvailable => 'No hay firma disponible';

  @override
  String get pleaseSelectBusinessType =>
      'Por favor selecciona un tipo de negocio';

  @override
  String get errorLoadingCategories => 'Error al cargar categorías';

  @override
  String get noCategoriesAvailable => 'No hay categorías disponibles';

  @override
  String get categoryDeletedSuccessfully => 'Categoría eliminada exitosamente';

  @override
  String get categoryUpdatedSuccessfully =>
      'Categoría actualizada exitosamente';

  @override
  String get mustAcceptTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get noClientsAvailable => 'No hay clientes disponibles';

  @override
  String get selectAClient => 'Seleccionar un cliente';

  @override
  String get noItemsFound => 'No se encontraron ítems';

  @override
  String get receiptUpdatedSuccessfully => 'Recibo actualizado exitosamente';

  @override
  String get receiptDeletedSuccessfully => 'Recibo eliminado exitosamente';

  @override
  String get receiptSavedSuccessfully => 'Recibo guardado exitosamente';

  @override
  String get duplicateReceiptTitle => 'Posible Duplicado';

  @override
  String get duplicateReceiptMessage =>
      'Un recibo similar ya fue guardado en las últimas 24 horas. ¿Deseas guardarlo de todos modos?';

  @override
  String get saveAnyway => 'Guardar de Todos Modos';

  @override
  String get settingsSavedSuccessfully => 'Configuración guardada exitosamente';

  @override
  String get errorUpdating => 'Error al actualizar';

  @override
  String get errorClearingImage => 'Error al limpiar imagen';

  @override
  String get errorSelectingImage => 'Error al seleccionar imagen';

  @override
  String get errorClearingLogo => 'Error al limpiar logo';

  @override
  String get errorSaving => 'Error al guardar';

  @override
  String get errorSavingSignature => 'Error al guardar firma';

  @override
  String get serviceNotAvailable => 'Servicio no disponible';

  @override
  String get loadingCategories => 'Cargando categorías...';

  @override
  String get errorLoadingExpense => 'Error al cargar gasto';

  @override
  String get unknownErrorOccurred => 'Ocurrió un error desconocido';

  @override
  String get noEstimateLinkAvailable =>
      'No hay enlace de cotización disponible. Por favor genera uno primero.';

  @override
  String get generatingNewLink => 'Generando nuevo enlace...';

  @override
  String get errorLoadingCategory => 'Error al cargar categoría';

  @override
  String get imageExportComingSoon => 'Exportación de imagen próximamente';

  @override
  String get errorExportingCsv => 'Error al exportar CSV';

  @override
  String get errorCreatingInvoice => 'Error creando factura';

  @override
  String get errorProcessingImage => 'Error al procesar imagen';

  @override
  String get errorPickingImage => 'Error al seleccionar imagen';

  @override
  String get error => 'Error';

  @override
  String get errorSavingReceipt => 'Error al guardar recibo';

  @override
  String get qty => 'Cant';

  @override
  String get errorUpdatingReceipt => 'Error al actualizar recibo';

  @override
  String get errorInitiatingOcr => 'Error iniciando OCR';

  @override
  String get businessCategoryCreativeDesc =>
      'Diseño, publicidad, marketing y medios';

  @override
  String get businessCategoryOther => 'Otro';

  @override
  String get businessCategoryOtherDesc => 'Otro tipo de negocio no listado';

  @override
  String get onboardingFullNameHint => 'Ej: Juan Pérez';

  @override
  String get onboardingFullNameRequired => 'El nombre es requerido';

  @override
  String get onboardingEmailRequired => 'El correo es requerido';

  @override
  String get onboardingEmailInvalid => 'Ingresa un correo válido';

  @override
  String get onboardingEmailHint => 'Ej: juan@ejemplo.com';

  @override
  String get onboardingPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get onboardingPasswordRequired => 'La contraseña es requerida';

  @override
  String get onboardingPasswordMinLength => 'Mínimo 8 caracteres';

  @override
  String get onboardingConfirmPassword => 'Confirmar contraseña';

  @override
  String get onboardingConfirmPasswordHint => 'Repite tu contraseña';

  @override
  String get onboardingConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get onboardingPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get onboardingPhotoAdded => 'Foto agregada';

  @override
  String get onboardingPhotoRemoved => 'Foto removida';

  @override
  String get onboardingCreatingAccount => 'Creando cuenta...';

  @override
  String get onboardingCreateMyAccount => 'Crear mi cuenta';

  @override
  String get onboardingEditInformation => 'Editar información';

  @override
  String get onboardingCompleteAllInfo =>
      'Por favor, completa toda la información requerida.';

  @override
  String get onboardingAccountCreatedSuccess =>
      '¡Cuenta creada exitosamente! Bienvenido a Facturo.';

  @override
  String get onboardingAccountCreationError => 'Error al crear la cuenta';

  @override
  String get onboardingUnexpectedError => 'Error inesperado al crear la cuenta';

  @override
  String get onboardingImageSelectionError => 'Error al seleccionar imagen';

  @override
  String get payments => 'Pagos';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get currentPassword => 'Contraseña Actual';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get confirmNewPassword => 'Confirmar Nueva Contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada exitosamente';

  @override
  String get errorChangingPassword => 'Error al cambiar la contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get savedReceipts => 'Guardadas';

  @override
  String get scanReceipt => 'Escanear Recibo';

  @override
  String get noSavedReceipts => 'No hay facturas guardadas';

  @override
  String get scanFirstReceipt =>
      'Escanea tu primera factura para empezar a guardarlas';

  @override
  String get receiptViewed => 'Factura visualizada';

  @override
  String get receiptExported => 'Factura exportada';

  @override
  String get receiptDeleted => 'Factura eliminada';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get ocrTipStraight => 'Mantén el recibo recto y sin arrugas';

  @override
  String get ocrTipCloseUp =>
      'Acércate lo suficiente para que el texto sea legible';

  @override
  String get ocrExtractingText => 'Extrayendo texto...';

  @override
  String get ocrAnalyzingData => 'Analizando datos...';

  @override
  String get ocrParsingData => 'Procesando información...';

  @override
  String get ocrValidatingData => 'Validando información...';

  @override
  String get ocrReviewTitle => 'Revisar Datos Extraídos';

  @override
  String get ocrReviewInstructions =>
      'Revisa y edita los datos extraídos antes de crear una factura';

  @override
  String get ocrPreviewHint => 'Toca para ampliar';

  @override
  String get ocrCreateInvoice => 'Crear Factura';

  @override
  String get ocrEditBeforeCreate => 'Editar y Crear Factura';

  @override
  String get ocrSaveOnly => 'Solo Guardar Recibo';

  @override
  String get ocrRescan => 'Re-escaneo';

  @override
  String get ocrBasicInfo => 'Información Básica';

  @override
  String get ocrCompany => 'Empresa';

  @override
  String get ocrInvoiceNumber => 'Número de Factura';

  @override
  String get ocrDate => 'Fecha';

  @override
  String get ocrFinancialInfo => 'Información Financiera';

  @override
  String get ocrSubtotal => 'Subtotal';

  @override
  String get ocrTax => 'Impuestos';

  @override
  String get ocrTotal => 'Total';

  @override
  String get ocrItems => 'Items';

  @override
  String get ocrAddItem => 'Agregar Item';

  @override
  String get ocrNoItems => 'No hay items';

  @override
  String get companyName => 'Nombre de la Empresa';

  @override
  String get saveReceipt => 'Guardar Recibo';

  @override
  String get receiptSavedSuccess => 'Recibo guardado exitosamente';

  @override
  String get receiptSaveError => 'Error al guardar recibo';

  @override
  String get invoiceCreatedSuccess => 'Factura creada exitosamente';

  @override
  String get invoiceCreateError => 'Error al crear factura';

  @override
  String get scannedReceipt => 'Recibo Escaneado';

  @override
  String get scannedImage => 'Imagen Escaneada';

  @override
  String get tapToEnlarge => 'Toca para ampliar';

  @override
  String get receiptDetails => 'Detalles del Recibo';

  @override
  String get deleteImage => 'Eliminar Imagen';

  @override
  String get deleteImageConfirmation =>
      '¿Estás seguro de que quieres eliminar esta imagen?';

  @override
  String get editInvoice => 'Editar Factura';

  @override
  String get cancelEdit => 'Cancelar Edición';

  @override
  String get saveInvoice => 'Guardar Factura';

  @override
  String get moreOptions => 'Más Opciones';

  @override
  String get projects => 'Proyectos';

  @override
  String get settings => 'Configuración';

  @override
  String get scanDocument => 'Escanear Documento';

  @override
  String get selectImageSource => 'Seleccionar Fuente de Imagen';

  @override
  String get deleteProfileImage => 'Eliminar Foto de Perfil';

  @override
  String get deleteProfileImageConfirmation =>
      '¿Estás seguro de que quieres eliminar tu foto de perfil?';

  @override
  String get removePhoto => 'Quitar Foto';

  @override
  String get next => 'Siguiente';

  @override
  String get errorRefreshingData => 'Error al actualizar datos';

  @override
  String get errorLoadingClients => 'Error al cargar clientes';

  @override
  String get errorUploadingImage => 'Error al subir imagen';

  @override
  String get couldNotOpenEmailApp => 'No se pudo abrir la aplicación de email';

  @override
  String get errorSharingEstimate => 'Error al compartir cotización';

  @override
  String get errorSharingInvoice => 'Error al compartir factura';

  @override
  String get errorGeneratingPdf => 'Error al generar PDF';

  @override
  String get errorGeneratingPng => 'Error al generar PNG';

  @override
  String get errorSavingPng => 'Error al guardar PNG';

  @override
  String get errorDeletingLink => 'Error al eliminar link';

  @override
  String get noImageToPreview => 'No hay imagen para previsualizar';

  @override
  String get errorLoadingClientsEs => 'Error cargando clientes';

  @override
  String get invoiceHasBeenMarkedAsPaid =>
      'La factura ha sido marcada como pagada';

  @override
  String get invoiceIsPendingPayment => 'La factura está pendiente de pago';

  @override
  String get previewImage => 'Vista previa de imagen';

  @override
  String get uploadInvoiceImage => 'Subir imagen de factura';

  @override
  String get startFree => 'Probar Gratis';

  @override
  String get unlockPro => 'Desbloquear PRO';

  @override
  String get welcomeToFacturo => 'Bienvenido a Facturo';

  @override
  String get usageLimits => 'Límites de uso';

  @override
  String get start => 'Iniciar';

  @override
  String get invoiceScans => 'Escaneos de facturas';

  @override
  String freemiumLimitInvoicesTitle(int count) {
    return '$count Facturas';
  }

  @override
  String freemiumLimitInvoicesSubtitle(int count) {
    return 'Crea hasta $count facturas profesionales';
  }

  @override
  String freemiumLimitClientsTitle(int count) {
    return '$count Clientes';
  }

  @override
  String freemiumLimitClientsSubtitle(int count) {
    return 'Gestiona hasta $count clientes';
  }

  @override
  String freemiumLimitEstimatesTitle(int count) {
    return '$count Estimados';
  }

  @override
  String freemiumLimitEstimatesSubtitle(int count) {
    return 'Genera hasta $count cotizaciones';
  }

  @override
  String freemiumLimitOcrTitle(int count) {
    return '$count Escaneos de facturas';
  }

  @override
  String freemiumLimitOcrSubtitle(int count) {
    return 'Digitaliza $count facturas';
  }

  @override
  String freemiumLimitReportsTitle(int count) {
    return '$count Reportes';
  }

  @override
  String freemiumLimitReportsSubtitle(int count) {
    return 'Genera $count reportes detallados';
  }

  @override
  String get allYears => 'Todos';

  @override
  String get categoryAddedSuccessfully => 'Categoría agregada exitosamente';

  @override
  String get updateCategory => 'Actualizar Categoría';

  @override
  String get paywallDefaultMessage =>
      'Desbloquea facturación ilimitada\nCrea facturas profesionales sin límites y haz crecer tu negocio como nunca';

  @override
  String invoiceEmailSubject(String documentNumber) {
    return 'Factura $documentNumber';
  }

  @override
  String get invoiceEmailBody =>
      'Adjunto encontrarás la factura por tu reciente transacción.\n\n';

  @override
  String invoiceEmailThankYou(String clientName) {
    return '¡Gracias por tu preferencia, $clientName!\n\n';
  }

  @override
  String invoiceEmailAmountDue(String amount) {
    return 'Monto a pagar: $amount\n\n';
  }

  @override
  String get invoiceEmailContact =>
      'Para cualquier consulta, no dudes en contactarnos.';

  @override
  String estimateEmailSubject(String documentNumber) {
    return 'Cotización $documentNumber';
  }

  @override
  String get estimateEmailBody =>
      'Adjunto encontrarás la cotización para tu consideración.\n\n';

  @override
  String estimateEmailThankYou(String clientName) {
    return '¡Gracias por tu interés, $clientName!\n\n';
  }

  @override
  String estimateEmailTotal(String amount) {
    return 'Total de la cotización: $amount\n\n';
  }

  @override
  String get passwordRecoveryComingSoon =>
      'Función de recuperación de contraseña próximamente';

  @override
  String get goToLogin => 'Ir a iniciar sesión';

  @override
  String get share => 'Compartir';

  @override
  String get cloud => 'Nube';

  @override
  String get anonymousSubscriptionWarning =>
      'Para suscribirte a un plan PRO, primero necesitas crear una cuenta permanente. Esto asegurará que tu suscripción esté vinculada a tu cuenta.\n\n¿Deseas crear una cuenta ahora?';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get googleAccountConnected =>
      '¡Cuenta conectada con Google! Activando suscripción...';

  @override
  String get googleAccountConnectedSuccess =>
      '¡Cuenta conectada con Google exitosamente!';

  @override
  String get appleAccountConnected =>
      '¡Cuenta conectada con Apple! Activando suscripción...';

  @override
  String get appleAccountConnectedSuccess =>
      '¡Cuenta conectada con Apple exitosamente!';

  @override
  String get planActive => 'Plan Activo';

  @override
  String get networkError => 'Error de conexión. Verifica tu internet.';

  @override
  String get tryAgainLater => 'Intenta nuevamente.';

  @override
  String get userNotAuthenticated => 'Usuario no autenticado';

  @override
  String get invalidDateRange => 'Rango de fechas inválido';

  @override
  String get convertReceipt => 'Convertir Recibo';

  @override
  String get chooseConversionType => 'Elige cómo quieres convertir este recibo';

  @override
  String get convertToExpense => 'Convertir a Gasto';

  @override
  String get convertToExpenseDescription =>
      'Registra este recibo como un gasto para seguimiento';

  @override
  String get convertToInvoiceDescription =>
      'Crea una factura para enviar a un cliente';

  @override
  String get recommended => 'Recomendado';

  @override
  String get expenseCreatedSuccessfully => 'Gasto creado exitosamente';

  @override
  String get errorCreatingExpense => 'Error creando gasto';

  @override
  String get tapReceiptToViewOrScan =>
      'Toca un recibo para ver detalles, o escanea uno nuevo';

  @override
  String get unknownCompany => 'Empresa desconocida';

  @override
  String get saved => 'Guardado';

  @override
  String get created => 'Creado';

  @override
  String get item => 'Ítem';

  @override
  String get selectFromPhotos => 'Seleccionar de fotos';

  @override
  String get chooseHowToAddReceipt => 'Elige cómo quieres agregar un recibo';

  @override
  String get processingReceipt => 'Procesando recibo...';

  @override
  String get processingResults => 'Procesando resultados...';

  @override
  String get sendingToAI => 'Enviando para procesar...';

  @override
  String get initializingAI => 'Inicializando procesamiento...';

  @override
  String get improveYourDocument => 'Mejora tu documento';

  @override
  String get improveYourDocumentTooltip => 'Mejora tu documento';

  @override
  String get makeInvoicesMoreProfessional =>
      'Para que tus facturas se vean más profesionales, te recomendamos agregar:';

  @override
  String get makeEstimatesMoreProfessional =>
      'Para que tus estimados se vean más profesionales, te recomendamos agregar:';

  @override
  String get addBusinessLogo => 'Logo del negocio';

  @override
  String get addBusinessLogoDescription =>
      'Agrega tu logo para dar identidad a tus documentos';

  @override
  String get addDigitalSignature => 'Firma digital';

  @override
  String get addDigitalSignatureDescription =>
      'Incluye tu firma para mayor formalidad';

  @override
  String get elementsOptionalButImprove =>
      'Estos elementos son opcionales pero mejoran la presentación';

  @override
  String get laterButton => 'Más tarde';

  @override
  String get configureButton => 'Configurar';

  @override
  String get scanningProgress => 'Progreso del escaneo';

  @override
  String get complete => '¡Completado!';

  @override
  String get receiptLinkedToInvoice =>
      'Este recibo ya está vinculado a una factura.';

  @override
  String get failedToDeleteReceipt => 'Error al eliminar recibo';

  @override
  String get errorDeletingReceipt => 'Error eliminando recibo';

  @override
  String get saveExpense => 'Guardar Gasto';

  @override
  String otpCooldown(int seconds) {
    return 'Espera $seconds segundos antes de solicitar otro código';
  }

  @override
  String get otpSentToEmail => 'Código OTP enviado a tu email';

  @override
  String get enter6DigitCode => 'Ingresa el código de 6 dígitos';

  @override
  String get invalidOtpCode => 'Código OTP inválido';

  @override
  String get accountCreatedSuccessfully => '¡Cuenta creada exitosamente!';

  @override
  String get accountCreatedWithGoogle => '¡Cuenta creada con Google!';

  @override
  String get accountCreatedWithApple => '¡Cuenta creada con Apple!';

  @override
  String get signInCancelled => 'Inicio de sesión cancelado';

  @override
  String get errorConnectingGoogle => 'Error al conectar con Google';

  @override
  String get errorConnectingApple => 'Error al conectar con Apple';

  @override
  String get enterCodeSentToEmail => 'Ingresa el código enviado a tu email';

  @override
  String get willSendVerificationCode =>
      'Te enviaremos un código de verificación por email';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendIn(int seconds) {
    return 'Reenviar en ${seconds}s';
  }

  @override
  String get dontHaveAccountCreateOne => '¿No tienes cuenta? Crear una';

  @override
  String get iAcceptThe => 'Acepto los';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get andThe => 'y la';

  @override
  String get errorSendingOtp => 'Error al enviar código OTP';

  @override
  String get verifyCode => 'Verificar Código';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get otpCodeExpired =>
      'El código ha expirado. Por favor, solicita un nuevo código.';

  @override
  String get otpCodeInvalid =>
      'El código es inválido. Por favor, verifica e intenta nuevamente.';

  @override
  String get accountNotFoundCreateFirst =>
      'No se encontró una cuenta con este email. Por favor, crea una cuenta primero.';

  @override
  String get guestAccountWarningTitle => 'Cuenta de Invitado';

  @override
  String get guestAccountWarningMessage =>
      'Estás usando la app como invitado. Si desinstalas la app, cierras sesión o cambias de dispositivo, perderás permanentemente todos tus datos (facturas, clientes, gastos).';

  @override
  String get secureYourDataNow =>
      'Crea una cuenta permanente para proteger tu información';

  @override
  String get whyCreateAccount => '¿Por qué crear una cuenta?';

  @override
  String get benefit1SyncData => 'Sincroniza tus datos entre dispositivos';

  @override
  String get benefit2BackupCloud => 'Respaldo automático en la nube';

  @override
  String get benefit3RecoverData => 'Recupera datos si cambias de dispositivo';

  @override
  String get benefit4NeverLoseData => 'Nunca pierdas tus facturas y clientes';

  @override
  String get myAccount => 'Mi Cuenta';

  @override
  String get continueWithEmail => 'Continuar con Email';

  @override
  String get accountVerified => 'Cuenta Verificada';

  @override
  String get accountInformation => 'Información de la Cuenta';

  @override
  String get createAccountSubtitle =>
      'Crea tu cuenta para proteger tus facturas y clientes';

  @override
  String get loginSubtitle => 'Inicia sesión para acceder a tu cuenta';

  @override
  String get termsAgreement => 'Al continuar, aceptas nuestros';

  @override
  String get and => 'y';

  @override
  String get loginSuccessful => 'Sesión iniciada correctamente';

  @override
  String get back => 'Volver';

  @override
  String get continueWithoutAccount => 'Continuar sin cuenta';

  @override
  String get accountOptionalPrompt =>
      'Si deseas guardar y sincronizar tus datos entre dispositivos, crea una cuenta o inicia sesión.';

  @override
  String get convertReceiptToInvoice =>
      '¿Convertir este recibo en una nueva factura?';

  @override
  String get convertReceiptToExpense =>
      '¿Convertir este recibo en un nuevo gasto?';

  @override
  String get confirmDeleteReceipt =>
      '¿Estás seguro de que quieres eliminar este recibo?';

  @override
  String get emailAppOpenedSuccessfully => 'App de correo abierta exitosamente';

  @override
  String get errorOpeningEmailApp => 'Error al abrir la app de correo';

  @override
  String get errorGeneratingLink => 'Error al generar enlace';

  @override
  String get noLinkAvailable =>
      'No hay enlace disponible. Por favor genera un enlace primero.';

  @override
  String get errorExportingPdf => 'Error al exportar PDF';

  @override
  String get pngExportedSuccessfully => 'PNG exportado exitosamente';

  @override
  String get errorExportingPng => 'Error al exportar PNG';

  @override
  String get justNow => 'Justo ahora';

  @override
  String get pdfSubtotal => 'Subtotal';

  @override
  String get pdfTel => 'Tel:';

  @override
  String get pdfEmail => 'Email:';

  @override
  String get createExpense => 'Crear Gasto';

  @override
  String get currency => 'Moneda';

  @override
  String get searchCurrency => 'Buscar moneda...';

  @override
  String get all => 'Todas';

  @override
  String get currencyUpdatedTo => 'Moneda actualizada a';

  @override
  String get currencySettings => 'Configuración de Moneda';

  @override
  String get selectYourPreferredCurrency =>
      'Selecciona tu moneda preferida para facturas y reportes';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get dateWithFormat => 'Fecha (MM/DD/AAAA)';

  @override
  String get letsStartWithBasicInfo => 'Comencemos con tu información básica';

  @override
  String get tapToAddProfilePhoto => 'Toca para agregar foto de perfil';

  @override
  String get exampleName => 'Ej: Juan Pérez';

  @override
  String get exampleEmail => 'ejemplo@correo.com';

  @override
  String get continueButton => 'Continuar';

  @override
  String get tellUsAboutYourBusiness => 'Cuéntanos sobre tu negocio';

  @override
  String get tapToAddBusinessLogo => 'Toca para agregar logo del negocio';

  @override
  String get exampleBusinessName => 'Ej: Mi Empresa S.A.';

  @override
  String get exampleAddress => 'Ej: Calle Principal #123';

  @override
  String get exampleWebsite => 'Ej: https://mipagina.com';

  @override
  String get whatDoesYourBusinessDo => '¿A qué se dedica tu negocio?';

  @override
  String get selectCategoryDescription =>
      'Selecciona la categoría que mejor describe tu negocio';

  @override
  String get finishButton => 'Finalizar';

  @override
  String get changeProfilePicture => 'Cambiar foto de perfil';

  @override
  String get importFromContacts => 'Importar desde contactos';

  @override
  String createdFromOcrReceipt(String number) {
    return 'Creado desde recibo OCR\nFactura #: $number';
  }

  @override
  String createdFromOcrScan(String company) {
    return 'Creado desde escaneo OCR\nEmpresa: $company';
  }

  @override
  String itemNumberLabel(int number) {
    return 'Ítem $number';
  }

  @override
  String qtyTimesPrice(String qty, String price) {
    return 'Cant: $qty × \$$price';
  }

  @override
  String get doubleTapToScanReceipt => 'Toca dos veces para escanear un recibo';

  @override
  String get doubleTapToViewNotifications =>
      'Toca dos veces para ver notificaciones';

  @override
  String get doubleTapToOpenMoreOptions =>
      'Toca dos veces para abrir más opciones';

  @override
  String get currentSignature => 'Firma Actual';

  @override
  String get addCategory => 'Agregar Categoría';

  @override
  String get categoryNameRequired => 'Nombre de Categoría *';

  @override
  String get enterCategoryName => 'Ingresa nombre de categoría';

  @override
  String get pleaseEnterCategoryName =>
      'Por favor ingresa un nombre de categoría';

  @override
  String get loadingCategoryDetails => 'Cargando detalles de categoría...';

  @override
  String get generatingPdf => 'Generando PDF...';

  @override
  String get uploadingToCloud => 'Subiendo a la nube...';

  @override
  String get shareOnlineLink => 'Compartir Enlace en Línea';

  @override
  String get generatingPdfFile => 'Generando archivo PDF...';

  @override
  String get sharePdf => 'Compartir PDF';

  @override
  String get unlockAllFeatures => 'Desbloquea todas las funciones';

  @override
  String get unlimitedLabel => 'Sin límites';

  @override
  String get cloudLabel => 'Nube';

  @override
  String get viewPlans => 'Ver Planes';

  @override
  String get excelXlsx => 'Excel (XLSX)';

  @override
  String totalRecordsCount(int count) {
    return 'Total de Registros: $count';
  }

  @override
  String totalAmountFormatted(String amount) {
    return 'Monto Total: $amount';
  }

  @override
  String get pdfFormat => 'PDF';

  @override
  String get pushNotificationsRequirePermissions =>
      'Las notificaciones push requieren permisos del sistema. Puedes cambiar estos permisos en la configuración de tu dispositivo.';

  @override
  String get pdfInvoice => 'FACTURA';

  @override
  String get pdfBillTo => 'FACTURAR A';

  @override
  String get pdfFrom => 'DE';

  @override
  String get pdfDate => 'FECHA';

  @override
  String get pdfDue => 'VENCIMIENTO';

  @override
  String get pdfOnReceipt => 'Al Recibir';

  @override
  String get pdfPoNumber => '# OC';

  @override
  String get pdfDescription => 'DESCRIPCION';

  @override
  String get pdfRate => 'PRECIO';

  @override
  String get pdfQty => 'CANT';

  @override
  String get pdfAmount => 'MONTO';

  @override
  String get pdfTotalDue => 'TOTAL A PAGAR';

  @override
  String get pdfTotal => 'TOTAL';

  @override
  String get pdfBalanceDue => 'Saldo Pendiente';

  @override
  String get pdfNA => 'N/A';

  @override
  String get pdfOff => 'desc';

  @override
  String get pdfInvoiceDetails => 'DETALLES DE FACTURA';

  @override
  String get pdfInvoiceDate => 'Fecha de Factura';

  @override
  String get pdfDueDate => 'Fecha de Vencimiento';

  @override
  String get pdfDetails => 'DETALLES';

  @override
  String get pdfDateSigned => 'FECHA DE FIRMA';

  @override
  String get pdfPayableTo => 'Favor de hacer pagos a nombre de:';

  @override
  String get pdfAttachments => 'Adjuntos';

  @override
  String pdfPageOf(int current, int total) {
    return 'Pagina $current de $total';
  }

  @override
  String pdfImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imagenes',
      one: '$count imagen',
    );
    return '$_temp0';
  }

  @override
  String get pdfFallbackBusiness => 'Su Empresa';

  @override
  String get pdfFallbackClient => 'Nombre del Cliente';
}
