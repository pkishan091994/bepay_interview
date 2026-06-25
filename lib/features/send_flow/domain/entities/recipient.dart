import 'package:equatable/equatable.dart';

enum RecipientType { address, bepayId, email, phone }

class Recipient extends Equatable {
  final String id;
  final String name;
  final String address; // Could be a raw EVM address, email, phone, or BepayID
  final RecipientType type;
  final bool
  isExternal; // True if it's an external blockchain address, false for internal Bepay transfer
  final String? badge; // Optional visual badge (e.g., "LAST USED")
  final String? timestamp; // Optional contact time (e.g., "2h ago")

  const Recipient({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.isExternal,
    this.badge,
    this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    type,
    isExternal,
    badge,
    timestamp,
  ];
}
