// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol"

import "hardhat/console.sol";
import './CloneFactory.sol';
import './GuessingGame.sol';

contract GuessingFactory is CloneFactory {
    event GameCreated(address indexed newGame, uint256 gameId);

    GuessingGame[] public games;
    address public implementationAddress;

    constructor(address _implementationAddress) {
        implementationAddress = _implementationAddress;
    }
    
    function createGame(uint256 gameId) public payable {
        //Creating a new crew object, you need to pay //for the deployment of this contract everytime - $$$$
        GuessingGame guessingGameAddress = GuessingGame(Clones.clone(implementationAddress));

        // since the clone create a proxy, the constructor is redundant and you have to use the initialize function
        guessingGameAddress.initialize(); 

        //Adding the new crew to our list of crew addresses
        GuessingGame.push(guessingGame);

        emit GameCreated(msg.sender, gameId);
    }

     function getGames() external view returns(GuessingGame[] memory){
         return games;
     }
}