import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../config/app_config.dart';
import '../models/tugas.dart';

class ChainTodoService {
  late final Web3Client _client;
  late final DeployedContract _contract;
  late final EthPrivateKey _credentials;

  late final ContractFunction _fnJumlah;
  late final ContractFunction _fnAmbil;
  late final ContractFunction _fnTambah;
  late final ContractFunction _fnSelesai;

  String get alamatSaya => _credentials.address.hexEip55;

  Future<void> init() async {
    _client = Web3Client(AppConfig.rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(AppConfig.privateKey);

    final abiJson = await rootBundle.loadString(AppConfig.abiAsset);
    _contract = DeployedContract(
      ContractAbi.fromJson(abiJson, 'ChainTodo'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
    _fnJumlah = _contract.function('jumlahTugas');
    _fnAmbil = _contract.function('ambilTugas');
    _fnTambah = _contract.function('tambahTugas');
    _fnSelesai = _contract.function('tandaiSelesai');
  }

  // ---------- BACA (view, gratis) ----------
  Future<List<Tugas>> ambilSemua() async {
    final hasil = await _client
        .call(contract: _contract, function: _fnJumlah, params: []);
    final jumlah = (hasil.first as BigInt).toInt();

    final daftar = <Tugas>[];
    for (var i = 0; i < jumlah; i++) {
      final r = await _client.call(
        contract: _contract,
        function: _fnAmbil,
        params: [BigInt.from(i)],
      );
      daftar.add(Tugas(
        id: i,
        judul: r[0] as String,
        selesai: r[1] as bool,
        dibuat: DateTime.fromMillisecondsSinceEpoch(
            (r[2] as BigInt).toInt() * 1000),
        pembuat: (r[3] as EthereumAddress).hexEip55,
      ));
    }
    return daftar.reversed.toList(); // terbaru di atas
  }

  // ---------- TULIS (transaksi, butuh gas) ----------
  Future<String> tambahTugas(String judul) {
    return _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _fnTambah,
        parameters: [judul],
      ),
      chainId: AppConfig.chainId,
    );
  }

  Future<String> tandaiSelesai(int id) {
    return _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _fnSelesai,
        parameters: [BigInt.from(id)],
      ),
      chainId: AppConfig.chainId,
    );
  }

  /// Menunggu transaksi masuk blok. Melempar Exception bila gagal/timeout.
  Future<void> tunggu(String hash) async {
    for (var i = 0; i < 60; i++) {
      final receipt = await _client.getTransactionReceipt(hash);
      if (receipt != null) {
        if (receipt.status == false) {
          throw Exception('Transaksi di-revert oleh kontrak');
        }
        return;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    throw Exception('Timeout menunggu konfirmasi transaksi');
  }

  void dispose() => _client.dispose();
}
