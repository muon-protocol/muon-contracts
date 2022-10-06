const muon = artifacts.require("./MuonV04.sol");
const nodeManager = artifacts.require("MuonNodeManager.sol");
const { toBN } = web3.utils;

function parseArgv() {
    let args = process.argv.slice(2);
    let params = args.filter((arg) => arg.startsWith("--"));
    let result = {};
    params.map((p) => {
        let [key, value] = p.split("=");
        result[key.slice(2)] = value === undefined ? true : value;
    });
    return result;
}

/**
 * Deploy MuonNodeManager cmd:
 * ./node_modules/.bin/truffle deploy --network=development --node-manager --nodes=../nodes.json
 */
module.exports = async function (deployer) {
    let args = parseArgv();
    if (args["node-manager"]) {
        await deployer.deploy(nodeManager);
        nodeManagerDeployed = await nodeManager.deployed();
        if (args["nodes"]) {
            let nodes = require(args["nodes"]);
            console.log(`Adding ${nodes.length} nodes`);
            for (i = 0; i < nodes.length; i++) {
                console.log(`Node ${nodes[i].nodeAddress}`);
                await nodeManagerDeployed.addNode(
                    nodes[i].nodeAddress,
                    nodes[i].stakerAddress || nodes[i].nodeAddress,
                    nodes[i].peerId,
                    true
                );
            }
        }
    }
};
