import { DefaultEscrow } from "../modules/ESCRW.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";

pragma solidity ^0.8.15;

contract Verifier is Policy {
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
        requests[0] = Permissions(toKeycode("ESCRW"), ESCRW.executeCallFromStack.selector);
    }

    modifier onlyVerifier(bytes32 userId) {
        require(msg.sender == ESCRW.getVerifierForUserId(userId), "Delegator: not delegate");
        _;
    }

    function executeCallFromStack(bytes32 userId) external onlyVerifier(userId) {
        ESCRW.executeCallFromStack(userId);
    }
}
