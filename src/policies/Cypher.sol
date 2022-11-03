import { DefaultEscrow } from "../modules/ESCRW.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";

pragma solidity ^0.8.15;

contract Cypher is Policy {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////

    DefaultEscrow public ESCRW;

    constructor(Kernel kernel_) Policy(kernel_) {}

    function configureDependencies()
        external
        override
        onlyKernel
        returns (Keycode[] memory dependencies)
    {
        dependencies = new Keycode[](1);

        dependencies[0] = toKeycode("ESCRW");
        ESCRW = DefaultEscrow(getModuleAddress(toKeycode("ESCRW")));
    }

    function requestPermissions()
        external
        view
        override
        onlyKernel
        returns (Permissions[] memory requests)
    {
        requests = new Permissions[](1);
        requests[0] = Permissions(toKeycode("ESCRW"), ESCRW.addCallToStack.selector);
    }

    modifier withCypher() {
        ESCRW.addCallToStack(msg.sender, msg.sig, msg.data, 0);
        _;
    }

    modifier withCypherPayable() {
        ESCRW.addCallToStack(msg.sender, msg.sig, msg.data, msg.value);
        _;
    }
}
