// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    // State variable untuk menyimpan alamat token ERC20 yang diterima
    IERC20 public immutable token;

    // 1. Mapping Saldo: Mencatat berapa banyak token yang disimpan oleh tiap user
    mapping(address => uint256) public balances;

    // Event untuk memberikan notifikasi ke aplikasi luar (frontend/graph)
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    // 2. Deposit (Approve -> TransferFrom)
    // User HARUS memanggil fungsi `approve` dulu di kontrak token sebelum memanggil fungsi ini
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Jumlah deposit harus lebih dari 0");

        // Memindahkan token dari dompet user ke kontrak Vault ini
        // Mengembalikan nilai boolean sukses/gagal
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer token gagal");

        // Menambahkan catatan saldo user di dalam Vault
        balances[msg.sender] += _amount;

        emit Deposited(msg.sender, _amount);
    }

    // 3. Withdraw dengan pola Checks-Effects-Interactions (CEI)
    // Pola ini sangat krusial untuk mencegah serangan Reentrancy (peretasan dana dikuras habis)
    function withdraw(uint256 _amount) external {
        // [CHECKS] - Validasi kondisi awal
        require(balances[msg.sender] >= _amount, "Saldo tidak mencukupi");

        // [EFFECTS] - Mengubah state internal kontrak DULU sebelum mengirim token keluar
        balances[msg.sender] -= _amount;

        // [INTERACTIONS] - Berinteraksi dengan kontrak luar (kirim token ke user)
        bool success = token.transfer(msg.sender, _amount);
        require(success, "Transfer token gagal");

        emit Withdrawn(msg.sender, _amount);
    }
}
