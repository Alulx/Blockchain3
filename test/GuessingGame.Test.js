const { expect } = require('chai');
const { ethers } = require('hardhat');
const  contractAbi = require ("../artifacts/contracts/GuessingGame.sol/GuessingGame.json");


describe("GuessingFactory", function () {
  before(async () => {
    [owner,user1,user2,user3, user4, user5] = await ethers.getSigners();


    const GuessingGameContract = await ethers.getContractFactory('GuessingGame');
    contract = await GuessingGameContract.deploy();
    

    const GuessingFactoryContract = await ethers.getContractFactory('GuessingFactory');
    guessingfactory = await GuessingFactoryContract.deploy(contract.address);
  });

  it("should print some basic info", async function () {
  

    let tx = await guessingfactory.createGame(2)

    let txreceipt = await tx.wait()
    
    /* console.log("tx: ",tx)
    console.log("txreceipt: ",txreceipt) */
    const [NewGame] = txreceipt.events;
    const  game= NewGame.args.game
    console.log("stuff", game)
    guessingfactory.on("NewGame", (arg1, arg2) => {
      console.log('MyEvent emitted:', arg1, arg2);
      expect(arg1).to.equal(owner.address);
      console.log("owneraddress: ",owner.address)
    })
    

    /* console.log("gamesByPlayer: ",gamesByPlayer);
    console.log("owner.address: ",owner.address); */
   
  });
/* 
  it("Should be able to  and emit NewGame event", async function () {
    await expect(guessingfactory.createGame(20))
      .to.emit(guessingfactory, 'NewGame')
      .withArgs(owner.address, "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e");

  });  */

  it("Should be able to get games by player", async function () {
    const gamesByPlayer = await guessingfactory.getGamesByPlayer(owner.address);
    expect(gamesByPlayer.length).to.equal(1);
    
  });

  describe("GuessingGame", function () {
    before(async () => {
      //deploy instance of contrac in games(0) from factory contract



      const GuessingGameContractAddess = await guessingfactory.games(0)
      const formattedAddress = GuessingGameContractAddess.toLowerCase(); // Convert to lowercase

      console.log("GuessingGameContract: ",formattedAddress);

      const Game = await ethers.getContractFactory('GuessingGame');
      const contract =  new ethers.Contract(GuessingGameContractAddess, contractAbi.abi, owner);
      const isInit = await contract.hasInitialized();
      console.log("isInit: ",isInit);
    });
    
        it("should be initialized ", async function () {
          await contract.initialize(owner.address, 2);
          const isInit = await contract.hasInitialized();
          expect(isInit).to.equal(true);
        });

        it("Should be able to get the host", async function () {
          const host = await contract.host();
          expect(host).to.equal(owner.address);
        });

        it("Fee should be 2 ether", async function () {
          const fee = await contract.entryFee();
          expect(fee).to.equal(ethers.utils.parseEther("2"));
        });
    
        it('Shouldnt be able to guess due to low fees', async function () {
          await expect(contract.connect(user1).guess(10,{value: ethers.utils.parseEther("0.2")})).to.be.revertedWith('Incorrect fee amount');
        });

        it("Shouldnt be able to guess a 1001", async function () {
          await expect(contract.connect(user1).guess(1001,{value: ethers.utils.parseEther("2")})).to.be.revertedWith('Guess must be between 0 and 1000');
        });

        it("Should be able give a guess 0", async function () {
          await contract.connect(user1).guess(0,{value: ethers.utils.parseEther("2")});
        });

        it("Shouldnt be able to give a second guess", async function () {
          await expect(contract.connect(user1).guess(1000,{value: ethers.utils.parseEther("2")})).to.be.revertedWith('Player has already entered a guess');
        });

        it("Shouldnt be able to end game after a single guess", async function () {
          await expect(contract.endGame()).to.be.revertedWith('Need at least 3 guesses');
        });

        it("Should be able to give a second and third and forth guess from new user", async function () {
          await (contract.connect(user2).guess(500,{value: ethers.utils.parseEther("2")}));
          await (contract.connect(user4).guess(500,{value: ethers.utils.parseEther("2")}));
          await (contract.connect(user5).guess(999,{value: ethers.utils.parseEther("2")}));


        });

/*         it("Should only be possible to  withdraw funds once the game has ended and by host", async function () {
          await expect(contract.connect(user1).withdraw()).to.be.revertedWith('Only the host can withdraw Ether');
          await expect(contract.withdraw()).to.be.revertedWith('Game has not ended yet');
        }); */

/*         it("Should only be possible to transfer funds once the game has ended and by host or winner", async function () {
          await expect(contract.connect(user2).transfer(user1.address)).to.be.revertedWith('Only the host or winner can transfer Ether');
          await expect(contract.transfer(user1.address)).to.be.revertedWith('Game has not ended yet');
        }); */

        it("Should not be possible to end game by outsider", async function () {
          await expect(contract.connect(user3).endGame()).to.be.revertedWith('24 hours have not passed yet or you are not the host');
        });

        it("Should be possible for host to end the game", async function () {
          await expect(contract.endGame());
        });

/*         it("Should be able to withdraw remaining funds", async function () {
          await expect(contract.withdraw());
        }); */
         
  });
});