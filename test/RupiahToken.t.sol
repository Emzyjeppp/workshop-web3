// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/RupiahToken.sol";

contract RupiahTokenTest is Test {
    RupiahToken public token;

    // Kita pakai address(this) sebagai owner sejati agar tidak bentrok dengan context Forge
    address public owner;
    address public hacker = address(0x999);
    address public user = address(0x1);

    function setUp() public {
        owner = address(this);
        token = new RupiahToken();
    }

    function testInitialSupply() public view {
        assertEq(token.name(), "Rupiah Token");
        assertEq(token.balanceOf(owner), 1000000 * 10 ** token.decimals());
    }

    function testMintAsOwner() public {
        // Karena owner adalah kontrak ini sendiri, panggil LANGSUNG tanpa vm.prank
        token.mint(user, 500 * 10 ** token.decimals());
        assertEq(token.balanceOf(user), 500 * 10 ** token.decimals());
    }

    function testMintAsNonOwnerFail() public {
        uint256 amount = 100 * 10 ** token.decimals();

        // 1. vm.prank sets msg.sender for the next external call
        vm.prank(hacker);

        // 2. vm.expectRevert expects the next external call to revert with OwnableUnauthorizedAccount
        vm.expectRevert(abi.encodeWithSelector(RupiahToken.OwnableUnauthorizedAccount.selector, hacker));

        // 3. Panggil fungsi yang akan gagal
        token.mint(user, amount);
    }
}
