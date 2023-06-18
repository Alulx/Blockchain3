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

        it("Fee should be 2 wei", async function () {
          const fee = await contract.entryFee();
          expect(fee).to.equal(2);
        });

        it("should not be able to commit a guess due to  being host", async function () {
          await expect(contract.commit("0x3b48f2d0209eb4dd60e62c1f7e596ae31bd20069addd815217072f5e9590f121", {value:4} ))
            .to.be.revertedWith("Host cannot enter a guess");
        });
    
        it("should not be able to commit a guess due to low fees ", async function () {
          await expect(contract.connect(user1).commit("0x3b48f2d0209eb4dd60e62c1f7e596ae31bd20069addd815217072f5e9590f121", {value:2} ))
            .to.be.revertedWith("Incorrect fee amount, need to send 2x the entry fee");
        });
    
        it("should commit a 50, 3", async function () {
          await contract.connect(user1).commit("0x3b48f2d0209eb4dd60e62c1f7e596ae31bd20069addd815217072f5e9590f121", {value:4} )
        });

        it("should commit a 100, 8", async function () {
          await contract.connect(user2).commit("0xd2f63731675c6a71dc2bd3699360fd070b4ef61c2e40215aaeeee79f9e81574f", {value:4} )
        });

        it("should commit a 101, 90", async function () {
          await contract.connect(user4).commit("0xd430cd73dbd454a7e704ecd05377d2269967d62a12cb95aa1d2b9381e124b955", {value:4} )
        });

        it("should commit a 800, 7", async function () {
          await contract.connect(user3).commit("0xfda1fb15b6423425c4c23940a54c663cdf63c6ac5fa15bf9b009dd01df5dbe15", {value:4} )
        });

        

        it("Should start the reveal phase", async function () {
          await contract.startRevealPhase();
          expect(await contract.isRevealPhase()).to.equal(true);
        });

        it("should be able to reveal the 50, 3 guess ", async function () {
          await contract.connect(user1).reveal(50, 3);
        });

        it("should be able to reveal a guess 100,8 ", async function () {
          await contract.connect(user2).reveal(100, 8);
          const addresses = await contract.guessToAddress(100,0);
          expect(addresses).to.include(user2.address);
        });

        it("should be able to reveal a guess 101,90  ", async function () {
          await contract.connect(user4).reveal(101,90 );
          const addresses = await contract.guessToAddress(101,0);
          expect(addresses).to.include(user4.address);
        });
      
        it("should be able to reveal a guess 800,7  ", async function () {
          await contract.connect(user3).reveal(800,7 );
          const addresses = await contract.guessToAddress(800,0);
          expect(addresses).to.include(user3.address);
        });

        it("should be able to end the game  ", async function () {
          await contract.endGame();
        }); 

        it("should be able to withdraw service fees", async function () {
          await contract.withdrawServiceFee();
        });

        it("should be able to withdraw prize", async function () {
          await contract.connect(user4).claimPrize();
        });

        it("should be able to withdraw deposit", async function () {
          await contract.connect(user1).retrieveDeposit();
        });

        it("should be able to withdraw deposit", async function () {
          await contract.connect(user4).retrieveDeposit();
        });

        it("should NOT be able to withdraw deposit AGIAN", async function () {
          await expect(contract.connect(user4).retrieveDeposit()).to.be.revertedWith("Deposit has already been retrieved");
        });

  });
});