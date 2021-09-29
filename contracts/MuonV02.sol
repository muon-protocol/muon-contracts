// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SchnorrSECP256K1.sol";

contract MuonV02 is Ownable {

    event Transaction(bytes reqId, address[] group);

    SchnorrSECP256K1 schnorr;

    struct PublicKey {
        uint256 x;
        uint8 parity;
    }

    mapping(address => PublicKey) public groupsPubKey;

    constructor(address _schnorrLib, address _groupAddress, uint256 _groupPubKeyX, uint8 _groupPubKeyYParity){
        groupsPubKey[_groupAddress] = PublicKey(_groupPubKeyX, _groupPubKeyYParity);
        schnorr = SchnorrSECP256K1(_schnorrLib);
    }

    function verify(
        bytes calldata _reqId, 
        uint256 _hash, 
        uint256[] calldata _sigs, 
        address[] calldata _groupWallets, 
        address[] calldata _nonces
    ) 
        public returns (bool) 
    {
        require(_sigs.length > 0, '!_sigs');
        require(_sigs.length == _groupWallets.length, '!_groupWallets');
        require(_sigs.length == _nonces.length, '!_nonces');

        PublicKey memory pub;
        address lastGroup;
        for(uint i=0 ; i<_sigs.length; i++){
            pub = groupsPubKey[_groupWallets[i]];
            if(!schnorr.verifySignature(pub.x, pub.parity, _sigs[i], _hash, _nonces[i]) || _groupWallets[i] <= lastGroup)
                return false;
            lastGroup = _groupWallets[i];
        }
        emit Transaction(_reqId, _groupWallets);
        return true;
    }

    function addGroupKeyPublic(address _address, uint256 _pubX, uint8 _pubYParity) public onlyOwner {
        groupsPubKey[_address] = PublicKey(_pubX, _pubYParity);
    }

    function removeGroupKeyPublic(address _groupAddress) public onlyOwner {
        delete groupsPubKey[_groupAddress];
    }

    function setLibAddress(address _schnorrLib) public onlyOwner {
        schnorr = SchnorrSECP256K1(_schnorrLib);
    }
}
