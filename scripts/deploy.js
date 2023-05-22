/* const hre = require("hardhat");
async function main() {
  const GuessingGame= await hre.ethers.getContractFactory("GuessingGame");
  const guessingGame= await GuessingGame.deploy();
  await guessingGame.deployed();
  console.log("GuessingGame contract deployed to: ", guessingGame.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
 */

  const path = require("path");

const hre = require("hardhat");
async function main() {
  const GuessingGame= await hre.ethers.getContractFactory("GuessingGame");
  const guessingGame= await GuessingGame.deploy();
  await guessingGame.deployed();
  console.log("LogicContract contract deployed to: ", guessingGame.address);

  const GuessingGameFactory= await hre.ethers.getContractFactory("GuessingFactory");
  const proxyFactory= await GuessingGameFactory.deploy(guessingGame.address);
  await proxyFactory.deployed();
  console.log("proxyFactory contract deployed to: ", proxyFactory.address);
  //print logicContract address of ProxyFactory
  console.log("LogicContract address of ProxyFactory: ", await proxyFactory.logicContractAddress());

    // We also save the contract's artifacts and address in the frontend directory
    saveFrontendFilesFactory(proxyFactory);
    saveFrontendFilesGame(guessingGame);

}

function saveFrontendFilesFactory(proxyFactory) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "Frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "proxy-contract-address.json"),
    JSON.stringify({ proxyFactory: proxyFactory.address }, undefined, 2)
  );

  const proxyFactoryArtifact = artifacts.readArtifactSync("GuessingFactory");

  fs.writeFileSync(
    path.join(contractsDir, "proxyFactory.json"),
    JSON.stringify(proxyFactoryArtifact, null, 2)
  );
}

function saveFrontendFilesGame(guessingGame) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "Frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "game-contract-address.json"),
    JSON.stringify({ guessingGame: guessingGame.address }, undefined, 2)
  );

  const guessingGameArtifact = artifacts.readArtifactSync("GuessingGame");

  fs.writeFileSync(
    path.join(contractsDir, "guessinggame.json"),
    JSON.stringify(guessingGameArtifact, null, 2)
  );
}



main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });