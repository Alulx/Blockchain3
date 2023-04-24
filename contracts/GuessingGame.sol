// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;

import "hardhat/console.sol";

contract GuessingGame {
    address payable public host;
    address payable public winner; 
    uint256 public entryFee;
    bool public gameEnded;
    mapping(uint256 => address[]) public guessToAddress;

    mapping(address => bool) public hasEntered; // mapping to track player entries

    uint256[] public guesses;
    uint256[] public diffs;

    uint256 public gameEndTime;
    uint256 public gameCreationTime;    

    constructor(uint256 _feeAmount) {
        host = payable(msg.sender);
        entryFee = _feeAmount;
        gameEnded = false; 
        console.log("Deploying GuessingGame with entry fee: ", entryFee);
        console.log("Deploying GuessingGame with host: ", host);
    }

    function guess(uint256 _guess) public payable {
        require(msg.value == entryFee, "Incorrect fee amount");
        require(hasEntered[msg.sender] == false, "Player has already entered a guess");
        require(_guess <= 1000 && _guess >= 0, "Guess must be between 0 and 1000");
        require(gameEnded == false, "Game has already ended");

        //require(block.timestamp < gameEndTime, "Game has ended");

        guessToAddress[_guess].push(msg.sender);
        hasEntered[msg.sender] = true;

        guesses.push(_guess);
        console.log("guess:", _guess);
        console.log("guessTOAddress:", getAddressByGuess(_guess)[0]);

        if (guessToAddress[_guess].length > 1){
            console.log("guessTOAddress:", getAddressByGuess(_guess)[1]);
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
        require(hasEntered[msg.sender] == true, "Only players may end the game");
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
        transfer(winner, address(this).balance * 90 / 100); // 90% of the balance goes to the winner
        withdraw(host, entryFee);
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

    function getSmallest(uint256[] memory _array)  public  returns(uint256){
        uint256 store_var = 1000;
        uint256 i;
        for(i=0;i<3;i++){
            if(store_var> _array[i]){
                store_var = _array[i];
            }
        }
        return store_var;
   }

    function getAddressByGuess(uint256 number) public view returns (address[] memory) {
        return guessToAddress[number];
    }

    // Function to withdraw all Ether from this contract.
    function withdraw() public  {
        require(msg.sender == host , "Only the host can withdraw Ether");
        require(gameEnded == true,"Game has  not ended yet");


        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = winner.call{value: address(this).balance * 10 / 100}("");  // 10% of the balance goes to the host
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer() public  {
        require(gameEnded == true,"Game has  not ended yet");
        require(msg.sender == host || msg.sender == winner, "Only the host or winner can transfer Ether");
        (bool success, ) = winner.call{value: address(this).balance * 90 / 100}("");  // 90% of the balance goes to the winner
        require(success, "Failed to send Ether");
    }
}