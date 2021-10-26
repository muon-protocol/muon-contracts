var schnorrLib = artifacts.require('./SchnorrSECP256K1.sol')
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
    let params = parseArgv()

    let libAddress = null
    if (!!params['libAddress']) {
      libAddress = params['muonAddress']
    } else {
      let deployedSchnorrLib = await await deployer.deploy(schnorrLib)
      libAddress = deployedSchnorrLib.address
    }
    let deployedMuon = await deployer.deploy(
      muon,
      libAddress,
      pubKeyAddress,
      pubKeyX,
      pubKeyYParity
    )
  })
}
