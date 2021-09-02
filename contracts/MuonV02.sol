// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SchnorrSECP256K1.sol";

contract MuonV02 is Ownable {

    event Transaction(bytes reqId);

    SchnorrSECP256K1 schnorr;

    uint256 pubKeyX;
    uint8 pubKeyYParity;

    constructor(address _schnorrLib, uint256 _masterKeyPubX, uint8 _masterKeyPubYParity){
        pubKeyX = _masterKeyPubX;
        pubKeyYParity = _masterKeyPubYParity;
        schnorr = SchnorrSECP256K1(_schnorrLib);
    }

    function verify(bytes calldata _reqId, uint256 _hash, uint256 _sig, address _nonce) public returns (bool) {
        if(schnorr.verifySignature(pubKeyX, pubKeyYParity, _sig, _hash, _nonce)){
            emit Transaction(_reqId);
            return true;
        }
        else{
            return false;
        }
    }

    function setMasterKeyPublic(uint256 _pubX, uint8 _pubYParity) public onlyOwner {
        pubKeyX = _pubX;
        pubKeyYParity = _pubYParity;
    }

    function setLibAddress(address _schnorrLib) public onlyOwner {
        schnorr = SchnorrSECP256K1(_schnorrLib);
    }
}
