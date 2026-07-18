// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/RupiahToken.sol";
import "../src/Vault.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Deploy RupiahToken
        RupiahToken token = new RupiahToken();
        
        // 2. Deploy Vault dengan alamat token yang baru saja dideploy
        Vault vault = new Vault(address(token));

        vm.stopBroadcast();
    }
}
