// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMuonV03.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MuonV03Example {
    using ECDSA for bytes32;

    uint32 public APP_ID = 0x2031768f;

    IMuonV03 muon;

    // The apps can run their own gateway and 
    // accept the transactions that is started by the gateway.
    address validGateway = msg.sender; // by default

    constructor(address _muon){
        muon = IMuonV03(_muon);
    }

    function verifyTSS(
        uint256 testParam,
        bytes calldata reqId,
        IMuonV03.SchnorrSign[] calldata signs
    ) public{
        bytes32 hash = keccak256(
            abi.encodePacked(
                APP_ID,
                reqId, // reqId is determinstic on MuonV3 and 
                // could be in the signature
                testParam
            )
        );
        bool verified = muon.verify(reqId, uint256(hash), signs);
        require(verified, "TSS not verified");
    }

    // To get the gatewaySignature,
    // gwSign=true should be passed to the
    // MuonApp.
    function verifyTSSAndGateway(
        uint256 testParam,
        bytes calldata reqId,
        IMuonV03.SchnorrSign[] calldata signs,
        bytes calldata gatewaySignature
    ) public {
        bytes32 hash = keccak256(
            abi.encodePacked(
                APP_ID,
                reqId,
                testParam
            )
        );
        bool verified = muon.verify(reqId, uint256(hash), signs);
        require(verified, "TSS not verified");

        hash = hash.toEthSignedMessageHash();
        address gatewaySignatureSigner = hash.recover(gatewaySignature);

        require(gatewaySignatureSigner == validGateway, "Gateway is not valid");

        // will be supported later
        // require(MuonNodeManager(addr).isMasterNode(gatewaySignature), "Not signed by a master node");
    }
}
