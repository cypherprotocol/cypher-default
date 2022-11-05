// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "src/Kernel.sol";

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { UserFactory } from "test-utils/UserFactory.sol";

import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { DefaultRegistry } from "src/modules/RSTRY.sol";
import { DefaultHardwareStack } from "src/modules/STACK.sol";
import { IVerifier, Verifier } from "src/policies/Verifier.sol";

import "../lib/ModuleTestFixtureGenerator.sol";

contract VerifierTest is Test {
    using ModuleTestFixtureGenerator for DefaultRegistry;
    using ModuleTestFixtureGenerator for DefaultHardwareStack;

    // kernel
    Kernel internal kernel;

    // modules
    DefaultRegistry internal RSTRY;
    DefaultHardwareStack internal STACK;

    // policies
    Verifier internal verifier;

    MockERC20 internal DAI;

    UserFactory public userFactory;
    address public user1;
    address public user2;
    address public user3;

    address internal registryGod;
    address internal stackGod;

    bytes public err;

    function setUp() public {
        userFactory = new UserFactory();
        address[] memory users = userFactory.create(3);
        user1 = users[0];
        user2 = users[1];
        user3 = users[2];

        // deploy default kernel
        kernel = new Kernel();

        // deploy modules
        // DAI = new MockERC20("DAI", "DAI", 18);
        // ERC20[] memory approvedTokens = new ERC20[](1);
        // approvedTokens[0] = ERC20(DAI);
        RSTRY = new DefaultRegistry(kernel);

        STACK = new DefaultHardwareStack(kernel);

        // deploy redemption
        verifier = new Verifier(kernel);
        // pod = new Pod(kernel);

        // generate fixtures
        registryGod = RSTRY.generateGodmodeFixture(type(DefaultRegistry).name);
        stackGod = STACK.generateGodmodeFixture(type(DefaultHardwareStack).name);

        // set up kernel
        kernel.executeAction(Actions.InstallModule, address(RSTRY));
        kernel.executeAction(Actions.InstallModule, address(STACK));
        kernel.executeAction(Actions.ActivatePolicy, address(verifier));
        kernel.executeAction(Actions.ActivatePolicy, address(registryGod));
        kernel.executeAction(Actions.ActivatePolicy, address(stackGod));

        // mint a mil to TRSRY
        // DAI.mint(address(TRSRY), 1_000_000 * 1e18);

        // mint to users
        // 1 vote backed by 1000 dai
        // vm.startPrank(voteGod);
        // VOTES.mintTo(user1, 200 * 1e3); // 20% of TRSRY
        // VOTES.mintTo(user2, 200 * 1e3); // 20% of TRSRY
        // VOTES.mintTo(user3, 600 * 1e3); // 60% of TRSRY
        // vm.stopPrank();
    }

    function testCorrectness_ExecuteCallAsVerifier() public {
        vm.startPrank(registryGod);
        bytes32 userId = RSTRY.registerUser(user1, "user1");
        RSTRY.assignApproverToUser(RSTRY.getUserIdForAddress(user1), user2));
        vm.stopPrank();

        vm.startPrank(stackGod);
        vm.stopPrank();

        // execute the call
        vm.startPrank(user2);

        vm.stopPrank();
    }

    // function testCorrectness_Redeem_MultiAsset() public {
    //     MockERC20 USDC = new MockERC20("USDC", "USDC", 6);
    //
    //     // mint a mil to TRSRY
    //     vm.prank(treasuryGod);
    //     TRSRY.addReserveAsset(USDC);
    //     USDC.mint(address(TRSRY), 2_000_000 * 1e6);
    //
    //     vm.startPrank(user1);
    //     VOTES.approve(address(TRSRY), VOTES.balanceOf(user1));
    //     redemption.redeem(VOTES.balanceOf(user1));
    //
    //     // current TRSRY total = 1M DAI, 2M USDC
    //     // user1 holds 200k/1M tokens = 20% of TRSRY = 200k DAI, 400k USDC
    //     // redeeming 20% * 95% * (200k DAI, 200k USDC) = 190k DAI, 380k USDC
    //     assertEq(DAI.balanceOf(user1), 190_000 * 1e18);
    //     assertEq(DAI.balanceOf(address(TRSRY)), 810_000 * 1e18);
    //
    //     assertEq(USDC.balanceOf(user1), 380_000 * 1e6);
    //     assertEq(USDC.balanceOf(address(TRSRY)), 1_620_000 * 1e6);
    //     vm.stopPrank();
    // }
}
