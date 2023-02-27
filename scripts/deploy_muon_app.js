require("dotenv").config();
const Muon = require("muon");

// Testnet: https://testnet.muon.net
//const muon = new Muon(process.env.MUON_NODE_GATEWAY);

const muon = new Muon(process.argv[3]);

const deploymentApp = "deployment";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// appId of the MuonApp
const tssAppId = process.argv[2]//process.env.MUON_TSS_APP_ID;

async function main() {
    // let randomSeedResponse = await muon
    //     .app(deploymentApp)
    //     .method("random-seed", {
    //         appId: tssAppId,
    //     })
    //     .call();
    // console.log("RandomSeed response: ", randomSeedResponse);
    // await sleep(2000);
    // let deployResponse = await muon
    //     .app(deploymentApp)
    //     .method("deploy", {
    //         appId: tssAppId,
    //         reqId: randomSeedResponse.reqId,
    //         seed: randomSeedResponse.sigs[0].signature,
    //         n: 20,
    //         t: 10,
    //         nonce: randomSeedResponse.sigs[0].nonce,
    //     })
    //     .call();

    // console.log("Deploy response: ", JSON.stringify(deployResponse));
    // await sleep(10000);

    let keyGenResponse = await muon
        .app(deploymentApp)
        .method("tss-key-gen", {
            appId: tssAppId,
            seed: "0x36f439a68a1446b707c2b1ad2c750ac41d90d18d01c920cf7262477f7b8ae9a6"//randomSeedResponse.sigs[0].signature,
        })
        .call();
    console.log("Keygen Response: ", keyGenResponse);
}

main().then(() => console.log("Success"));
