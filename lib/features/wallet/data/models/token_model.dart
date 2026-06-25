import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';

class TokenModel extends TokenBalance {
  const TokenModel({
    required super.id,
    required super.name,
    required super.symbol,
    required super.balance,
    required super.fiatRate,
    required super.decimals,
    required super.network,
    super.iconUrl,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      balance: (json['balance'] as num).toDouble(),
      fiatRate: (json['fiatRate'] as num).toDouble(),
      decimals: json['decimals'] as int,
      network: json['network'] as String,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'balance': balance,
      'fiatRate': fiatRate,
      'decimals': decimals,
      'network': network,
      'iconUrl': iconUrl,
    };
  }
}
