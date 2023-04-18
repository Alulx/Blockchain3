// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;

import "hardhat/console.sol";

contract GuessingGame {
    address payable public host;
    address public winner; 
    uint256 public entryFee;
    mapping(address => uint256) public AddressToGuesses;
    
    uint256[] guesses;
    uint256[] diffs;

    uint256 public gameEndTime;
    uint256 public gameCreationTime;    
    uint256 public numberOfGuesses;

    constructor(uint256 _feeAmount) {
        host = payable(msg.sender);
        entryFee = _feeAmount;
    }

    function guess(uint256 _guess) public payable {
        require(msg.value == entryFee, "Incorrect fee amount");
        require(AddressToGuesses[msg.sender] == 0, "Player has already entered a guess");
        require(guess <= 1000 && guess >= 0, "Guess must be between 0 and 1000");

        AddressToGuesses[msg.sender] = _guess;
        guesses[numberOfGuesses] = _guess;
        numberOfGuesses += 1;
        if (numberOfGuesses== 3) {
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
        uint256 avergae = ((guesses[0] + guesses[1] + guesses[2]) / 3 ) *0.66;
        console.log("average number is: ", avergae);

        for (uint256 i = 0; i < 3; i++) {
           uint diff = absDiff(guesses[i], avergae);
              diffs[i] = diff;
        }
        uint256 winningNumber = getLargest();
        console.log("winning number is: ", winningNumber);


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

    function getLargest(uint256[] _array) public view returns(uint){
        uint store_var = 0;
        uint i;
        for(i=0;i<3;i++){
            if(store_var<_array[i]){
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