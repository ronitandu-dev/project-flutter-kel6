# ChainTodo – Aplikasi Flutter Terhubung Blockchain

Mata kuliah Pemrograman Mobile 2 – D4 Teknologi Rekayasa Komputer, Polnes.

Aplikasi to-do list Flutter yang datanya disimpan di smart contract (testnet **Sepolia**).

## Anggota & Pembagian Tugas
| Nama | NIM (jangan tulis jika tidak perlu) | Tugas |
|---|---|---|
| ... | ... | Smart contract + deploy |
| ... | ... | UI Flutter |
| ... | ... | Integrasi web3dart, dokumentasi |

## Info Kontrak
- Jaringan: Sepolia (chain ID 11155111)
- Alamat kontrak: `0x...ISI...`
- Etherscan: https://sepolia.etherscan.io/address/0x...ISI...

## Versi Paket
| Paket | Versi |
|---|---|
| Flutter | (isi dari `flutter --version`) |
| web3dart | (isi dari pubspec.lock) |
| http | (isi dari pubspec.lock) |
| flutter_dotenv | (isi dari pubspec.lock) |

## Cara Menjalankan
1. `flutter create .` (sekali saja, untuk membuat folder android/ios) lalu `flutter pub get`
2. Salin `.env.example` menjadi `.env`, isi `RPC_URL`, `CONTRACT_ADDRESS`, `PRIVATE_KEY` (akun MetaMask khusus tugas).
3. `flutter run` atau `flutter build apk --release`

## Keamanan
- `.env` ada di `.gitignore`; tidak ada private key/seed phrase di repositori.
- Hanya testnet Sepolia, wallet khusus tugas.

## Sumber Kode yang Diadaptasi
- Kerangka kontrak dari dokumen tugas.
- Video tutorial 4 & 5 (Flutter + web3dart) – sebutkan bagian yang diadaptasi.
- Bantuan AI (sebutkan bagian yang dibantu).
