// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "hardhat/console.sol";

/*
    2 contracts: GuessingFactory and GuessingGame
    GuessingFactory is the factory contract that creates new GuessingGame contracts
    GuessingGame is the contract that players interact with


*/

contract GuessingFactory  {
    event NewGame(address indexed player, address game);

    mapping(address => address[]) public playerToGames;
    address[] public games; 

    address public logicContractAddress;

    constructor(address _masterContract) {
        require(_masterContract != address(0), "Invalid contract address");
        logicContractAddress = _masterContract;
    }

    function createGame(uint256 _feeAmount) external  returns (address)  {
        // require(msg.value == _feeAmount, "Incorrect wager amount");

        address newGame = Clones.clone(logicContractAddress) ;
        // since the clone create a proxy, the constructor is redundant and you have to use the initialize function
        GuessingGame(newGame).initialize(msg.sender, _feeAmount); 

        playerToGames[msg.sender].push(newGame);

        games.push(newGame);

        emit NewGame(msg.sender, newGame);
        console.log("new game deployed on: ", newGame);

        return newGame;
    } 

    function getGamesByPlayer(address player) external view returns (address[] memory) {
        return playerToGames[player];
    }
    
    function getGames() external view returns(address[] memory){
        return games;
    }
}


contract GuessingGame {
    address payable public host;
    address payable public winner; 
    uint256 public entryFee;
    bool public gameEnded;
    bool public hasInitialized;

    mapping(uint256 => address[]) public guessToAddress;
    mapping(address => bool) public hasEntered; // mapping to track player entries

    uint256[] private guesses;
    uint256[] private diffs;

    uint256 public gameDeadline;
    uint256 public gameCreationTime;    

    // Function only called once when the game is created
    function initialize(address _owner, uint256 _feeAmount) external {
        require(_owner != address(0), "Invalid owner address");
        require(_feeAmount > 0, "Invalid fee amount");
        require(hasInitialized == false, "Game has already been initialized");

        hasInitialized = true;
        host = payable(_owner);
        entryFee = _feeAmount;
        gameEnded = false; 
        gameDeadline = block.timestamp + 1 days; // set the deadline to 1 day from now

        console.log("Deploying GuessingGame with entry fee: ", entryFee);
        console.log("Deploying GuessingGame with host: ", host);
        console.log("Deploying on address: ", address(this));
    }

    function guess(uint256 _guess) public payable {
        require(msg.value == entryFee, "Incorrect fee amount");
        require(msg.sender != host, "Host cannot enter a guess");
        require(hasEntered[msg.sender] == false, "Player has already entered a guess");
        require(_guess <= 1000 && _guess >= 0, "Guess must be between 0 and 1000");
        require(gameEnded == false, "Game has already ended");
        require(block.timestamp < gameDeadline, "Game deadline has passed");


        //require(block.timestamp < gameEndTime, "Game has ended");

        guessToAddress[_guess].push(msg.sender);
        hasEntered[msg.sender] = true;

        guesses.push(_guess);
        console.log("guess:", _guess);

        if (guessToAddress[_guess].length > 1){
            console.log("guessTOAddress:", getAddressByGuess(_guess)[guessToAddress[_guess].length - 1]);
        } else {
            console.log("guessTOAddress:", getAddressByGuess(_guess)[0]);

        }
        
    }


/*     function init(address _host, uint256 _entryFee) external {
        console.log("init game");
        host = payable(_host);
        entryFee = _entryFee;
        gameEndTime = block.timestamp + 1 days;
         numberOfGuesses = 0; 
        gameEnded = false;
        gameCreationTime = block.timestamp; // Set the game creation time
    } */

   
    function endGame() external {
        require(guesses.length >= 3, "Need at least 3 guesses");
        // check if someone who has given a guess wants to end the game
        require(msg.sender == host , "Only host may end the game");
        require(gameEnded == false, "Game has already ended");
        
        gameEnded = true;
        uint256 average;
        for (uint256 i = 0; i < guesses.length; i++) {
            average += guesses[i];
         }  

        average /= guesses.length; //average
        average = (average * 66) / 100; //get two thirds
        console.log("average number is: ", average);
        
        diffs = new uint256[](guesses.length);
        for (uint256 i = 0; i < guesses.length; i++) {
           uint diff = absDiff(guesses[i], average);
              diffs[i] = diff;
        }  
        console.log(getSmallest(diffs));
        uint256 winningNumber = getSmallest(diffs) + average;
        console.log("winning number is: ", winningNumber );
        address[] memory _guessAddress = guessToAddress[winningNumber];

        // check if multiple players chose the same number and if so, randomly select one
        if (guessToAddress[winningNumber].length > 1){
            console.log("endgame_ guessTOAddress:", getAddressByGuess(winningNumber)[0]);
            console.log("endgame_ guessTOAddress:", getAddressByGuess(winningNumber)[1]);
            uint256 winnerIndex = uint256(block.timestamp) % guessToAddress[winningNumber].length;
            winner =  payable(guessToAddress[winningNumber][winnerIndex]);
        } else {
            winner =  payable(_guessAddress[0]);
        }
        console.log("winner is: ", winner );

        //payout winner
        console.log("Contracts balance: ", address(this).balance);
        transfer(winner); // 90% of the balance goes to the winner
        withdraw(); // 10% of the balance goes to the host
        //print balance of contract
        console.log("Contracts balance: ", address(this).balance);
        // print balance of winner
        console.log("Winners balance: ", winner.balance);
        // and of host
        console.log("Hosts balance: ", host.balance);
    } 

    function absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

/*     function claimRemainingBalance() external {
        require(msg.sender == host, "Only the host can claim the remaining balance");
        require(gameEnded, "Game has not yet ended");

        // Calculate the duration since game creation
        uint256 durationSinceCreation = block.timestamp - gameCreationTime;
        // 86400 is one day 
        // Check if the duration is greater than or equal to the desired duration
        if (durationSinceCreation >= 86400) {
            uint256 remainingBalance = address(this).balance - totalPrizePool;
            if (remainingBalance > 0) {
                payable(msg.sender).transfer(remainingBalance);
            }
        }
    } */

/*     function withdrawFees() public {
        require(block.timestamp >= gameDeadline, "Game is still active");
        require(amount > 0, "No fees to withdraw");
        
        fees[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send fees");
    }
*/
    function getSmallest(uint256[] memory _array)  internal  returns(uint256){
        uint256 store_var = 1000;
        uint256 i;
        for(i=0;i<_array.length;i++){
            if(store_var> _array[i]){
                store_var = _array[i];
            }
        }
        return store_var;
   } 

    function getAddressByGuess(uint256 number) public view returns (address[] memory) {
        return guessToAddress[number];
    }

    // Function to withdraw  Ether to host from this contract.
    function withdraw() private  {
        require(msg.sender == host , "Only the host can withdraw Ether");
        require(gameEnded == true,"Game has not ended yet");

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = host.call{value: address(this).balance * 10 / 100}("");  // 10% of the balance goes to the host
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address _winner) private  {
        require(msg.sender == host || msg.sender == winner, "Only the host or winner can transfer Ether");
        require(gameEnded == true,"Game has not ended yet");
        console.log("test");
        (bool success, ) = _winner.call{value:  address(this).balance * 90 / 100}("");  // 90% of the balance goes to the winner
        require(success, "Failed to send Ether");
    }
}