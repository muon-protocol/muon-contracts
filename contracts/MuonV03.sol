// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/SchnorrSECP256K1Verifier.sol";

contract MuonV03 is Ownable, SchnorrSECP256K1Verifier {

    event Transaction(bytes reqId, address[] groups);

    struct PublicKey {
        uint256 x;
        uint8 parity;
    }

    struct SchnorrSign {
        uint256 signature;
        address owner;
        address nonce;
    }

    mapping(address => PublicKey) public groupsPubKey;

    constructor(address _groupAddress, uint256 _groupPubKeyX, uint8 _groupPubKeyYParity){
        addGroupPublicKey(_groupAddress, _groupPubKeyX, _groupPubKeyYParity);
    }

    function verify(bytes calldata _reqId, uint256 _hash, SchnorrSign[] calldata _sigs) public returns (bool) 
    {
        require(_sigs.length > 0, '!_sigs');

        PublicKey memory pub;
        address[] memory groups = new address[](_sigs.length);
        for(uint i=0 ; i<_sigs.length; i++){
            pub = groupsPubKey[_sigs[i].owner];
            if(pub.x == 0)
                return false;
            if(!verifySignature(pub.x, pub.parity, _sigs[i].signature, _hash, _sigs[i].nonce) || (i>0 && _sigs[i].owner <= groups[i-1]))
                return false;
            groups[i] = _sigs[i].owner;
        }
        emit Transaction(_reqId, groups);
        return true;
    }

    function addGroupPublicKey(address _address, uint256 _pubX, uint8 _pubYParity) public onlyOwner {
        validatePubKey(_pubX);
        groupsPubKey[_address] = PublicKey(_pubX, _pubYParity);
    }

    function removeGroupPublicKey(address _groupAddress) public onlyOwner {
        delete groupsPubKey[_groupAddress];
    }
}
