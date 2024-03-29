const axios = require('axios');

const BASE_URL = process.env.MUON_NODE_GATEWAY

function request(params){
	return axios.post(BASE_URL, params).then(({data}) => data)
}

function ethCallContract(address, method, params, abi) {
	let filteredAbi = [
		abi.find(({name, type}) => (name === method && type === 'function'))
	]
	let data = {
		app: 'eth',
		method: 'call',
		params: {
			address, 
			method, 
			params, 
			abi: filteredAbi,
			outputs: ['user', 'amount', 'fromChain', 'toChain', 'tokenId', 'txId'],
			network: 'ganache'
		}
	}
	return axios.post(BASE_URL, data).then(({data}) => data)
}

function ethAddBridgeToken(mainTokenAddress, mainNetwork, targetNetwork) {
	let data = {
	    app: "eth",
	    method: "addBridgeToken",
	    params: {
	        mainTokenAddress,
	        mainNetwork,
	        targetNetwork
	    }
	}
	return axios.post(BASE_URL, data).then(({data}) => data)
}

module.exports = {
	request,
	ethCallContract,
	ethAddBridgeToken,
}