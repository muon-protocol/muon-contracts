require("dotenv").config();
const Web3 = require("web3");
const web3 = new Web3(process.env.NODE_MANAGER_PROVIDER);

const ABI = require("../build/contracts/MuonNodeManager.json").abi;
const contractAddress = process.env.NODE_MANAGER_CONTRACT;

const acc = web3.eth.accounts.privateKeyToAccount(process.env.PK);

web3.eth.accounts.wallet.add(acc);
web3.eth.defaultAccount = acc.address;

var contract = new web3.eth.Contract(ABI, contractAddress);

if(process.argv.length != 5){
    console.log("Usage: add_node.js <nodeAddress> <stakerAddress> <peerId>");
    process.exit(1)
}
contract.methods
    .addNode(
        process.argv[2], // nodeAddress
        process.argv[3], // stakerAddress
        process.argv[4],
        true // active
    )
    .send({
        from: acc.address,
        gas: 1000000,
    })
    .then((x) => {
        console.log("Done. TX Hash: ", x.transactionHash);
    })
    .catch((err) => {
        console.log(err);
        process.exit(1);
    });
