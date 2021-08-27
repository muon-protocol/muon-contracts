const addSeconds = (seconds) => new Promise((resolve, reject) => 
    web3.currentProvider.send({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [seconds],
        id: new Date().getTime()
    }, (error, result) => {
        web3.currentProvider.send({
            jsonrpc: '2.0', 
            method: 'evm_mine', 
            params: [], 
            id: new Date().getSeconds()
        }, (err, res) => resolve(res));
    }));


const addDays = (days) => addSeconds(days * 24 * 60 * 60);
const addHours = (hours) => addSeconds(hours * 60 * 60);

const currentTimestamp = () => web3.eth.getBlock(web3.eth.blockNumber).timestamp;

module.exports =  {
    addSeconds,
    addDays,
    addHours,
    currentTimestamp
};