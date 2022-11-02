// SPDX-License-Identifier: AGPL-3.0-only
// Proxy Bonds are a modified gradual dutch auction mechanism for protocols to sell their native tokens.

import { ERC721 } from "solmate/tokens/ERC721.sol";
import { DefaultVotes } from "../modules/VOTES.sol";
import { DefaultTreasury } from "../modules/TRSRY.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";

pragma solidity ^0.8.15;

contract Cypher {
    modifier withCypher() {
        _;
    }

    modifier withCypherPayable() {
        _;
    }
}

contract Pod is Policy, ERC721, Cypher {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////

    DefaultEscrow public ESCRW;

    constructor(Kernel kernel_) Policy(kernel_) ERC721("Cypher", "CYPHR") {}

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

    /////////////////////////////////////////////////////////////////////////////////
    //                                Policy Variables                             //
    /////////////////////////////////////////////////////////////////////////////////

    uint256 public constant MAX_SUPPLY = 10000;

    uint256 public constant RESERVED_SUPPLY = 10000 / 5;

    string public UNREVEALED_URI;

    string public BASE_URI;

    /////////////////////////////////////////////////////////////////////////////////
    //                              View Functions                                 //
    /////////////////////////////////////////////////////////////////////////////////

    function claimCypher(bytes32[] calldata proof) external withCypher returns (uint256 cypherId) {}
}
