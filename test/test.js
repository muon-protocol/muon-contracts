var SchnorrLib = artifacts.require('./SchnorrSECP256K1.sol')
const MuonV02 = artifacts.require('MuonV02');
const truffleAssert = require('truffle-assertions');
const {expect, muonNode} = require('./helpers')
const {toBN} = web3.utils;

const pubKeyAddress = process.env.MUON_MASTER_WALLET_PUB_ADDRESS;
const pubKeyX = process.env.MUON_MASTER_WALLET_PUB_X;
const pubKeyYParity = process.env.MUON_MASTER_WALLET_PUB_Y_PARITY;

console.log({pubKeyX, pubKeyYParity})


contract("MuonV02", (accounts) => {
    let owner=accounts[9], muon;

    before(async () => {
        let lib = await SchnorrLib.new({from: owner})
        muon = await MuonV02.new(lib.address, pubKeyAddress, pubKeyX, pubKeyYParity, {from: owner});
    });

    describe("Test TSS verification", async () => {
        it("should verify signature", async () => {
            let muonResponse = await muonNode.request({app: 'tss', method: 'test'})
            let {success, result} = muonResponse
            assert(success === true, 'Muon response failed')
            assert(result.confirmed === true, 'Muon request not confirmed')

            let reqId = `0x${result.cid.substr(1)}`;
            let groupAddress = result.signatures[0].owner;
            let signature = result.signatures[0].signature;
            let nonceAddress = result.data.init.nonceAddress;
            let msgHash = web3.utils.soliditySha3('done')

            let sigs = [{
                signature: signature,
                owner: groupAddress,
                nonce: nonceAddress
            }]
            let verifyResult = await muon.verify(reqId, msgHash, sigs);
            expect.eventEmitted(verifyResult, 'Transaction', (ev) => {
                return ev.reqId == reqId;
            })
        })
    })
});
