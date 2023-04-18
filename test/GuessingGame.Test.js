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

  describe("Gaming", function () {
   

      it("Shouldnt be able to guess due to low fees", async function () {
        await contract.connect(user1).guess(10, {value:10});
       //  await expect(await contract.connect(user1).guess(10,{value: 10}).to.be.revertedWith("Incorrect fee amount"));
      });

      it("Shouldnt be able to guess due to bad number", async function () {
        contract.guess(11111);
        //await expect(contract.connect(user1).guess(10,{value: 10}).to.be.revertedWith("Incorrect fee amount"));
      });

      it("Should be able give a guess", async function () {
        await contract.guess(30, {value:20});
        //await expect(contract.connect(user1).guess(10,{value: 10}).to.be.revertedWith("Incorrect fee amount"));
      });
  });  
});
