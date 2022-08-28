# muon-contracts

# V3 Updates

- reqId calculates deterministically and must be signed and verified on the chain.

- SchnorrSECP256K1 is on MuonV03 and does not need a contract call anymore. It reduced gas.

- The apps can verify both TSS and Gateway signatures. It let’s the apps run their own gateway and accept the requests that are initiated by their own gateway.

- APP_ID, reqId must be the first 2 fields in the signature.

Sample smart contract:  
https://github.com/muon-protocol/muon-contracts/blob/v3/contracts/MuonV03Example.sol  

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
