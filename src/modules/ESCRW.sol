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

    mapping(bytes32 => Stack) public getStackForUserId;
    mapping(address => bytes32) public getUserIdForAddress;

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

    function registerUser(address user, string memory name)
        public
        permissioned
        returns (bytes32 id)
    {
        id = _userHash(user, name);
        getUserIdForAddress[user] = id;
    }

    function addCallToStack(
        address caller,
        bytes4 funcSelector,
        bytes calldata data,
        uint256 value
    ) external permissioned {
        bytes32 callHash = _callHash(caller, funcSelector, data, value);

        // contract that the call is coming from (cypher client)
        bytes32 userId = getUserIdForAddress[msg.sender];
        Stack storage stack = getStackForUserId[userId];
        stack.getFunctionForIndex[stack.numExecuted] = callHash;
    }

    /// INTERNAL FUNCTIONS

    /// @notice Returns the encoded data of the call
    /// @param caller The user who made the call
    /// @param funcSelector The 4 byte hash of the function called
    /// @param data Hash of the parameters associated with the call
    /// @param value Additional value used for monitoring
    function _callHash(
        address caller,
        bytes4 funcSelector,
        bytes calldata data,
        uint256 value
    ) internal returns (bytes32 hash) {
        hash = keccak256(abi.encodePacked(caller, funcSelector, data, value));
    }

    function _userHash(address user, string memory name) internal returns (bytes32 hash) {
        hash = keccak256(abi.encodePacked(user, name));
    }
}
