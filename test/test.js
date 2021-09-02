var SchnorrLib = artifacts.require('./SchnorrSECP256K1.sol')
const MuonV02 = artifacts.require('MuonV02');
const truffleAssert = require('truffle-assertions');
const {expect, muonNode} = require('./helpers')
const {toBN} = web3.utils;

const pubKeyX = process.env.MUON_MASTER_WALLET_PUB_X;
const pubKeyYParity = toBN(process.env.MUON_MASTER_WALLET_PUB_Y).mod(toBN(2)).toString();

console.log({pubKeyX, pubKeyYParity})


contract("MuonV02", (accounts) => {
    let owner=accounts[9], muon;

    before(async () => {
        let lib = await SchnorrLib.new({from: owner})
        muon = await MuonV02.new(lib.address, pubKeyX, pubKeyYParity, {from: owner});
    });

    describe("Test TSS verification", async () => {
        it("should verify signature", async () => {
            let muonResponse = await muonNode.request({app: 'tss', method: 'test'})
            let {success, result} = muonResponse
            assert(success === true, 'Muon response failed')
            assert(result.confirmed === true, 'Muon request not confirmed')

            let reqId = `0x${result.cid.substr(1)}`;
            let signature = result.signatures[0].signature.split(',')[0];
            let nonceAddress = result.data.init.nonceAddress;
            let msgHash = web3.utils.soliditySha3('done')

            let verifyResult = await muon.verify(reqId, msgHash, signature, nonceAddress);
            expect.eventEmitted(verifyResult, 'Transaction', (ev) => {
                return ev.reqId == reqId;
            })
        })
    })
});
