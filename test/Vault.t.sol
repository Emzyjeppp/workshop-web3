// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/RupiahToken.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    RupiahToken public token;
    Vault public vault;
    address public user = address(0x1);
    uint256 public amount = 1000 * 10 ** 18;

    function setUp() public {
        token = new RupiahToken();
        vault = new Vault(address(token));

        // Berikan token ke user untuk modal testing dan pindah aset
        token.mint(user, amount);
    }

    // Uji alur deposit (Approve -> Deposit)
    function testDeposit() public {
        vm.startPrank(user); // Mulai bertindak sebagai 'user'

        token.approve(address(vault), amount); // 1. Beri izin vault ambil token
        vault.deposit(amount); // 2. Lakukan deposit

        vm.stopPrank();

        assertEq(vault.balances(user), amount);
        assertEq(token.balanceOf(address(vault)), amount);
    }

    // Uji alur withdraw (Deposit -> Withdraw)
    function testWithdraw() public {
        vm.startPrank(user);

        token.approve(address(vault), amount);
        vault.deposit(amount);

        // Lakukan penarikan setengah saldo
        uint256 withdrawAmount = amount / 2;
        vault.withdraw(withdrawAmount);

        vm.stopPrank();

        assertEq(vault.balances(user), amount - withdrawAmount);
        assertEq(token.balanceOf(user), withdrawAmount);
    }
}
