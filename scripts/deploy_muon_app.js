require("dotenv").config();
const Muon = require("muon");
const muon = new Muon(process.env.MUON_NODE_GATEWAY);
const deploymentApp = "deployment";

const sleep = ms => new Promise(r => setTimeout(r, ms));

// test app to deploy
const tssAppId = process.env.MUON_TSS_APP_ID;

async function main() {
    let randomSeedResponse = await muon
        .app(deploymentApp)
        .method("random-seed", {
            appId: tssAppId,
        })
        .call();
    console.log(randomSeedResponse);
    // return;
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

    console.log(deployResponse);
    await sleep(10000);

    let keyGenResponse = await muon
        .app(deploymentApp)
        .method("tss-key-gen", {
            appId: tssAppId,
            seed: randomSeedResponse.sigs[0].signature,
        })
        .call();
    console.log(keyGenResponse);
}

main().then(() => console.log("Success"));
