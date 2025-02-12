// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../script/DeploySafe.s.sol";

contract DeploySafeTest is Test {
    DeploySafeScript public deployer;

    function setUp() public {
        // Create test addresses for config
        address owner1 = makeAddr("owner1");
        address owner2 = makeAddr("owner2");
        address owner3 = makeAddr("owner3");

        // Create config file with test addresses
        string memory config = string.concat(
            '{"owners": ["',
            vm.toString(owner1),
            '","',
            vm.toString(owner2),
            '","',
            vm.toString(owner3),
            '"],"threshold": 2,"network": "sepolia"}'
        );

        // Write config to file
        vm.writeFile("config/safe-config.json", config);

        // Setup deployer
        deployer = new DeploySafeScript();
    }

    function test_DeploySafe() public {
        // Run deployment
        deployer.run();

        // Get the deployed safe instance
        SafeInstance memory safe = deployer.getSafe();
        
        // Verify basic setup
        assertEq(safe.threshold, 2, "Threshold should be 2");
        assertEq(safe.owners.length, 3, "Should have 3 owners");
        
        // Verify the safe was properly initialized
        assertTrue(address(safe.safe) != address(0), "Safe should be deployed");
    }
} 