// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMuonV04.sol";

contract MuonV04ClientBase {

    uint256 public muonAppId;

    IMuonV04 public muon;

    IMuonV04.PublicKey public muonPublicKey;
}
