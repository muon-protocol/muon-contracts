var MuonV04Example = artifacts.require('./MuonV04Example.sol');
var MuonV04 = artifacts.require('./MuonV04.sol');

const truffleAssert = require('truffle-assertions');
const {expect, muonNode} = require('./helpers')
const {toBN} = web3.utils;

const tssAppId = process.env.MUON_TSS_APP_ID;
const muonGateway = process.env.MUON_GATEWAY;

contract("MuonV04Example", (accounts) => {
    let owner=accounts[9], v4Example;

    before(async () => {
        let muon = await MuonV04.new({from: owner});
        // v4Example = await MuonV04Example.new(
        //     muon.address, 
        //     tssAppId, {
        //         x: pubKeyX, 
        //         parity: pubKeyYParity
        //     }, {from: owner});
    });

    describe("Test TSS verification", async () => {
        it("should verify signature", async () => {
            let muonResponse = await muonNode.request({app: 'tss', method: 'test'})
            let {success, result} = muonResponse
            assert(success === true, 'Muon response failed')
            assert(result.confirmed === true, 'Muon request not confirmed')

            let reqId = result.reqId;
            let groupAddress = result.signatures[0].owner;
            let signature = result.signatures[0].signature;
            let nonceAddress = result.data.init.nonceAddress;
            let msgHash = web3.utils.soliditySha3('done')

            let sig = {
                signature: signature,
                owner: groupAddress,
                nonce: nonceAddress
            }
            let verifyResult = await v4Example.verifyTSS.call('done',reqId, sig);
            assert(verifyResult===true, "Not verified.");
        })
    })
});
