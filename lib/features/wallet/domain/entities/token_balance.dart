import 'package:equatable/equatable.dart';

class TokenBalance extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final double balance;
  final double fiatRate; // Price per token in USD
  final int decimals; // e.g. 18 for ETH, 6 for USDT
  final String network; // e.g. "Ethereum Mainnet"
  final String? iconUrl;

  const TokenBalance({
    required this.id,
    required this.name,
    required this.symbol,
    required this.balance,
    required this.fiatRate,
    required this.decimals,
    required this.network,
    this.iconUrl,
  });

  double get fiatBalance => balance * fiatRate;

  @override
  List<Object?> get props => [
    id,
    name,
    symbol,
    balance,
    fiatRate,
    decimals,
    network,
    iconUrl,
  ];
}
