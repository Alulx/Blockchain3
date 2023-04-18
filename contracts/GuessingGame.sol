// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "hardhat/console.sol";


contract GuessingGame {
    address payable public host;
    address public winner; 
    uint256 public entryFee;
    mapping(address => uint256) public AddressToGuesses;
    uint256[] guesses;

    bool public gameEnded;
    uint256 public winningNumber;
    uint256 public totalPrizePool;
    uint256 public gameEndTime;
    uint256 public gameCreationTime;    
    uint256 public numberOfGuesses;


    function init(address _host, uint256 _entryFee) external {
        console.log("init game");
        host = payable(_host);
        entryFee = _entryFee;
        gameEndTime = block.timestamp + 1 days;
         numberOfGuesses = 0; 
        gameEnded = false;
        gameCreationTime = block.timestamp; // Set the game creation time
    }

    function makeGuess(uint256 guess) external payable {
        require(!gameEnded, "Game has already ended");
        require(msg.value >= entryFee, "Entry fee not met");
        require(block.timestamp >= gameEndTime, "Game has not yet ended");
        require(guess <= 1000 && guess >= 0, "Guess must be between 0 and 1000");
        
        console.log("ola");
        AddressToGuesses[msg.sender] = guess;
        guesses[numberOfGuesses] = guess; 
        numberOfGuesses += 1; 
        totalPrizePool += msg.value;

        if ( numberOfGuesses == 3 ){
            endGame();
        }
    }

    function endGame() internal {

 /*        gameEnded = true;
        winningNumber = ((guesses[0] + guesses[1] + guesses[2]) / 3 ) *0.66;

        for (uint256 i = 0; i < 3; i++) {
           uint diff = absDiff(guesses[i], winningNumber);
           
        }

        // Transfer fee to host
        uint256 fee = totalPrizePool * 0.9;
        host.transfer(fee);
        */
    } 

    function absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    function withdrawPrizePool() external {
        require(gameEnded, "Game has not yet ended");
        require( winner  == msg.sender, "You did not win the game");
    }

    function claimRemainingBalance() external {
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
    }

}