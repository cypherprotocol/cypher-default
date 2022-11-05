// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { Kernel, Module, Keycode, Instruction, Actions } from "src/Kernel.sol";

interface IDefaultRegistry {
    error UserAlreadyRegistered();
}

contract DefaultRegistry is Module, IDefaultRegistry {
    /// CONSTRUCTOR
    constructor(Kernel kernel_) Module(kernel_) {}

    function KEYCODE() public pure override returns (Keycode) {
        return Keycode.wrap("RSTRY");
    }

    /// VARIABLES

    mapping(address => bytes32) public getUserIdForAddress;
    mapping(bytes32 => address) public getApproverForUser;

    /// POLICY INTERFACE

    function registerUser(address user, string memory name)
        public
        permissioned
        returns (bytes32 id)
    {
        id = _userHash(user, name);
        if (getUserIdForAddress[id] != address(0)) revert UserAlreadyRegistered();
        getUserIdForAddress[user] = id;
    }

    function assignApproverForUser(bytes32 userId, address approver) public permissioned {
        getApproverForUser[userId] = approver;
    }

    /// INTERNAL FUNCTIONS

    function _userHash(address user, string memory name) internal returns (bytes32 hash) {
        hash = keccak256(abi.encodePacked(user, name));
    }
}
