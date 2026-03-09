import 'package:uuid/uuid.dart';

class Client {
  final String clientsId;
  final String? userId;
  final String clientName;
  final String? clientEmail;
  final String? secondaryEmailClient;
  final String? clientMobile;
  final String? clientPhone;
  final String? clientAddress1;
  final String? clientAddress2;
  final DateTime createdAt;
  final bool status;

  Client({
    String? clientsId,
    this.userId,
    required this.clientName,
    this.clientEmail,
    this.secondaryEmailClient,
    this.clientMobile,
    this.clientPhone,
    this.clientAddress1,
    this.clientAddress2,
    DateTime? createdAt,
    this.status = true,
  }) : clientsId = clientsId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Getters para compatibilidad con el código existente
  String get id => clientsId;
  String get name => clientName;
  String? get email => clientEmail;
  String? get phone => clientPhone ?? clientMobile;
  String? get company => secondaryEmailClient; // Usando como compañía temporalmente
  String? get address => clientAddress1;

  // Create a Client from a JSON map
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientsId: json['clients_id'],
      userId: json['user_id'],
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      secondaryEmailClient: json['secondary_email_client'],
      clientMobile: json['client_mobile'],
      clientPhone: json['client_phone'],
      clientAddress1: json['client_address_1'],
      clientAddress2: json['client_address_2'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? true,
    );
  }

  // Convert Client to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'clients_id': clientsId,
      'user_id': userId,
      'client_name': clientName,
      'client_email': clientEmail,
      'secondary_email_client': secondaryEmailClient,
      'client_mobile': clientMobile,
      'client_phone': clientPhone,
      'client_address_1': clientAddress1,
      'client_address_2': clientAddress2,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  // Convert Client to a JSON map for creating a new client (without ID and createdAt)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'client_name': clientName,
      'client_email': clientEmail,
      'secondary_email_client': secondaryEmailClient,
      'client_mobile': clientMobile,
      'client_phone': clientPhone,
      'client_address_1': clientAddress1,
      'client_address_2': clientAddress2,
      'status': status,
    };
  }

  // Create a copy of Client with updated fields
  Client copyWith({
    String? clientsId,
    String? userId,
    String? clientName,
    String? clientEmail,
    String? secondaryEmailClient,
    String? clientMobile,
    String? clientPhone,
    String? clientAddress1,
    String? clientAddress2,
    DateTime? createdAt,
    bool? status,
  }) {
    return Client(
      clientsId: clientsId ?? this.clientsId,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      secondaryEmailClient: secondaryEmailClient ?? this.secondaryEmailClient,
      clientMobile: clientMobile ?? this.clientMobile,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress1: clientAddress1 ?? this.clientAddress1,
      clientAddress2: clientAddress2 ?? this.clientAddress2,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
