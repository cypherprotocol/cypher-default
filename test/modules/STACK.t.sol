// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "src/Kernel.sol";
import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { UserFactory } from "test-utils/UserFactory.sol";

import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { Kernel, Actions } from "src/Kernel.sol";
import { DefaultHardwareStack } from "src/modules/STACK.sol";

import "../lib/ModuleTestFixtureGenerator.sol";

contract DefaultStackTest is Test {
    using ModuleTestFixtureGenerator for DefaultHardwareStack;

    Kernel internal kernel;

    DefaultHardwareStack internal STACK;

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
        STACK = new DefaultHardwareStack(kernel);

        // generate godmode address
        godmode = STACK.generateGodmodeFixture(type(DefaultHardwareStack).name);

        // set up kernel
        kernel.executeAction(Actions.InstallModule, address(STACK));
        kernel.executeAction(Actions.ActivatePolicy, godmode);
    }

    function testCorrect_AddCallToStackTest() public {
        vm.startPrank(godmode);
        STACK.addCallToStack("", user1, bytes4(keccak256(bytes("testFunction()"))), "", 0);
        assertEq(
            STACK.getFunctionFromStack("", 0),
            keccak256(
                abi.encodePacked(user1, bytes4(keccak256(bytes("testFunction()"))), "", uint256(0))
            )
        );
    }
}
