var MuonClientExample = artifacts.require('./MuonClientExample.sol');

const truffleAssert = require('truffle-assertions');
const {expect, muonNode} = require('./helpers')
const {toBN} = web3.utils;

contract("MuonClientExample", (accounts) => {
    let owner=accounts[9], v4Example, muonResponse;

    before(async () => {
        muonResponse = await muonNode.request({app: 'tss', method: 'test'})
        // console.log(muonResponse);
        let {success, result} = muonResponse;
        console.log(result.appId, {
                x: result.signatures[0].ownerPubKey.x, 
                parity: result.signatures[0].ownerPubKey.yParity
            })
        v4Example = await MuonClientExample.new(
            result.appId, {
                x: result.signatures[0].ownerPubKey.x, 
                parity: result.signatures[0].ownerPubKey.yParity
            }, {from: owner});
    });

    describe("Test TSS verification", async () => {
        it("should verify signature", async () => {
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
            //assert(verifyResult===true, "Not verified.");
        })
    })
});
