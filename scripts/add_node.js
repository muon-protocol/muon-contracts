require("dotenv").config();
const Web3 = require("web3");
const web3 = new Web3(process.env.NODE_MANAGER_PROVIDER);

const ABI = require("../build/contracts/MuonNodeManager.json").abi;
const contractAddress = process.env.NODE_MANAGER_CONTRACT;

const acc = web3.eth.accounts.privateKeyToAccount(process.env.PK);

web3.eth.accounts.wallet.add(acc);
web3.eth.defaultAccount = acc.address;

var contract = new web3.eth.Contract(ABI, contractAddress);

function parseBool(val) {
    val = val.toString().toLowerCase();
    return val === '1' || val === 'true'
}

if(process.argv.length != 7){
    console.log("Usage: add_node.js <nodeAddress> <stakerAddress> <peerId> <active> <isDeployer>");
    process.exit(1)
}

async function addNodeToNetwork() {
    const nodeAddress = process.argv[2],
      stakerAddress = process.argv[3],
      peerId = process.argv[4],
      active = parseBool(process.argv[5]),
      isDeployer = parseBool(process.argv[6]);

    let tx = await contract.methods
      .addNode(
        nodeAddress, // nodeAddress
        stakerAddress, // stakerAddress
        peerId,
        active // active
      )
      .send({
          from: acc.address,
          gas: 10000000
      })
    console.log("Add TX Hash: ", tx.transactionHash);

    if(isDeployer) {
        const nodeInfo = await contract.methods.nodeAddressInfo(nodeAddress).call();
        const tx = await contract.methods
          .setIsDeployer(nodeInfo.id, isDeployer)
          .send({
              from: acc.address,
              gas: 1000000,
          })
        console.log("setDeployer TX Hash: ", tx.transactionHash);
    }
}

addNodeToNetwork()
  .then(() => {
      console.log('done.')
  })
  .catch((err) => {
      console.log(err);
  })
  .then(() => {
      process.exit(1);
  })
