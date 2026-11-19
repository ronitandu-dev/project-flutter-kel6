import 'package:flutter_dotenv/flutter_dotenv.dart';

/// SATU berkas konfigurasi: semua nilai dibaca dari .env
/// (alamat kontrak, RPC URL, chain ID, private key).
class AppConfig {
  static String get rpcUrl => dotenv.env['RPC_URL']!;
  static String get contractAddress => dotenv.env['CONTRACT_ADDRESS']!;
  static int get chainId =>
      int.parse(dotenv.env['CHAIN_ID'] ?? '11155111'); // Sepolia
  static String get privateKey => dotenv.env['PRIVATE_KEY']!;

  static const String abiAsset = 'assets/abi/ChainTodo.json';
  static const String explorerTx = 'https://sepolia.etherscan.io/tx/';
}
