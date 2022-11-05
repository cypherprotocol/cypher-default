// SPDX-License-Identifier: AGPL-3.0-only
// Proxy Bonds are a modified gradual dutch auction mechanism for protocols to sell their native tokens.

pragma solidity ^0.8.15;

import { Router } from "src/policies/Router.sol";

contract Cypher {
    Router public router;

    constructor(address _router) {
        router = Router(_router);
    }

    modifier withCypherPayable() {
        router.stashCall(msg.sender, msg.sig, msg.data, msg.value);
        _;
    }

    modifier withCypher() {
        router.stashCall(msg.sender, msg.sig, msg.data, 0);
        _;
    }
}
