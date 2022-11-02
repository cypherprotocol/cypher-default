// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { Kernel, Module, Keycode, Instruction, Actions } from "src/Kernel.sol";

interface IDefaultEscrow {}

contract DefaultEscrow is Module, IDefaultEscrow {
    /// CONSTRUCTOR
    constructor(Kernel kernel_) Module(kernel_) {}

    function KEYCODE() public pure override returns (Keycode) {
        return Keycode.wrap("ESCRW");
    }

    /// VARIABLES

    struct Stack {
        mapping(uint256 => bytes32) getFunctionForIndex;
        uint256 numExecuted;
    }

    mapping(bytes32 => CallStack) public getCallstackForUser;
    mapping(address => bytes32) public getUserIdForAddress;

    /// POLICY INTERFACE

    function registerUser(address user, string memory name) {
        getUserIdForAddress[user] = _userHash(user, name);
    }

    function addCallToStack(
        address caller,
        bytes32 funcSelector,
        bytes32 data,
        uint256 value
    ) external permissioned {
        bytes32 callHash = _callHash(caller, funcSelector, data, value);
    }

    /// INTERNAL FUNCTIONS

    /// @notice Returns the encoded hash of the call
    /// @param caller The user who made the call
    /// @param funcSelector The 4 byte hash of the function called
    /// @param data Hash of the parameters associated with the call
    /// @param value Additional value used for monitoring
    function _callHash(
        address caller,
        bytes32 funcSelector,
        bytes32 data,
        uint256 value
    ) internal returns (bytes32 hash) {
        hash = keccak256(abi.encodeWithSignature(caller, funcSelector, data, value));
    }

    function _userHash(address user, string memory name) returns (bytes32 hash) {
        hash = keccak256(abi.encodePacked(user, name));
    }
}
