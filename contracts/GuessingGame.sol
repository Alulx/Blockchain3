// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;

import "hardhat/console.sol";

contract GuessingGame {
    address payable public host;
    address public winner; 
    uint256 public entryFee;
    mapping(uint256 => address) public guessToAddress;
    mapping(address => bool) public hasEntered; // mapping to track player entries

    uint256[] public guesses;
    uint256[] public diffs;

    uint256 public gameEndTime;
    uint256 public gameCreationTime;    

    constructor(uint256 _feeAmount) {
        host = payable(msg.sender);
        entryFee = _feeAmount;
        console.log("Deploying GuessingGame with entry fee: ", entryFee);
        console.log("Deploying GuessingGame with host: ", host);
    }

    function guess(uint256 _guess) public payable {
        require(msg.value == entryFee, "Incorrect fee amount");
        require(hasEntered[msg.sender] == false, "Player has already entered a guess");
        require(_guess <= 1000 && _guess >= 0, "Guess must be between 0 and 1000");
        require(guesses.length < 3, "Game has already ended");

        guessToAddress[_guess] = msg.sender;
        hasEntered[msg.sender] = true;

        guesses.push(_guess);

        if (guesses.length == 3) {
            endGame();
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

   
    function endGame() internal {
        uint256 average = (guesses[0] + guesses[1] + guesses[2]);
         average /= 3; //average
         average = (average * 66) / 100; //get two thirds
         console.log("average number is: ", average);
        
        diffs = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
           uint diff = absDiff(guesses[i], average);
              diffs[i] = diff;
        }  
        uint256 winningNumber = getLargest(diffs) + average;
        console.log("winning number is: ", winningNumber );
        console.log("winner is: ", guessToAddress[winningNumber] );
        //payout winner

        
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

    function getLargest(uint256[] memory _array)  public  returns(uint256){
        uint256 store_var = 0;
        uint256 i;
        for(i=0;i<3;i++){
            console.log("array is: ", _array[0]);
            if(store_var< _array[i]){
                store_var = _array[i];
            }
        }
        return store_var;
   }

    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = host.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}