const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("GuessingGame", function () {
  before(async () => {
    [owner,user1,user2,user3] = await ethers.getSigners();
    const GuessingFactoryContract = await ethers.getContractFactory('GuessingFactory');
    guessingfactory = await GuessingFactoryContract.deploy();
  });

  describe("Factory", function () {
/*     it("Should be able to create Games", async function () {
       guessingfactory.connect(user2).createGame(0, {value: 10});
        guessingfactory.connect(user1).createGame(1, {value: 5});
      const games = await guessingfactory.getGames();
      console.log(games);
      
      console.log(child1);
      expect(games.length).to.equal(2);

    }); */
  });

  describe("Withdrawals", function () {
   

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  
      });
  });  
});
