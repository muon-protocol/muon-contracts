# muon-contracts

# Samples


Sample smart contract:  
https://github.com/muon-protocol/muon-contracts/blob/v4-muon-as-a-lib/contracts/MuonClientExample.sol

Sample MuonApp:  
https://github.com/muon-protocol/muon-apps/blob/master/general/muon_v3_sample.js  

# Compile
$ npm install  
$ ./node_modules/.bin/truffle compile  

# Deploy development
$ npm run deploy-dev -- --pubAddress=0x6deb6fbd3... --pubX=0x1af2181eb... --yParity=0

# Run tests  
1- Install & run ganache-cli  
  
2- $ ./node_modules/.bin/truffle tests  

# Test specific file
$ ./node_modules/.bin/truffle test --network development --show-events ./test/--path to the file--/
