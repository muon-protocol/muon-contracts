const runBatchTX = require('./batchTx')
const { networksWeb3 } = require('./web3')

const ABI_MUON_V02 = require('../build/contracts/MuonV02.json').abi

const CONTRACT_ADDRESS = '0xE4F8d9A30936a6F8b17a73dC6fEb51a3BBABD51A'

// const CONTRACT_ADDRESS = {
//   3: '0xA18B20557212A4fef65965Cdf6dEF847abEd9cCb',
//   4: '0x4b3a3D16b6F54938bC1216b846E24cBdF9A221cB',
//   97: '0xFC9683a4256f892F2a848d22BfaCAb0c6d95D955',
//   4002: '0xE1E219C7eDfDAD1F3929b84816671980b5a653Dd',
//   80001: '0xFa4199E1b679fF05d315bAE8F24304a1098B65f3'
// }

// for (let index = 0; index < Object.keys(networksWeb3).length; index++) {
//   const chainId = Object.keys(networksWeb3)[index]
//   runBatchTX(
//     CONTRACT_ADDRESS[chainId],
//     'addGroupPublicKey',
//     [
//       '0xb0C7BB7918AA46e019bD128cB532bB44A8A01684',
//       '0x58898d168f0d264ee40660c0f15acae89ae11f2931a6a9d7f857c5ef6707b9c2',
//       '0'
//     ],
//     ABI_MUON_V02,
//     chainId
//   )
// }

for (let index = 0; index < Object.keys(networksWeb3).length; index++) {
  const chainId = Object.keys(networksWeb3)[index]
  runBatchTX(
    CONTRACT_ADDRESS,
    'addGroupPublicKey',
    [
      '0xb0C7BB7918AA46e019bD128cB532bB44A8A01684',
      '0x58898d168f0d264ee40660c0f15acae89ae11f2931a6a9d7f857c5ef6707b9c2',
      '0'
    ],
    ABI_MUON_V02,
    chainId
  )
}
