// SPDX-License-Identifier: AGPL-3.0-only

// The Administration Policy manages clients and their respective permissions.

import { DefaultRegistry } from "../modules/RSTRY.sol";
import { DefaultHardwareStack } from "../modules/STACK.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";

pragma solidity ^0.8.15;

interface ICypher {
    event CallAddedToStack(
        bytes32 indexed userId,
        address indexed caller,
        bytes4 funcSelector,
        bytes data,
        uint256 value
    );

    error UnregisteredUser();
    error NotAdmin();
}

contract Admin is Policy, ICypher {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////

    DefaultHardwareStack public STACK;
    DefaultRegistry public RSTRY;

    constructor(Kernel kernel_, address admin_) Policy(kernel_) {
        admin = admin_;
    }

    function configureDependencies()
        external
        override
        onlyKernel
        returns (Keycode[] memory dependencies)
    {
        dependencies = new Keycode[](2);

        dependencies[0] = toKeycode("STACK");
        dependencies[1] = toKeycode("RSTRY");
        STACK = DefaultHardwareStack(getModuleAddress(toKeycode("STACK")));
        RSTRY = DefaultRegistry(getModuleAddress(toKeycode("RSTRY")));
    }

    function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](2);
        requests[0] = Permissions(toKeycode("RSTRY"), RSTRY.registerUser.selector);
        requests[1] = Permissions(toKeycode("RSTRY"), RSTRY.assignVerifierToUser.selector);
    }

    /////////////////////////////////////////////////////////////////////////////////
    //                             Policy Variables                                //
    /////////////////////////////////////////////////////////////////////////////////

    address public admin;

    /////////////////////////////////////////////////////////////////////////////////
    //                               User Actions                                  //
    /////////////////////////////////////////////////////////////////////////////////

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    function registerUser(
        address user,
        string memory name,
        address verifier
    ) external onlyAdmin returns (bytes32 userId) {
        userId = RSTRY.registerUser(user, name);
        RSTRY.assignVerifierToUser(userId, verifier);
    }
}
