// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MuonV04ClientBase.sol";

contract MuonV04Client is MuonV04ClientBase {

    constructor(
        address muonAddress, 
        uint256 _muonAppId,
        IMuonV04.PublicKey memory _muonPublicKey
    ){
        muon = IMuonV04(muonAddress);
        muonAppId = _muonAppId;
        muonPublicKey = _muonPublicKey;
    }
}
