// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/SafeTestTools.sol";

contract DeploySafeScript is Script, SafeTestTools {
    function setUp() public {}

    function run() public {
        // Load config
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config/safe-config.json");
        string memory json = vm.readFile(path);
        address[] memory owners = abi.decode(vm.parseJson(json, ".owners"), (address[]));
        uint256 threshold = abi.decode(vm.parseJson(json, ".threshold"), (uint256));

        // Convert addresses to "smart contract PKs" for SafeTestTools
        uint256[] memory ownerPKs = new uint256[](owners.length);
        for (uint256 i = 0; i < owners.length; i++) {
            // Encode address as special "smart contract PK"
            ownerPKs[i] = uint256(keccak256(abi.encodePacked("SMART_CONTRACT_WALLET", owners[i])));
        }

        // Start broadcasting
        vm.broadcast();

        // Deploy Safe with minimal configuration
        SafeInstance memory safe = _setupSafe(
            ownerPKs,
            threshold,
            0, // No initial balance
            AdvancedSafeInitParams({
                includeFallbackHandler: true,
                initData: "",
                saltNonce: 0,
                setupModulesCall_to: address(0),
                setupModulesCall_data: "",
                refundAmount: 0,
                refundToken: address(0),
                refundReceiver: payable(address(0))
            })
        );

        console.log("Safe deployed at:", address(safe.safe));
        console.log("Owners:");
        for (uint256 i = 0; i < safe.owners.length; i++) {
            console.log("  ", safe.owners[i]);
        }
        console.log("Threshold:", safe.threshold);
    }
} 