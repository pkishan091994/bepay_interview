import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';

class NumberFormatter {
  /// Formats a double value as USD currency, e.g. 9226.80 -> $9,226.80
  static String formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String integer =
        parts[0].replaceAllMapped(reg, (Match match) => '${match[1]},');
    return '\$$integer.${parts[1]}';
  }

  /// Formats a token balance based on its type and symbol
  static String formatBalance(TokenBalance token) {
    final int fixedDecimals =
        (token.symbol == 'BTC' || token.symbol == 'ETH') ? 3 : 2;
    final parts = token.balance.toStringAsFixed(fixedDecimals).split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String integer =
        parts[0].replaceAllMapped(reg, (Match match) => '${match[1]},');

    if (token.symbol == 'MATIC') {
      return integer; // Just '1,000'
    }
    return '$integer.${parts[1]}';
  }

  /// Formats a token's total fiat value dynamically
  static String formatTokenFiatValue(TokenBalance token) {
    return formatCurrency(token.balance * token.fiatRate);
  }
}
