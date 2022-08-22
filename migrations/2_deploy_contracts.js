var muon = artifacts.require('./MuonV02.sol')
var { toBN } = web3.utils

const pubKeyAddress = process.env.MUON_MASTER_WALLET_PUB_ADDRESS
const pubKeyX = process.env.MUON_MASTER_WALLET_PUB_X
const pubKeyYParity = process.env.MUON_MASTER_WALLET_PUB_Y_PARITY

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
  
  deployer.then(async () => {
    let deployedMuon = await deployer.deploy(
      muon,
      pubKeyAddress,
      pubKeyX,
      pubKeyYParity
    )

    // await deployedMuon.addGroupPublicKey(
    //   "0xF096EC73cB49B024f1D93eFe893E38337E7a099a",
    //   "0xeae3877457595b4884e6fffa853ad34ca19cb142e06e90796c3cdf983893b8d",
    //   "1"
    // );

  })
}
