
const path = require("path");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const factory = await ethers.getContractFactory("GuessingFactory");

  //get value of eth gas price
  const gasPrice = await ethers.provider.getGasPrice();
  console.log("Gas price:", gasPrice.toString());
  
  
   const estimatedGas = await factory.signer.estimateGas(
    factory.getDeployTransaction()
   );
   console.log(`Estimated gas: ${estimatedGas}`); 

  const guessingGame = await factory.deploy();
  await guessingGame.deployed();

  console.log("Game Contract address:", guessingGame.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });