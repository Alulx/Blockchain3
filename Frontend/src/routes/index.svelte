<script lang="ts">
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";

 import Game_ABI from "../contracts/guessinggame.json";
import proxyContractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

$: if (connected) {
    console.log(new Date().toLocaleDateString("en-GB"))
}
let fee: any;
let commit: any;
let guess: any;
let salt: any;
let testGames: string[] = [];
let Games: Game[] = [];
evm.attachContract('guessingfactorycontract',proxyContractAddress.proxyFactory, Factory_ABI.abi as AbiItem[])
interface Game {
    fee: number;
    host: string;
    address: string;
    gameEnded: boolean;
    deadlineCommit: number;
    deadlineReveal: number;
    isRevealPhase: boolean;
    winner: string;
    numCommits: number;
    numReveals: number;
    guess: number;
}


async function createGameFront(){
    //Fee should be positive number only, so not empty and no characters
    if (fee < 0 || fee == '' || !isNaN(fee)) {
        alert("Please enter a positive betting amount");
        return;
    }
   
    let address=  await $contracts.guessingfactorycontract.methods.logicContractAddress().call();
    console.log("address:_ ",address)
   // evm.attachContract('guessinggamecontract',address, Game_ABI.abi as AbiItem[])

 /*    const id = await $web3.eth.getChainId();
    console.log(id); */
 
    await $contracts.guessingfactorycontract.methods.createGame(fee).send({from: $selectedAccount, gas: 3000000});
   
    console.log("games: ",await $contracts.guessingfactorycontract.methods.games(0).call());
     await $contracts.guessingfactorycontract.events.NewGame({fromBlock: 0}, (error: any, event: any) => {
        console.log("event: ",event.returnValues);
    }); 
    // factoryContract =  new $web3.eth.Contract(Factory_ABI.abi as AbiItem[] , contractAddress.proxyFactory)

}

async function getGames(){

    testGames = await $contracts.guessingfactorycontract.methods.getGames().call();
    


    getGameData();
    //it looks stupid but is best practice, trust me (needed to fire the reactive statement above that is dependent on testGames)
    testGames = testGames;
}

async function getGameData(){
    for (let i=0; i<testGames.length; i++){
        console.log("game: ",testGames[0]);
        var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , testGames[i]);
        //instantiate new  Game     
        Games[i] = {
            fee: await contract.methods.entryFee().call(),
            host: await contract.methods.host().call(),
            address: testGames[i],
            gameEnded: await contract.methods.gameEnded().call(),
            deadlineCommit: await contract.methods.commitDeadline().call(),
            deadlineReveal: await contract.methods.revealDeadline().call(),
            isRevealPhase: await contract.methods.isRevealPhase().call(),
            winner: await contract.methods.winner().call(),
            numCommits: await contract.methods.getCommits().call(),
            numReveals: await contract.methods.getGuesses().call(),
            guess: await contracts.methods.getGuesses().call()

        }
        console.log("game: ",Games[i]);
    
    }
}

async function joinGame(game: Game){
    if ( salt == null || commit == null || salt == '' || commit == '') {
        alert("At least one Value is missing");
        return;
    }
    if (!( !isNaN(commit) && commit >= 0  &&  commit <= 1000) ) {
        alert("Please enter a postive betting amount between 0 and 1000");
        return;
    }
 
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    const hash = $web3.utils.sha3(commit + salt)
    console.log("Hash: ",hash);

    await contract.methods.commit(hash).send({from: $selectedAccount, gas: 3000000, value: game.fee *2}); 

}

async function reveal(game: Game){
    if ( salt == null || guess == null || salt == '' || guess == '') {
        alert("At least one Value is missing");
        return;
    }
    if (!( !isNaN(guess) && guess >= 0  &&  guess <= 1000) ) {
        alert("Please enter a postive betting amount between 0 and 1000");
        return;
    }
 
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    await contract.methods.reveal(guess, salt).send({from: $selectedAccount, gas: 3000000});
    console.log("Your guess has been processed!")
}

async function startRevealPhase(game: Game){
    console.log("Starting Revealing Phase...")
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    //start Reveal Phase
    await contract.methods.startRevealPhase().send({from: $selectedAccount, gas: 3000000});
    console.log(await contract.methods.isRevealPhase().call());   
    getGames();
}

async function endGame(game: Game){
    console.log("Ending the game")
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    //start Reveal Phase
    await contract.methods.endGame().send({from: $selectedAccount, gas: 3000000});
    console.log(await contract.methods.gameEnded().call());   
    getGames();
}

async function claimPrize(game: Game){
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    await contract.methods.claimPrize().send({from: $selectedAccount, gas: 3000000});
}

async function claimServiceFee(game: Game){
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    await contract.methods.withdrawServiceFee().send({from: $selectedAccount, gas: 3000000});

}

async function claimDeposit(game: Game){
    var contract = await new $web3.eth.Contract(Game_ABI.abi as AbiItem[] , game.address);
    await contract.methods.retrieveDeposit().send({from: $selectedAccount, gas: 3000000});
}

</script>
<div class="   m-10">
    <div class="bg-neutral  flex flex-col border h-[790px]  ">
        
    
        <div style="display:flex;justify-content:center;align-items:center;" class=" flex-col border basis-1/3   ">
            <button class="btn btn-accent btn-lg "
                on:click={createGameFront}
                ><span class=" text-3xl text-white">Create new Game</span>
            </button>
            
            <input
                bind:value={fee}
                type="text"
                placeholder="Betting Amount in WEI"
                class="input mt-3 input-bordered input-accent "
            />
        </div>

        <div class=" border basis-2/3">
            <button style="margin-left:auto"  class="btn flex m-5 mt-5 btn-rounded btn-accent" 
                on:click={getGames}
                >
                <span class=" text text-white">Refresh &#x21bb</span>
            </button>

            <div class="flex pt-2  gap-5 flex-wrap justify-center  ">
            <!-- if games avaialble show them otherwise say no page online right now -->
                {#if Games != undefined && Games.length > 0}
                    {#each Games as game}
                        <div class="flex flex-col border-2 bg-secondary  border-orange-600 ">
                            <span class="text pt-2 pl-2 pr-2 text-white">Host: {game.host}</span>
                            <span class="flex text  p-2 pr-2  text-white">EntryFee: {game.fee} <img src="/img/eth.png"  width=30 height=20 alt="ether" /> </span>
                            {#if !game.isRevealPhase}
                                <span class="text  pl-2 pr-2 text-white">Commit Until: {new Date(Number(game.deadlineCommit *1000))}</span>
                            {:else}
                                <span class="text  pl-2 pr-2 text-white">Reveal until: {new Date(Number(game.deadlineReveal*1000 ))}</span>
                            {/if}

                            
                            {#if !game.gameEnded}
                                {#if !game.isRevealPhase}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={(event) => joinGame(game)}
                                        ><span class=" text-lg text-white">Commit</span>
                                    </button>
                                    <div class="flex">
                                        <input
                                        bind:value={commit}
                                        type="text"
                                        placeholder="Enter your Guess"
                                        class="input w-1/2 input-bordered input-accent "
                                    />
                                    <input
                                        bind:value={salt}
                                        type="text"
                                        placeholder="Enter a Random Number (SALT)"
                                        class=" input w-1/2 input-bordered input-accent "
                                    />
                                    </div>
                        
                                {:else}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={(event) => reveal(game)}
                                        ><span class=" text-lg text-white">Reveal</span>
                                    </button>  
                                    <div class="flex">
                                        <input
                                        bind:value={guess}
                                        type="text"
                                        placeholder="Enter your Guess from earlier again"
                                        class="input w-1/2 input-bordered input-accent "
                                    />
                                    <input
                                        bind:value={salt}
                                        type="text"
                                        placeholder="Enter your SALT from earlier again"
                                        class=" input w-1/2 input-bordered input-accent "
                                    />
                                    </div>
                                                                 
                                {/if}
                               

                                <span class="flex text  p-2 pr-2  text-white">Number of Commits so far: {game.numCommits} </span>
                                {#if game.host.toLocaleLowerCase() == $selectedAccount && !game.isRevealPhase}
                                    <button class="btn  btn-accent btn-sm "
                                        on:click={(event) => startRevealPhase(game)}
                                        ><span class="text-lg  text-white">Start Reveal Phase</span>
                                    </button>
                                {/if}
                                {#if game.host.toLocaleLowerCase() == $selectedAccount && game.isRevealPhase}
                                    <button class="btn  btn-accent btn-sm "
                                         on:click={(event) => endGame(game)}
                                    ><span class="text-lg  text-white">End the Game</span>
                                    </button>
                                    <span class="flex text  p-2 pr-2  text-white">possible 24h from start from reveal Phase or when everyone has revealed</span>
                                    <span class="flex text  p-2 pr-2  text-white">Number of Reveals needed {game.numCommits - game.numReveals}</span>

                                {/if}
                              
                                
                            {:else}
                                <span class="text pt-2 pl-2 pr-2 text-white">Game Ended you may claim remaining funds</span>
                                <span class="text pt-2 pl-2 pr-2 text-white">Winner was: {game.winner}</span>

                                {#if game.host.toLocaleLowerCase() == $selectedAccount}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={(event) => claimServiceFee(game)}
                                        ><span class="text-lg text-white">Withdraw Service Fee</span>
                                    </button> 
                                {:else}
                                    {#if game.winner.toLocaleLowerCase() == $selectedAccount}
                                    <span class="text pt-2 pl-2 pr-2 text-white">You won! Congratulations!</span>

                                    <button class="btn btn-accent btn-sm "
                                        on:click={(event) => claimPrize(game)}
                                        ><span class="text-lg text-white">Claim Prize</span>
                                    </button>
                                    {:else}
                                        <span class="text pt-2 pl-2 pr-2 text-white">You did not win</span>
                                    {/if}

                                    <button class="btn btn-accent btn-sm "
                                        on:click={(event) => claimDeposit(game)}
                                        ><span class="text-lg text-white">Retrieve Deposit</span>
                                    </button>  
                                    <span class="text pt-2 pl-2 pr-2 text-white">Your Guess was: </span>

                                {/if}
                                                 
                                

                            {/if}
                        </div>
                    {/each}
                {:else}
                    <span  style="text-align:center" class="  text-5xl  text-white">There are currently no active games (Hit Refresh to check for new games)</span>
                {/if} 
            </div>
        </div>
        
    </div> 
  
</div>
   