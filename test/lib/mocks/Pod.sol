// SPDX-License-Identifier: AGPL-3.0-only
// Proxy Bonds are a modified gradual dutch auction mechanism for protocols to sell their native tokens.

pragma solidity ^0.8.15;

import { ERC721 } from "solmate/tokens/ERC721.sol";
import { CypherDefense } from "../../../src/CypherDefense.sol";
import { Kernel } from "../../../src/Kernel.sol";

contract Pod is ERC721, CypherDefense {
    constructor(address cypher) CypherDefense(cypher) ERC721("Pod", "POD") {}

    uint256 public currentId;

    uint256 public constant MAX_SUPPLY = 10000;

    string public UNREVEALED_URI;

    string public BASE_URI;

    /////////////////////////////////////////////////////////////////////////////////
    //                              View Functions                                 //
    /////////////////////////////////////////////////////////////////////////////////

    function mintOne() external payable withCypherPayable returns (uint256 id) {
        _mint(msg.sender, currentId++);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }

    // function claimCypher(bytes32[] calldata proof) external withCypher returns (uint256 cypherId) {}
}
