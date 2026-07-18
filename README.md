# 🏦 Tabungan Crypto — Workshop Smart Contract (Solidity + Foundry)

Proyek workshop untuk belajar membuat smart contract Ethereum dari nol menggunakan
**Solidity** dan **Foundry**. Kita membangun aplikasi **tabungan crypto** sederhana:

- **`RupiahToken` (ERC20)** — token "Rupiah" (IDRT) yang berperan sebagai uang.
- **`Vault`** — celengan tempat menyimpan token Rupiah; mencatat saldo tiap orang
  dan bisa ditarik kapan saja.

> Catatan: ini versi sederhana untuk belajar. Saldo dicatat **1:1** (tanpa
> perhitungan _shares_, bunga, atau yield). Fokusnya: memahami kontrak ERC20,
> Vault, dan pola interaksi antar-kontrak.

---

## 📖 Alur yang kita bangun

```
                approve(vault, 100)              deposit(100)
   ┌──────────┐ ─────────────────────►  ┌──────────┐ ───────────►  ┌──────────┐
   │  PESERTA │  "Vault, kamu boleh      │   token  │  Vault tarik  │  VAULT   │
   │ (dompet) │   ambil 100 token-ku"    │  (ERC20) │  via          │ saldo:   │
   │          │ ◄─────────────────────   │          │  transferFrom │  100     │
   └──────────┘        withdraw(100)     └──────────┘ ◄───────────  └──────────┘
                  Vault kirim token balik
```

Dua langkah saat menabung itu (**approve** lalu **deposit**) adalah pola paling
inti di web3: sebuah kontrak tidak boleh mengambil token kita tanpa izin. Kita
beri izin dulu (`approve`), baru kontrak menariknya (`transferFrom`).

---

## ✅ Prasyarat

1. **Foundry** (forge, cast, anvil). Cek apakah sudah terpasang:
   ```bash
   forge --version
   ```
   Kalau belum:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```
2. **Git** (untuk mengambil dependensi OpenZeppelin).

---

## 🚀 Setup proyek

Kalau kamu **meng-clone** repo ini, ambil dependensinya (forge-std & OpenZeppelin):
```bash
git submodule update --init --recursive
```

Kalau kamu **memulai dari nol** (code-along), beginilah cara memasang OpenZeppelin:
```bash
forge install OpenZeppelin/openzeppelin-contracts@v5.6.1
```
Lalu pastikan ada baris remapping ini di `foundry.toml` agar `import` OpenZeppelin
ketemu:
```toml
remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
    "forge-std/=lib/forge-std/src/",
]
```

Kompilasi untuk memastikan semua siap:
```bash
forge build
```

---

## 📁 Struktur proyek

```
.
├── src/
│   ├── RupiahToken.sol   # Token ERC20 (uang)
│   └── Vault.sol         # Tabungan / celengan
├── test/
│   ├── RupiahToken.t.sol # Test token
│   └── Vault.t.sol       # Test vault (deposit, withdraw, kasus gagal)
├── script/
│   └── Deploy.s.sol      # Script untuk men-deploy kedua kontrak
├── foundry.toml          # Konfigurasi Foundry + remappings
└── .env.example          # Contoh variabel lingkungan (untuk deploy ke testnet)
```

---

## 🧑‍🏫 Urutan untuk code-along

Saat workshop, bangun secara bertahap dengan urutan ini:

1. **`src/RupiahToken.sol`** — kenalkan ERC20: apa itu token, kenapa kita
   mewarisi dari OpenZeppelin, apa itu `mint`, dan kenapa dibatasi `onlyOwner`.
2. **`forge build`** — pastikan token kompilasi.
3. **`src/Vault.sol`** — bahas `mapping` saldo, `deposit` (approve → transferFrom),
   `withdraw` (pola Checks-Effects-Interactions), dan `event`.
4. **`test/*.t.sol`** — tunjukkan cara menguji tanpa perlu jaringan: `forge test`.
5. **Demo langsung** dengan `anvil` + `cast` (lihat di bawah).
6. (Opsional) **Deploy ke Sepolia**.

---

## 🧠 Konsep web3 yang muncul di kode

| Konsep | Di mana | Penjelasan singkat |
|---|---|---|
| `msg.sender` | di mana-mana | Alamat yang memanggil fungsi (si pengirim transaksi). |
| ERC20 | `RupiahToken.sol` | Standar token: `balanceOf`, `transfer`, `approve`, `allowance`, `transferFrom`. |
| 18 desimal | `RupiahToken.sol` | 1 token = `10**18` unit terkecil (sama seperti ETH ke wei). |
| `onlyOwner` | `mint()` | Access control: hanya pemilik kontrak yang boleh memanggil. |
| `approve` + `transferFrom` | `deposit()` | Pola izin: user mengizinkan kontrak menarik tokennya. |
| `mapping` | `Vault.balances` | Struktur data alamat → saldo. |
| `event` | `Deposited`, `Withdrawn` | "Log" yang dipancarkan kontrak; dibaca aplikasi luar. |
| Checks-Effects-Interactions | `withdraw()` | Pola urutan aman untuk mencegah reentrancy. |
| `immutable` | `Vault.token` | Variabel yang di-set sekali di constructor, hemat gas. |

---

## 🧪 Build & Test

```bash
forge build          # kompilasi semua kontrak
forge test           # jalankan semua test
forge test -vvv      # dengan detail (berguna saat debugging)
forge test --gas-report   # plus laporan pemakaian gas
```

---

## 🎬 Demo lokal dengan anvil + cast

`anvil` adalah blockchain Ethereum lokal untuk testing (cepat & gratis).

### 1. Jalankan anvil (terminal terpisah)
```bash
anvil
```
Anvil mencetak 10 akun + private key-nya. Kita pakai **Account 0**.
Alamatnya: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`.
Salin **private key Account 0** dari output anvil, lalu di terminal kerja:
```bash
export PK=<private-key-Account-0-dari-output-anvil>
export RPC=http://localhost:8545
export ME=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

### 2. Deploy kedua kontrak
```bash
forge script script/Deploy.s.sol --rpc-url $RPC --private-key $PK --broadcast
```
Catat alamat yang dicetak, lalu simpan ke variabel:
```bash
export TOKEN=<alamat-RupiahToken>
export VAULT=<alamat-Vault>
```

### 3. Cek saldo token awal (harusnya 1.000.000 IDRT)
```bash
cast call $TOKEN "balanceOf(address)(uint256)" $ME --rpc-url $RPC
```
> Angkanya besar karena 18 desimal. Untuk membaca versi "manusia":
> `cast from-wei <angka>` → mis. `1000000` token.

### 4. Approve: izinkan Vault menarik 100 token
```bash
# 100 IDRT = 100 * 10^18. Pakai `cast to-wei 100` agar tak perlu hitung nol.
cast send $TOKEN "approve(address,uint256)" $VAULT $(cast to-wei 100) \
  --rpc-url $RPC --private-key $PK
```

### 5. Deposit 100 token ke Vault
```bash
cast send $VAULT "deposit(uint256)" $(cast to-wei 100) \
  --rpc-url $RPC --private-key $PK
```

### 6. Cek saldo tabungan di Vault
```bash
cast call $VAULT "balances(address)(uint256)" $ME --rpc-url $RPC
# → 100000000000000000000  (= 100 IDRT)
```

### 7. Withdraw 40 token
```bash
cast send $VAULT "withdraw(uint256)" $(cast to-wei 40) \
  --rpc-url $RPC --private-key $PK

cast call $VAULT "balances(address)(uint256)" $ME --rpc-url $RPC
# → 60000000000000000000  (= 60 IDRT tersisa)
```

> **Coba minta peserta:** jalankan langkah 4–7 dengan **Account 1** anvil dan
> buktikan saldo tabungan tiap orang terpisah.

---

## 🌐 (Opsional) Deploy ke testnet Sepolia

1. Siapkan akun test, isi sedikit Sepolia ETH dari faucet (mis. faucet Alchemy /
   Google Cloud Web3 faucet).
2. Salin env: `cp .env.example .env` lalu isi `SEPOLIA_RPC_URL`, `PRIVATE_KEY`,
   `ETHERSCAN_API_KEY`.
3. Muat env & deploy:
   ```bash
   source .env
   forge script script/Deploy.s.sol \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
   ```

> ⚠️ **JANGAN** memakai private key akun utama / berisi dana asli. Gunakan akun
> khusus testing. Jangan commit file `.env`.

---

## 🔒 Catatan keamanan & apa yang disederhanakan

Versi workshop ini sengaja dibuat minimal. Yang **belum** ada (bagus jadi bahan
diskusi / latihan lanjutan):

- **Tanpa _shares_/bunga/yield** — saldo dicatat 1:1.
- **Mint** bisa dipanggil owner kapan saja — di produksi perlu kebijakan suplai
  yang jelas (capped supply, dll).
- **Tanpa `ReentrancyGuard`** — kita mengandalkan pola Checks-Effects-Interactions.
  Token kita sendiri "jinak", tapi untuk token sembarang sebaiknya pakai
  `nonReentrant` dan/atau `SafeERC20`.
- **Tanpa fitur pause / upgrade / batas waktu**.

---

## 📚 Referensi

- Foundry Book: <https://book.getfoundry.sh>
- OpenZeppelin Contracts: <https://docs.openzeppelin.com/contracts/5.x/>
- Standar ERC20 (EIP-20): <https://eips.ethereum.org/EIPS/eip-20>
