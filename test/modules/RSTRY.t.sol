// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "src/Kernel.sol";
import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { UserFactory } from "test-utils/UserFactory.sol";

import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { Kernel, Actions } from "src/Kernel.sol";
import { DefaultRegistry } from "src/modules/RSTRY.sol";

import "../lib/ModuleTestFixtureGenerator.sol";

contract DefaultRegistryTest is Test {
    using ModuleTestFixtureGenerator for DefaultRegistry;

    Kernel internal kernel;

    DefaultRegistry internal RSTRY;

    UserFactory internal userFactory;

    address internal godmode;

    address public user1;
    address public user2;
    address public user3;

    function setUp() public {
        // generate test users
        userFactory = new UserFactory();
        address[] memory users = userFactory.create(3);
        user1 = users[0];
        user2 = users[1];
        user3 = users[2];

        // deploy kernel and TRSRY module
        kernel = new Kernel();
        RSTRY = new DefaultRegistry(kernel);

        // generate godmode address
        godmode = RSTRY.generateGodmodeFixture(type(DefaultRegistry).name);

        // set up kernel
        kernel.executeAction(Actions.InstallModule, address(RSTRY));
        kernel.executeAction(Actions.ActivatePolicy, godmode);
    }

    function testCorrect_IsRegistered() public {
        vm.startPrank(godmode);
        RSTRY.registerUser(godmode, "cypher");
        assertEq(
            RSTRY.getUserIdForAddress(godmode),
            keccak256(abi.encodePacked(godmode, "cypher"))
        );
    }

    function testCorrect_AssignVerifier() public {
        vm.startPrank(godmode);
        RSTRY.registerUser(godmode, "cypher");

        RSTRY.assignVerifierToUser(RSTRY.getUserIdForAddress(godmode), user1);
        assertEq(RSTRY.getVerifierForUserId(RSTRY.getUserIdForAddress(godmode)), user1);
    }
}
