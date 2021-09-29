# muon-contracts

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