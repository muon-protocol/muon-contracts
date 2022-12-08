// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./MuonClient.sol";

contract MuonClientExample is MuonClient {
    using ECDSA for bytes32;

    bytes public muonAppCID;

    constructor(
        uint256 _muonAppId,
        PublicKey memory _muonPublicKey,
        bytes memory _muonAppCID
    ) MuonClient(_muonAppId, _muonPublicKey){
        muonAppCID = _muonAppCID;
    }

    function testFunction(
        uint256 testParam,
        bytes calldata reqId,
        bytes calldata appCID,
        SchnorrSign calldata sign
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                muonAppId,
                reqId,
                appCID,
                testParam
            )
        );
        bool verified = muonVerify(reqId, uint256(hash), sign, muonPublicKey);
        require(verified, "TSS not verified");
    }
}
