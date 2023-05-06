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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });