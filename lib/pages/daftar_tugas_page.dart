import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart';
import '../models/tugas.dart';
import '../services/chain_todo_service.dart';
import 'tambah_tugas_page.dart';

class DaftarTugasPage extends StatefulWidget {
  const DaftarTugasPage({super.key});

  @override
  State<DaftarTugasPage> createState() => _DaftarTugasPageState();
}

class _DaftarTugasPageState extends State<DaftarTugasPage> {
  final _service = ChainTodoService();
  List<Tugas> _tugas = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mulai();
  }

  Future<void> _mulai() async {
    try {
      await _service.init();
      await _muat();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Gagal inisialisasi: $e';
      });
    }
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.ambilSemua();
      if (!mounted) return;
      setState(() {
        _tugas = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat data: $e';
      });
    }
  }

  /// Indikator status transaksi: memproses -> berhasil (hash) / gagal (error)
  Future<void> _kirim(Future<String> Function() aksi, String pesan) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(pesan)),
        ]),
      ),
    );
    try {
      final hash = await aksi();
      await _service.tunggu(hash);
      if (!mounted) return;
      Navigator.of(context).pop();
      _tampilkanHasil(berhasil: true, teks: hash);
      await _muat();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _tampilkanHasil(berhasil: false, teks: e.toString());
    }
  }

  void _tampilkanHasil({required bool berhasil, required String teks}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: berhasil ? Colors.green[700] : Colors.red[700],
      duration: const Duration(seconds: 8),
      content: Text(berhasil
          ? 'Berhasil ✔\nHash: $teks\n${AppConfig.explorerTx}$teks'
          : 'Gagal ✘\n$teks'),
    ));
  }

  Future<void> _tambah() async {
    final judul = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const TambahTugasPage()),
    );
    if (judul == null) return;
    await _kirim(() => _service.tambahTugas(judul), 'Mengirim tugas baru...');
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChainTodo'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _muat,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _tambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: _isi(fmt),
      ),
    );
  }

  Widget _isi(DateFormat fmt) {
    if (_loading && _tugas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(children: [
        Padding(padding: const EdgeInsets.all(24), child: Text(_error!)),
      ]);
    }
    if (_tugas.isEmpty) {
      return ListView(children: const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada tugas. Tekan "Tambah".'),
        ),
      ]);
    }
    return ListView.separated(
      itemCount: _tugas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = _tugas[i];
        final milikSaya =
            t.pembuat.toLowerCase() == _service.alamatSaya.toLowerCase();
        return ListTile(
          leading: Icon(
            t.selesai ? Icons.check_circle : Icons.radio_button_unchecked,
            color: t.selesai ? Colors.green : null,
          ),
          title: Text(
            t.judul,
            style: TextStyle(
              decoration: t.selesai ? TextDecoration.lineThrough : null,
              color: t.selesai ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
              '#${t.id} • ${fmt.format(t.dibuat)}\n${_singkat(t.pembuat)}'),
          isThreeLine: true,
          trailing: (!t.selesai && milikSaya)
              ? TextButton(
                  onPressed: () => _kirim(
                      () => _service.tandaiSelesai(t.id), 'Menandai selesai...'),
                  child: const Text('Selesai'),
                )
              : null,
        );
      },
    );
  }

  String _singkat(String a) => '${a.substring(0, 8)}...${a.substring(a.length - 6)}';
}
