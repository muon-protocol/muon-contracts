// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./MuonClient.sol";

/**
 * Example of an Immutable MuonApp.
 * 
 * MuonApp:
 * https://github.com/muon-protocol/muon-apps/blob/master/general/immutable_app_sample.js 
 */
contract ImmutableClientExample is MuonClient {
    using ECDSA for bytes32;

    // appCID is the content ID of the MuonApp.
    // Immutable apps can sign the appCID
    // and verify it on-chain.
    // When the content of the Muon app changes, the appCID
    // will change and the signatures will be invalid
    bytes public muonAppCID;

    // initialize
    // bytes public muonAppCID = hex"516d516a6446776f5168795a3579385545525466597968376d74346f41737644506f324a68764e4e577137723735";

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
