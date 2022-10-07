// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MuonV04ClientBase.sol";

contract MuonV04Client is MuonV04ClientBase {

    constructor(
        uint256 _muonAppId,
        PublicKey memory _muonPublicKey
    ){
        muonAppId = _muonAppId;
        muonPublicKey = _muonPublicKey;
    }
}
