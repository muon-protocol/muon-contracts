const muon = artifacts.require('./MuonV04.sol')
const nodeManager = artifacts.require('MuonNodeManager.sol');
const { toBN } = web3.utils;

function parseArgv() {
  let args = process.argv.slice(2)
  let params = args.filter((arg) => arg.startsWith('--'))
  let result = {}
  params.map((p) => {
    let [key, value] = p.split('=')
    result[key.slice(2)] = value === undefined ? true : value
  })
  return result
}

module.exports = function (deployer) {
  let args = parseArgv();
  if(args['node-manager']){
    deployer.deploy(nodeManager);
  }
}
