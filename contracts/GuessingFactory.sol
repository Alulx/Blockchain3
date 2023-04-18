// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";
import './CloneFactory.sol';
import './GuessingGame.sol';

contract GuessingFactory is CloneFactory, Ownable {
    event GameCreated(address indexed host, uint256 gameId);

    GuessingGame[] public games;
    address masterContract;

   constructor(address _masterContract) {
        masterContract = _masterContract;
    }
    function createGame(uint256 gameId) public payable {
        uint256 entryFee = msg.value;
        require(msg.value > 0, "Entry fee must be greater than zero");
        console.log(entryFee);
                console.log("contract address: ", masterContract);

        GuessingGame host = GuessingGame(createClone(masterContract));
        console.log(msg.sender);
        host.init(msg.sender, entryFee);
        
        games.push(host);


        emit GameCreated(msg.sender, gameId);
    }

     function getGames() external view returns(GuessingGame[] memory){
         return games;
     }
}