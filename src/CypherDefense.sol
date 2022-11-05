// SPDX-License-Identifier: AGPL-3.0-only
// Proxy Bonds are a modified gradual dutch auction mechanism for protocols to sell their native tokens.

pragma solidity ^0.8.15;

import { Cypher } from "src/policies/Cypher.sol";

contract CypherDefense {
    Cypher public cypher;

    constructor(address _cypher) {
        cypher = Cypher(_cypher);
    }

    modifier withCypherPayable() {
        cypher.stashCall(msg.sender, msg.sig, msg.data, msg.value);
        _;
    }

    modifier withCypher() {
        cypher.stashCall(msg.sender, msg.sig, msg.data, 0);
        _;
    }
}
