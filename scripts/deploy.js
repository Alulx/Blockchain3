const hre = require("hardhat");
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