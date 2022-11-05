// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { Kernel, Module, Keycode, Instruction, Actions } from "src/Kernel.sol";

interface IDefaultStack {}

contract DefaultHardwareStack is Module, IDefaultStack {
    /// CONSTRUCTOR
    constructor(Kernel kernel_) Module(kernel_) {}

    function KEYCODE() public pure override returns (Keycode) {
        return Keycode.wrap("STACK");
    }

    /// VARIABLES

    struct Stack {
        mapping(uint256 => bytes32) getFunctionForIndex;
        uint256 numExecuted;
    }

    mapping(bytes32 => Stack) public getStackForUserId;

    /// POLICY INTERFACE

    function getFunctionFromStack(bytes32 userId, uint256 index) external view returns (bytes32) {
        Stack storage stack = getStackForUserId[userId];
        return stack.getFunctionForIndex[index];
    }

    function executeCallFromStack(bytes32 userId)
        public
        permissioned
        returns (uint256 functionIndex)
    {
        Stack storage stack = getStackForUserId[userId];
    }

    function addCallToStack(
        bytes32 userId,
        address caller,
        bytes4 funcSelector,
        bytes calldata data,
        uint256 value
    ) external permissioned {
        bytes32 callHash = _callHash(caller, funcSelector, data, value);

        Stack storage stack = getStackForUserId[userId];
        stack.getFunctionForIndex[stack.numExecuted] = callHash;
        stack.numExecuted++;
    }

    /// INTERNAL FUNCTIONS

    function _callHash(
        address caller,
        bytes4 funcSelector,
        bytes calldata data,
        uint256 value
    ) internal returns (bytes32 hash) {
        hash = keccak256(abi.encodePacked(caller, funcSelector, data, value));
    }
}
