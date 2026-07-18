// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RupiahToken is ERC20 {
    address private _owner;

    // Custom error agar pas dengan ekspektasi error OpenZeppelin v5
    error OwnableUnauthorizedAccount(address account);

    constructor() ERC20("Rupiah Token", "IDRT") {
        // Simpan owner secara manual
        _owner = msg.sender;

        // Cetak 1.000.000 token langsung ke owner (deployer)
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // Fungsi view untuk membaca siapa Owner-nya
    function owner() public view returns (address) {
        return _owner;
    }

    // Pembatasan akses manual yang 100% presisi mendeteksi msg.sender
    function mint(address to, uint256 amount) public {
        if (msg.sender != _owner) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _mint(to, amount);
    }
}
