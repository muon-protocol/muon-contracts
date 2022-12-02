require("dotenv").config();
const Muon = require("muon");

// Testnet: https://testnet.muon.net
const muon = new Muon(process.env.MUON_NODE_GATEWAY);
const deploymentApp = "deployment";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// appId of the MuonApp
const tssAppId = process.env.MUON_TSS_APP_ID;

async function main() {
    let randomSeedResponse = await muon
        .app(deploymentApp)
        .method("random-seed", {
            appId: tssAppId,
        })
        .call();
    console.log("RandomSeed response: ", randomSeedResponse);
    await sleep(2000);
    let deployResponse = await muon
        .app(deploymentApp)
        .method("deploy", {
            appId: tssAppId,
            reqId: randomSeedResponse.reqId,
            seed: randomSeedResponse.sigs[0].signature,
            nonce: randomSeedResponse.sigs[0].nonce,
        })
        .call();

    console.log("Deploy response: ", deployResponse);
    await sleep(5000);

    let keyGenResponse = await muon
        .app(deploymentApp)
        .method("tss-key-gen", {
            appId: tssAppId,
            seed: randomSeedResponse.sigs[0].signature,
        })
        .call();
    console.log("Keygen Response: ", keyGenResponse);
}

main().then(() => console.log("Success"));
