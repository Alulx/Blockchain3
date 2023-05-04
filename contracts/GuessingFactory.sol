// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import "hardhat/console.sol";
import './GuessingGame.sol';

contract GuessingFactory  {
    event GameCreated(address indexed newGame, uint256 gameId);

    mapping(address => GuessingGame) public addressToGame;
    address public implementationAddress;

    constructor(address _implementationAddress) {
        implementationAddress = _implementationAddress;
        console.log("Deploying GuessingFactory with implementation at: ", implementationAddress);
    }
    
     function createGame() public payable {
        //Creating a new crew object, you need to pay //for the deployment of this contract everytime - $$$$
        GuessingGame guessingGameAddress = GuessingGame(Clones.clone(implementationAddress));

        // since the clone create a proxy, the constructor is redundant and you have to use the initialize function
        guessingGame.init(msg.sender, msg.value); 

        //Adding the new crew to our list of crew addresses
        games.push(guessingGameAddress);

        emit GameCreated(msg.sender, 1);
    } 

     function getGames() external view returns(GuessingGame[] memory){
         return games;
     }
}