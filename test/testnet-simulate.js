const truffleAssert = require('truffle-assertions');
const {expect, muonNode} = require('./helpers')
const {toBN} = web3.utils;
const toWei = (number) => web3.utils.toWei(number.toString());
const fromWei = (x) => web3.utils.fromWei(x);


const MuonTestToken = artifacts.require('./MuonTestToken.sol');
const MuonNodeManager = artifacts.require('./MuonNodeManager.sol');
const MuonNodeStaking = artifacts.require("./MuonNodeStaking.sol");

contract("MuonTestnet", (accounts) => {
    let owner = accounts[9];
    let staker = accounts[1];

    describe("Deploy contracts", async () => {
        it("should add a node", async () => {
            let mutest = await MuonTestToken.new({from: owner});
            let nodeManager = await MuonNodeManager.new({from:owner});
            let nodeStaking = await MuonNodeStaking.new(
                mutest.address,
                nodeManager.address,
                {from: owner}
            );
            // grant ADMIN_ROLE to MuonNodeStaking
            await nodeManager.grantRole(
                await nodeManager.ADMIN_ROLE(),
                nodeStaking.address,{
                    from: owner
                }
            );

            // mint token
            await mutest.mint(staker, toWei(1000), {from:owner});

            // approve
            await mutest.approve(nodeStaking.address, toWei(1000), {from: staker});
            
            // stake
            await nodeStaking.stake(toWei(1000), {from: staker});

            // add node
            await nodeStaking.addMuonNode(staker, "test-peer-id", {
                from: staker
            });

            let info = await nodeManager.info();
            assert(info._nodes.length==1, "Node not added");
        });
    });
});
