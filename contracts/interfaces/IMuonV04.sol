// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IMuonV04 {
    struct SchnorrSign {
        uint256 signature;
        address owner;
        address nonce;
    }

    struct PublicKey {
        uint256 x;
        uint8 parity;
    }

    event Transaction(bytes reqId, PublicKey pubKey);

    function verify(
        bytes calldata reqId,
        uint256 hash,
        SchnorrSign calldata signature,
        PublicKey calldata pubKey
    ) external returns (bool);
}
