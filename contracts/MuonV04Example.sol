// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./MuonV04Client.sol";

contract MuonV04Example is MuonV04Client {
    using ECDSA for bytes32;

    // The apps can run their own gateway and 
    // accept the transactions that is started by the gateway.
    address validGateway = msg.sender; // by default

    constructor(
        uint256 _muonAppId,
        PublicKey memory _muonPublicKey
    ) MuonV04Client(_muonAppId, _muonPublicKey){

    }

    function verifyTSS(
        string calldata data,
        bytes calldata reqId,
        SchnorrSign calldata sign
    ) public{
        bytes32 hash = keccak256(
            abi.encodePacked(
                muonAppId,
                reqId,
                data
            )
        );
        bool verified = muonVerify(reqId, uint256(hash), sign, muonPublicKey);
        require(verified, "TSS not verified");
    }

    // To get the gatewaySignature,
    // gwSign=true should be passed to the
    // MuonApp.
    function verifyTSSAndGateway(
        uint256 testParam,
        bytes calldata reqId,
        SchnorrSign calldata sign,
        bytes calldata gatewaySignature
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                muonAppId,
                reqId,
                testParam
            )
        );
        bool verified = muonVerify(reqId, uint256(hash), sign, muonPublicKey);
        require(verified, "TSS not verified");

        hash = hash.toEthSignedMessageHash();
        address gatewaySignatureSigner = hash.recover(gatewaySignature);

        require(gatewaySignatureSigner == validGateway, "Gateway is not valid");

        // will be supported later
        // require(MuonNodeManager(addr).isMasterNode(gatewaySignature), "Not signed by a master node");
    }
}
