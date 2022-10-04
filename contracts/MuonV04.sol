// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/SchnorrSECP256K1Verifier.sol";
import "./interfaces/IMuonV04.sol";

contract MuonV04 is IMuonV04,
    Ownable, SchnorrSECP256K1Verifier {

    function verify(
        bytes calldata reqId,
        uint256 hash, 
        SchnorrSign calldata signature,
        PublicKey calldata pubKey
    ) public override returns (bool) {
        // TODO: need to make sure that pubKey
        // is a Muon TSS key.
        // Now it verifies any valid SchnorrSign
        if(!verifySignature(pubKey.x, pubKey.parity, 
                signature.signature, 
                hash, signature.nonce)){
            return false;
        }
        emit Transaction(reqId, pubKey);
        return true;
    }
}
