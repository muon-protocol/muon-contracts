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
  return val === "1" || val === "true";
}

if (process.argv.length != 4) {
  console.log(
    "Usage: set_deployer.js <nodeId> <isDeployer>"
  );
  process.exit(1);
}

async function setIsDeployer() {
  const nodeId = process.argv[2],
    isDeployer = parseBool(process.argv[3]);

  const tx = await contract.methods.setIsDeployer(nodeId, isDeployer).send({
    from: acc.address,
    gas: 1000000,
  });
  console.log("setDeployer TX Hash: ", tx.transactionHash);
}

setIsDeployer()
  .then(() => {
    console.log("done.");
  })
  .catch((err) => {
    console.log(err);
  })
  .then(() => {
    process.exit(1);
  });
