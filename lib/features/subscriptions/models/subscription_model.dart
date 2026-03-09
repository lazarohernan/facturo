import 'dart:convert';
import 'package:flutter/material.dart';

/// Available subscription types in the application
enum SubscriptionType { monthly, annual }

/// Represents a subscription plan available for purchase
class SubscriptionPlan {
  final String id;
  final String title;
  final String description;
  final String titleEs; // Spanish title
  final String descriptionEs; // Spanish description
  final double price;
  final String currency;
  final SubscriptionType type;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.titleEs,
    required this.descriptionEs,
    required this.price,
    required this.currency,
    required this.type,
  });

  // Get localized title based on current locale
  String getLocalizedTitle(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'es') {
      return titleEs;
    }
    return title;
  }

  // Get localized description based on current locale
  String getLocalizedDescription(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'es') {
      return descriptionEs;
    }
    return description;
  }

  // Predefined subscription plans
  static const SubscriptionPlan monthly = SubscriptionPlan(
    id: 'facturo_monthly_subscription',
    title: 'Monthly Plan',
    description: 'Unlimited invoicing renewed monthly',
    titleEs: 'Plan Mensual',
    descriptionEs: 'Facturación ilimitada renovada mensualmente',
    price: 15.0,
    currency: 'USD',
    type: SubscriptionType.monthly,
  );

  static const SubscriptionPlan annual = SubscriptionPlan(
    id: 'facturo_annual_subscription',
    title: 'Annual Plan',
    description: 'Unlimited invoicing renewed annually',
    titleEs: 'Plan Anual',
    descriptionEs: 'Facturación ilimitada renovada anualmente',
    price: 150.0,
    currency: 'USD',
    type: SubscriptionType.annual,
  );

  // List of all available plans
  static const List<SubscriptionPlan> allPlans = [monthly, annual];
}

/// Subscription status enum
enum SubscriptionStatus {
  active,        // Activa y renovando
  canceled,      // Cancelada pero aún válida hasta expiry_date
  expired,       // Expirada
  inGracePeriod, // En período de gracia por problema de pago
  refunded       // Reembolsada
}

/// Represents the user's subscription information
class SubscriptionInfo {
  bool isActive;
  final SubscriptionType type;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String? transactionId;
  final DateTime? cancellationDate;
  final DateTime? gracePeriodExpiresAt;
  final bool isAutoRenew;
  final DateTime? refundDate;
  final DateTime lastVerifiedAt;
  final String? platform;
  final String? productId;

  SubscriptionInfo({
    this.isActive = false,
    required this.type,
    required this.purchaseDate,
    required this.expiryDate,
    this.transactionId,
    this.cancellationDate,
    this.gracePeriodExpiresAt,
    this.isAutoRenew = true,
    this.refundDate,
    DateTime? lastVerifiedAt,
    this.platform,
    this.productId,
  }) : lastVerifiedAt = lastVerifiedAt ?? DateTime.now();
  
  // Constructor para una suscripción inactiva
  factory SubscriptionInfo.inactive() {
    return SubscriptionInfo(
      isActive: false,
      type: SubscriptionType.monthly,
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(0),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(0),
      isAutoRenew: false,
    );
  }

  /// Get the current status of the subscription
  SubscriptionStatus get status {
    final now = DateTime.now();
    
    // Si fue reembolsada
    if (refundDate != null) {
      return SubscriptionStatus.refunded;
    }
    
    // Si está en grace period
    if (gracePeriodExpiresAt != null && gracePeriodExpiresAt!.isAfter(now)) {
      return SubscriptionStatus.inGracePeriod;
    }
    
    // Si expiró el grace period
    if (gracePeriodExpiresAt != null && gracePeriodExpiresAt!.isBefore(now)) {
      return SubscriptionStatus.expired;
    }
    
    // Si ya expiró
    if (expiryDate.isBefore(now)) {
      return SubscriptionStatus.expired;
    }
    
    // Si fue cancelada pero aún está dentro del período pagado
    if (cancellationDate != null && expiryDate.isAfter(now)) {
      return SubscriptionStatus.canceled;
    }
    
    // Si está activa y renovando
    if (isActive && isAutoRenew) {
      return SubscriptionStatus.active;
    }
    
    // Si está activa pero no renovará
    if (isActive && !isAutoRenew) {
      return SubscriptionStatus.canceled;
    }
    
    return SubscriptionStatus.expired;
  }
  
  /// Check if user has access to premium features
  bool get hasAccess {
    final now = DateTime.now();
    return isActive && 
           expiryDate.isAfter(now) && 
           refundDate == null &&
           (gracePeriodExpiresAt == null || gracePeriodExpiresAt!.isAfter(now));
  }
  
  /// Get days remaining until expiration
  int get daysRemaining {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) return 0;
    return expiryDate.difference(now).inDays;
  }
  
  /// Check if subscription will expire soon (within 7 days)
  bool get willExpireSoon {
    return daysRemaining > 0 && daysRemaining <= 7;
  }

  /// Creates a copy of this instance with updated fields
  SubscriptionInfo copyWith({
    bool? isActive,
    SubscriptionType? type,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? transactionId,
    DateTime? cancellationDate,
    DateTime? gracePeriodExpiresAt,
    bool? isAutoRenew,
    DateTime? refundDate,
    DateTime? lastVerifiedAt,
    String? platform,
    String? productId,
  }) {
    return SubscriptionInfo(
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      transactionId: transactionId ?? this.transactionId,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      gracePeriodExpiresAt: gracePeriodExpiresAt ?? this.gracePeriodExpiresAt,
      isAutoRenew: isAutoRenew ?? this.isAutoRenew,
      refundDate: refundDate ?? this.refundDate,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      platform: platform ?? this.platform,
      productId: productId ?? this.productId,
    );
  }

  /// Converts this instance to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'is_active': isActive,
      'type': type.name,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'transaction_id': transactionId,
      'cancellation_date': cancellationDate?.toIso8601String(),
      'grace_period_expires_at': gracePeriodExpiresAt?.toIso8601String(),
      'is_auto_renew': isAutoRenew,
      'refund_date': refundDate?.toIso8601String(),
      'last_verified_at': lastVerifiedAt.toIso8601String(),
      'platform': platform,
      'product_id': productId,
    };
  }

  /// Creates an instance from a JSON map
  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      isActive: map['is_active'] ?? false,
      type: SubscriptionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SubscriptionType.monthly
      ),
      purchaseDate: DateTime.parse(map['purchase_date']),
      expiryDate: DateTime.parse(map['expiry_date']),
      transactionId: map['transaction_id'],
      cancellationDate: map['cancellation_date'] != null 
          ? DateTime.parse(map['cancellation_date']) 
          : null,
      gracePeriodExpiresAt: map['grace_period_expires_at'] != null 
          ? DateTime.parse(map['grace_period_expires_at']) 
          : null,
      isAutoRenew: map['is_auto_renew'] ?? true,
      refundDate: map['refund_date'] != null 
          ? DateTime.parse(map['refund_date']) 
          : null,
      lastVerifiedAt: map['last_verified_at'] != null 
          ? DateTime.parse(map['last_verified_at']) 
          : DateTime.now(),
      platform: map['platform'],
      productId: map['product_id'],
    );
  }

  /// Converts this instance to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates an instance from a JSON string
  factory SubscriptionInfo.fromJson(String source) =>
      SubscriptionInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SubscriptionInfo(isActive: $isActive, type: $type, status: ${status.name}, purchaseDate: $purchaseDate, expiryDate: $expiryDate, transactionId: $transactionId, cancellationDate: $cancellationDate, isAutoRenew: $isAutoRenew)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubscriptionInfo &&
        other.isActive == isActive &&
        other.type == type &&
        other.purchaseDate == purchaseDate &&
        other.expiryDate == expiryDate &&
        other.transactionId == transactionId &&
        other.cancellationDate == cancellationDate &&
        other.gracePeriodExpiresAt == gracePeriodExpiresAt &&
        other.isAutoRenew == isAutoRenew &&
        other.refundDate == refundDate &&
        other.platform == platform &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    return isActive.hashCode ^
        type.hashCode ^
        purchaseDate.hashCode ^
        expiryDate.hashCode ^
        transactionId.hashCode ^
        cancellationDate.hashCode ^
        gracePeriodExpiresAt.hashCode ^
        isAutoRenew.hashCode ^
        refundDate.hashCode ^
        platform.hashCode ^
        productId.hashCode;
  }
}
