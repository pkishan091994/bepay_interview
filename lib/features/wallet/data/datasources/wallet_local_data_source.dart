import 'package:bepay_interview/features/wallet/data/models/token_model.dart';

abstract class WalletLocalDataSource {
  Future<List<TokenModel>> getBalances();
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  @override
  Future<List<TokenModel>> getBalances() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      const TokenModel(
        id: 'USDC',
        name: 'USD Coin',
        symbol: 'USDC',
        balance: 250.50,
        fiatRate: 1.0,
        decimals: 6,
        network: 'Polygon',
        iconUrl: 'usdc',
      ),
      const TokenModel(
        id: 'ETH',
        name: 'Ethereum',
        symbol: 'ETH',
        balance: 1.240,
        fiatRate: 2519.3548,
        decimals: 18,
        network: 'Mainnet',
        iconUrl: 'eth',
      ),
      const TokenModel(
        id: 'BTC',
        name: 'Bitcoin',
        symbol: 'BTC',
        balance: 0.005,
        fiatRate: 82460.0,
        decimals: 8,
        network: 'Native',
        iconUrl: 'btc',
      ),
      const TokenModel(
        id: 'SOL',
        name: 'Solana',
        symbol: 'SOL',
        balance: 45.00,
        fiatRate: 100.0,
        decimals: 9,
        network: 'Solana',
        iconUrl: 'sol',
      ),
      const TokenModel(
        id: 'MATIC',
        name: 'Polygon',
        symbol: 'MATIC',
        balance: 1000.0,
        fiatRate: 0.94,
        decimals: 18,
        network: 'Polygon',
        iconUrl: 'matic',
      ),
    ];
  }
}
