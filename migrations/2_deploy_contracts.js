var muon = artifacts.require('./MuonV01.sol')

function parseArgv(){
	let args = process.argv.slice(2);
	let params = args.filter(arg => arg.startsWith('--'))
	let result = {}
	params.map(p => {
		let [key, value] = p.split('=');
		result[key.slice(2)] = value === undefined ? true : value
	})
	return result;
}

module.exports = function (deployer) {
	deployer.then(async () => {
		// let params = parseArgv()

		await deployer.deploy(muon);

		// let muonAddress = null
		// if(!!params['muonAddress']){
		// 	muonAddress = params['muonAddress'];
		// }
		// else{
		// 	let deployedMuon = await await deployer.deploy(muon);
		// 	muonAddress = deployedMuon.address;
		// }
		
    //let deployedPresale = await deployer.deploy(presale, "0xd0e5D73785A1b179628F873306Ae5911dD29Aed3")
	})
}
