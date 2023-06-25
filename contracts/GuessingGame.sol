// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.23 <0.9.0;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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
    /*
    * Function to create new GuessingGame
    * @param _feeAmount: amount of Ether in Wei to be wagered
    */
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
    address[] private possibleWinners; 

    uint256 public entryFee;
    uint256 public prizePool;
    bool public gameEnded;

    mapping(address => bytes32) public addressToCommit;
    mapping(bytes32 => address) public commitToAddress;
    mapping(uint256 => address[]) public guessToAddress;

    mapping(address => bool) public hasCommited; // mapping to track player entries
    mapping(address => bool) public hasRevealed; // mapping to track player entries

    bytes32[] public commits;
    uint256[] private diffs;
    uint256[] public guesses;

    uint256 public commitDeadline;
    uint256 public revealDeadline;
    bool public isRevealPhase; 

    bool public hasInitialized;
    bool public hasWithdrawn;
    bool public hasTransferred;
    mapping(address => bool) public hasretrieved; // mapping to track player deposits

    uint256 public gameEndedFactor; // 1 if game ended normally, 2 if game did not find enough players to pay out players

    /*
    *   Function to initialize the contract
    *   @param _owner: address of the owner of the contract
    *  @param _feeAmount: amount of Ether in Wei to be wagered
    */
    function initialize(address _owner, uint256 _feeAmount) external {
        require(_owner != address(0), "Invalid owner address");
        require(_feeAmount > 0, "Invalid fee amount");
        require(hasInitialized == false, "Game has already been initialized");

        hasInitialized = true;
        host = payable(_owner);
        entryFee = _feeAmount; // convert to wei
      
       
        console.log("ola", entryFee);

        isRevealPhase = false;
        gameEnded = false; 
        hasWithdrawn = false;
        hasTransferred = false;
        gameEndedFactor = 1;

        commitDeadline = block.timestamp + 1 days; // set the deadline to 1 day from now

        console.log("Deploying GuessingGame with entry fee: ", entryFee);
        console.log("Deploying GuessingGame with host: ", host);
        console.log("Deploying on address: ", address(this));
    }

 
    /*
    * Function to enter a guess by inserting a hash of the guess and salt
    * @param commitment: hash of the guess and salt
    */
    function commit(bytes32 commitment) public payable {
        require(msg.value  == entryFee *2, "Incorrect fee amount, need to send 2x the entry fee");
        require(msg.sender != host, "Host cannot enter a guess");
        require(hasCommited[msg.sender] == false, "Player has already entered a guess");
        require(gameEnded == false, "Game has already ended");
        require(block.timestamp < commitDeadline, "Game deadline has passed");
        require(isRevealPhase == false, "Reveal phase has already started");
        console.log("Ola");
        addressToCommit[msg.sender] = commitment;
        commitToAddress[commitment] = (msg.sender);
        hasCommited[msg.sender] = true;
        
        commits.push(commitment);      
    }

    /*
    * Function to reveal a guess by inserting the guess and salt
    * @param guess: guess of the player
    * @param salt: salt of the player
    */
   function reveal(uint256 guess,uint256 salt ) public  {
        require(gameEnded == false, "Game has already ended");
        require(hasCommited[msg.sender] == true, "Player has not commited something");
        require(hasRevealed[msg.sender] == false, "Player has already revealed");
        require(isRevealPhase == true, "Reveal phase has not started yet");

        if(keccak256(abi.encodePacked(Strings.toString(guess), Strings.toString(salt)))  == addressToCommit[msg.sender]  ){
            if (guess >= 0 && guess <= 1000){
                guessToAddress[guess].push(msg.sender);
                hasRevealed[msg.sender] = true;
                guesses.push(guess);
            } else {
                require(guess >= 0 && guess <= 1000, "Guess must be between 0 and 1000");
            }
        } else {
            revert("Guess does not match commit");
        }

    }
    /*
    * This starts the second phase of the game: the reveal phase, where everyone may reveal their guesses previously committed
    */
    function startRevealPhase() external {
        require(msg.sender == host || block.timestamp >= commitDeadline, "24 hours have not passed yet or you are not the host");
        require(gameEnded == false, "Game has already ended");
        require(commits.length >= 3, "Wait until at least 3 people have entered commits");
        require(isRevealPhase == false, "Reveal phase has already started");
        prizePool = address(this).balance / 2; //because half of it is from deposits and not to be betted
        isRevealPhase = true;
        revealDeadline = block.timestamp + 1 days; // set the deadline to 1 day from now 
    }

    /*
    * This function concludes the game and determines the winner depending on the guesses revealed
    * If there are multiple winners, the winner is randomly selected
    *  If there are only 2 reveals then the game is still considered finished and everyone may get their deposit + fee back (if revealed)
    */
    function endGame() external {
        require(guesses.length == commits.length|| block.timestamp >= revealDeadline, "24 hours have not passed yet or not everyone has revealed yet");
        require(gameEnded == false, "Game has already ended");
        
        //technically not needed
        if (block.timestamp < revealDeadline && guesses.length < 3) {
            revert("Wait until at least 3 people have entered guesses");
        }

        gameEnded = true;

        if (guesses.length <3){
            gameEndedFactor = 2;
            return;
        } 
        
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
              console.log("diffs: ", diffs[i]);
        }  
        console.log("smallest dif: ",getSmallest(diffs));

        getPossibleWinners(diffs, average); // 

        // check if multiple players chose the same number and if so, randomly select one
        if (possibleWinners.length > 1){
            console.log("endgame_ guessTOAddress:", possibleWinners[0]);
            console.log("endgame_ guessTOAddress:", possibleWinners[1]);
            uint256 winnerIndex = uint256(block.timestamp) % possibleWinners.length;
            winner =  payable(possibleWinners[winnerIndex]);
        } else {
            winner =  payable(possibleWinners[0]);
        }
        console.log("winner is: ", winner );

    } 

    function absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    function getSmallest(uint256[] memory _array)  pure internal  returns(uint256){
        uint256 store_var = 1000;
        uint256 i;
        for(i=0;i<_array.length;i++){
            if(store_var> _array[i]){
                store_var = _array[i];
            }
        }
        return store_var;
   } 

    // There might be multiple players with the same difference to the average, this function gets alls of them 
   function getPossibleWinners(uint256[] memory _diffs,uint256 _average) internal {


        for (uint256 i = 0; i < guesses.length; i++) {
            if (_average + getSmallest(_diffs) == guesses[i]){
                for(uint256 j = 0; j < guessToAddress[guesses[i]].length; j++){ //add every address that guessed the winning number to the possible winners array
                    possibleWinners.push(guessToAddress[guesses[i]][j]);
                }
            }
            // do the same thing but subtract the smallest diff from the average
            if (_average - getSmallest(_diffs) == guesses[i]){
                for(uint256 j = 0; j < guessToAddress[guesses[i]].length; j++){ //add every address that guessed the winning number to the possible winners array
                    possibleWinners.push(guessToAddress[guesses[i]][j]);
                }
            }
        }
   }

    function getAddressByGuess(uint256 number) public view returns (address[] memory) {
        return guessToAddress[number];
    }

    function getCommits() public view returns (uint256 ) {
 
        return commits.length   ;
    }

     function getGuesses() public view returns (uint256 ) {
         
            return guesses.length ;   
    }

    // Function to withdraw  Ether to host from this contract.
    function withdrawServiceFee() external  {
        require(msg.sender == host , "Only the host can withdraw Ether from Service Fee");
        require(gameEnded == true,"Game has not ended yet");
        require(hasWithdrawn == false, "Service fee has already been withdrawn");
        hasWithdrawn = true; 
        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = host.call{value: prizePool * 10 / 100}("");  // 10% of the balance goes to the host
        require(success, "Failed to send Ether");
    }

    /**
     * @dev Function to transfer Ether to winner from this contract.
     * / */
    function claimPrize() external  {
        require(msg.sender == winner, "Only the winner can claim the prize");
        require(gameEnded == true,"Game has not ended yet");
        require(hasTransferred == false, "Prize has already been claimed");
        hasTransferred = true;
        (bool success, ) = winner.call{value:  prizePool * 90 / 100}("");  // 90% of the balance goes to the winner
        require(success, "Failed to send Ether");
    }

     function retrieveDeposit() external  {
        require(hasRevealed[msg.sender], "Only players who have revealed can retrieve their deposit");
        require(gameEnded == true,"Game has not ended yet");
        require(hasretrieved[msg.sender] == false, "Deposit has already been retrieved");
        hasretrieved[msg.sender] = true;
        //Factor depends whether or not game has actually been carried out; 1 if it has, 2 if it has not
        (bool success, ) = msg.sender.call{value:  entryFee * gameEndedFactor}("");  // Since everyone pays 2x the entry fee, we can just send back the entry fee * 1 or 2 (
        require(success, "Failed to send Ether");
    }
}

