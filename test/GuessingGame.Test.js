const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("GuessingGame", function () {
  before(async () => {
    [owner,user1,user2,user3] = await ethers.getSigners();
    const GuessingFactoryContract = await ethers.getContractFactory('GuessingGame');
    contract = await GuessingFactoryContract.deploy(20);
  });

/*   describe("Factory", function () {
     it("Should be able to create Games", async function () {
      const guessinggame =  guessingfactory.connect(user2).createGame();
      const games = await guessingfactory.getGames();
      console.log(games);
      console.log(guessinggame);

     
       expect(games.length).to.equal(1);

    }); 
  }); */

  describe("Game", function () {
   
      it('Shouldnt be able to guess due to low fees', async function () {
        await expect(contract.guess(10,{value: 10})).to.be.revertedWith('Incorrect fee amount');
       });

      it("Shouldnt be able to guess a 1001", async function () {
        await expect(contract.guess(1001,{value: 20})).to.be.revertedWith('Guess must be between 0 and 1000');
      });

      it("Should be able give a guess 0", async function () {
        await contract.guess(0,{value: 20});
      });

      it("Shouldnt be able to give a second guess", async function () {
        await expect(contract.guess(1000,{value: 20})).to.be.revertedWith('Player has already entered a guess');
      });

      it("Should be able to give a second guess from new user", async function () {
        await (contract.connect(user1).guess(1000,{value: 20}));
      });

      it("Should calculate the average of all 3 guess and end the game", async function () {
        await (contract.connect(user2).guess(500,{value: 20}));
      });
      
  });  
});
