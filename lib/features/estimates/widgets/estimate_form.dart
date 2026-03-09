import 'dart:io';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/widgets/estimate_items_list.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import 'package:facturo/core/design_system/design_system.dart';

class EstimateForm extends ConsumerStatefulWidget {
  final Estimate? estimate;
  final Function(Estimate) onSubmit;

  const EstimateForm({super.key, this.estimate, required this.onSubmit});

  @override
  ConsumerState<EstimateForm> createState() => _EstimateFormState();
}

class _EstimateFormState extends ConsumerState<EstimateForm>
    with FreemiumMixin, AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _documentDate;
  DateTime? _expiryDate;
  String? _clientId;
  double? _generalDiscount;
  String _generalDiscountType = 'percentage';
  double? _generalTax;
  String _generalTaxType = 'percentage';

  File? _photoFile;
  String? _photoUrl;
  String? _signatureUrl;
  bool _isUploading = false;

  List<Map<String, dynamic>> _clients = [];
  bool _isLoadingClients = false;

  final List<EstimateDetail> _estimateDetails = [];

  String? _clientError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _documentDate = widget.estimate?.documentDate ?? DateTime.now();
    // Set default expiry date to 30 days from document date
    _expiryDate = widget.estimate?.expiryDate ??
        _documentDate?.add(const Duration(days: 30));
    // Set default values for discount and tax
    _generalDiscount = widget.estimate?.generalDiscount ?? 0.00;
    _generalTax = widget.estimate?.generalTax ?? 0.00;
    // Load clients
    _loadClients();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.estimate != null) {
      _documentNumberController.text = widget.estimate!.documentNumber ?? '';
      _poNumberController.text = widget.estimate!.poNumber ?? '';
      _generalDiscountType =
          widget.estimate!.generalDiscountType ?? 'percentage';
      _generalTaxType = widget.estimate!.generalTaxType ?? 'percentage';
      _photoUrl = widget.estimate!.photoUrl;
      _signatureUrl = widget.estimate!.signatureUrl;
      _notesController.text = widget.estimate!.notes ?? '';

      if (widget.estimate!.details != null) {
        _estimateDetails.addAll(widget.estimate!.details!);
      }
    }
  }

  // Load clients from the database
  Future<void> _loadClients() async {
    setState(() {
      _isLoadingClients = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('clients')
          .select('clients_id, client_name')
          .eq('user_id', userId)
          .eq('status', true)
          .order('client_name');

      setState(() {
        _clients = List<Map<String, dynamic>>.from(response);
        _isLoadingClients = false;

        // Validate and set clientId after loading clients
        if (widget.estimate != null && widget.estimate!.clientId != null) {
          final clientExists = _clients.any(
              (client) => client['clients_id'] == widget.estimate!.clientId);
          if (clientExists) {
            _clientId = widget.estimate!.clientId;
          } else {
            // Client no longer exists, clear the selection
            _clientId = null;
            _clientError = AppLocalizations.of(context).clientNoLongerAvailable;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });
      if (mounted) {
        SnackbarService.showGenericError(context, error: e.toString());
      }
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _poNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String?> _uploadPhoto() async {
    if (_photoFile == null) return _photoUrl;

    setState(() {
      _isUploading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final fileExt = _photoFile!.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final filePath = 'estimates/$fileName';

      final storageService = StorageService(supabase);
      final storedPath = await storageService.uploadFile(
        filePath: filePath,
        file: _photoFile!,
      );

      return storedPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading image: $e');
      }
      if (!mounted) return null;
      SnackbarService.showGenericError(context, error: e.toString());
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Si es un nuevo estimado, verificar límite freemium
    if (widget.estimate == null) {
      final canCreate = await executeIfAllowed(
        FreemiumAction.createEstimate,
        () async {
          await _createEstimate();
        },
      );

      // Si no se pudo crear por límite, executeIfAllowed ya mostró el paywall
      if (!canCreate) return;
    } else {
      // Si es edición, proceder normalmente
      await _createEstimate();
    }
  }

  Future<void> _createEstimate() async {
    try {
      // Get the current values from the form
      _formKey.currentState!.save();

      // Create or update the estimate
      final estimate = Estimate(
        id: widget.estimate?.id,
        documentNumber: _documentNumberController.text,
        documentDate: _documentDate,
        expiryDate: _expiryDate,
        poNumber: _poNumberController.text,
        clientId: _clientId,
        generalDiscount: _generalDiscount,
        generalDiscountType: _generalDiscountType,
        generalTax: _generalTax,
        generalTaxType: _generalTaxType,
        photoUrl: await _uploadPhoto(),
        notes: _notesController.text,
        signatureUrl: _signatureUrl,
        details: _estimateDetails,
      );

      await widget.onSubmit(estimate);
    } catch (e) {
      if (mounted) {
        SnackbarService.showGenericError(context, error: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesignTokens.gapSm,

            // Estimate Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).estimateInformation,
              children: [
                _buildFormField(
                  controller: _documentNumberController,
                  label: AppLocalizations.of(context).estimateNumberRequired,
                  hint: AppLocalizations.of(context).enterEstimateNumber,
                  icon: Iconsax.document_text_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterEstimateNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  theme,
                  AppLocalizations.of(context).estimateDateRequired,
                  _documentDate,
                  AppLocalizations.of(context).selectEstimateDate,
                  (date) {
                    setState(() {
                      _documentDate = date;
                      // Auto-set expiry date 30 days later if not set
                      _expiryDate ??= date.add(const Duration(days: 30));
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  theme,
                  AppLocalizations.of(context).validUntilRequired,
                  _expiryDate,
                  AppLocalizations.of(context).selectExpiryDate,
                  (date) {
                    setState(() {
                      _expiryDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _poNumberController,
                  label: AppLocalizations.of(context).poNumberOptional,
                  hint: AppLocalizations.of(context).enterPoNumberOptional,
                  icon: Iconsax.tag_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Client Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).clientInformation,
              children: [
                _buildDropdownField(
                  value: _clientId,
                  label: AppLocalizations.of(context).clientRequired,
                  hint: _isLoadingClients
                      ? AppLocalizations.of(context).loadingClients
                      : AppLocalizations.of(context).selectClient,
                  icon: Iconsax.user_outline,
                  items: _isLoadingClients
                      ? [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppLocalizations.of(context).loadingClients),
                          ),
                        ]
                      : _clients.isEmpty
                          ? [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(AppLocalizations.of(context).noClientsAvailable),
                              ),
                            ]
                          : [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(AppLocalizations.of(context).selectAClient),
                              ),
                              ..._clients.map((client) {
                                return DropdownMenuItem<String>(
                                  value: client['clients_id'],
                                  child: Text(client['client_name']),
                                );
                              }),
                            ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _clientId = newValue;
                      _clientError = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseSelectClient;
                    }
                    return null;
                  },
                ),
                if (_clientError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _clientError!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Information Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).additionalInformation,
              children: [
                _buildFormField(
                  controller: _notesController,
                  label: AppLocalizations.of(context).notes,
                  hint: AppLocalizations.of(context).additionalNotesOptional,
                  icon: Iconsax.note_text_outline,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estimate Items Section
            _buildSectionCard(
              theme,
              title: AppLocalizations.of(context).estimateItems,
              children: [
                EstimateItemsList(
                  estimateId: widget.estimate?.id ?? 'temp_id',
                  items: _estimateDetails,
                  onItemsChanged: (items) {
                    setState(() {
                      _estimateDetails.clear();
                      _estimateDetails.addAll(items);
                    });
                  },
                  generalDiscount: _generalDiscount,
                  generalDiscountType: _generalDiscountType,
                  generalTax: _generalTax,
                  generalTaxType: _generalTaxType,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    vertical: LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
                  ),
                  minimumSize: Size(
                    double.infinity,
                    LayoutSystem.isMobile(context) ? 48 : 56
                  ),
                ),
                child: Text(
                  widget.estimate == null
                      ? AppLocalizations.of(context).createEstimate
                      : AppLocalizations.of(context).updateEstimate,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: LayoutSystem.isMobile(context) ? DesignTokens.fontSizeMd : DesignTokens.fontSizeLg,
                  ),
                ),
              ),
            ),
            SizedBox(height: LayoutSystem.isMobile(context) ? DesignTokens.spacing3xl : DesignTokens.spacing4xl),
          ],
        ),
      ),
    );
  }

  // Build section card with modern design
  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              DesignTokens.spacingSm,
            ),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: LayoutSystem.isMobile(context) ? DesignTokens.fontSizeMd : DesignTokens.fontSizeLg,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Section content
          Padding(
            padding: EdgeInsets.fromLTRB(
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              0,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingLg : DesignTokens.spacingXl,
              LayoutSystem.isMobile(context) ? DesignTokens.spacingMd : DesignTokens.spacingLg,
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // Build form field with modern design
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
    );
  }

  // Build date field with modern design
  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime? selectedDate,
    String hint,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Iconsax.calendar_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode).format(selectedDate)
              : hint,
        ),
      ),
    );
  }

  // Build dropdown field with modern design
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
