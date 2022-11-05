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
}

contract Cypher is Policy, ICypher {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////

    DefaultHardwareStack public STACK;
    DefaultRegistry public RSTRY;

    constructor(Kernel kernel_) Policy(kernel_) {}

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
        requests = new Permissions[](1);
        requests[0] = Permissions(toKeycode("STACK"), STACK.addCallToStack.selector);
    }

    modifier withCypher() {
        STACK.addCallToStack(
            RSTRY.getUserIdForAddress(address(this)),
            msg.sender,
            msg.sig,
            msg.data,
            0
        );
        emit CallAddedToStack(
            RSTRY.getUserIdForAddress(address(this)),
            msg.sender,
            msg.sig,
            msg.data,
            0
        );
        _;
    }

    modifier withCypherPayable() {
        STACK.addCallToStack(
            RSTRY.getUserIdForAddress(address(this)),
            msg.sender,
            msg.sig,
            msg.data,
            msg.value
        );
        emit CallAddedToStack(
            RSTRY.getUserIdForAddress(address(this)),
            msg.sender,
            msg.sig,
            msg.data,
            msg.value
        );
        _;
    }
}
