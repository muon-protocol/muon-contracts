// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMuonV03.sol";

contract MuonPVRBExample {
    // muon_pvrb
    uint256 public APP_ID = 0x129a3351aa5c98c426ec09668f9873fc482f69bf8540b2a6a72fcbf12440fecd;

    IMuonV03 muon;

    uint256 randomState = 1234; // initial state

    constructor(address _muon){
        muon = IMuonV03(_muon);
    }

    function updateState(
        bytes calldata reqId,
        IMuonV03.SchnorrSign[] calldata signs
    ) public{
        bytes32 hash = keccak256(
            abi.encodePacked(
                APP_ID,
                reqId,
                randomState // previous random
            )
        );
        bool verified = muon.verify(reqId, uint256(hash), signs);
        require(verified, "TSS not verified");

        // new random
        // drives from the TSS
        randomState = signs[0].signature;
    }
}
