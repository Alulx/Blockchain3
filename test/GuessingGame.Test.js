const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("GuessingGame", function () {
  before(async () => {
    [owner,user1,user2,user3] = await ethers.getSigners();
    const GuessingFactoryContract = await ethers.getContractFactory('GuessingFactory');
    guessingfactory = await GuessingFactoryContract.deploy("0x5fbdb2315678afecb367f032d93f642f64180aa3");
  });

  describe("Factory", function () {
     it("Should be able to create Games", async function () {
      const guessinggame =  guessingfactory.connect(user2).createGame();
      const games = await guessingfactory.getGames();
      console.log(games);
      console.log(guessinggame);

     
       expect(games.length).to.equal(1);

    }); 
  });

  describe("Withdrawals", function () {
   

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  
      });
  });  
});
