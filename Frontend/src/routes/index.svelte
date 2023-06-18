<script lang="ts">
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";

 import Game_ABI from "../contracts/guessinggame.json";
import proxyContractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

$: if (connected) {
    console.log(new Date().toLocaleDateString("en-GB"))
}
let fee: number;
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
}


async function createGameFront(){
    //Fee should be positive number only, so not empty and no characters
    if (fee < 0 || fee == null ) {
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
            isRevealPhase: await contract.methods.isRevealPhase().call()
        }
        console.log("game: ",Games[i]);
    
    }
}

async function joinGame(){
   /*  evm.attachContract('guessinggamecontract',game, Game_ABI.abi as AbiItem[])
    console.log("game: ",game);
    console.log("game contract: ",$contracts.guessinggamecontract);
    console.log("game contract: ",$contracts.guessinggamecontract.methods);
    console.log("game contract: ",$contracts.guessinggamecontract.methods.getGameInfo().call());
 */
}

async function claimPrize(){
    //TODO
}

async function claimServiceFee(){
    //TODO
}

async function claimDeposit(){
    //TODO
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
                                <span class="text  pl-2 pr-2 text-white">Commit Until: {new Date(Number(game.deadlineCommit)).toLocaleDateString("en-GB")}</span>
                            {:else}
                                <span class="text  pl-2 pr-2 text-white">Reveal until: {new Date(Number(game.deadlineReveal )).toLocaleDateString("en-GB")}</span>
                            {/if}
                            {#if !game.gameEnded}
                                <button class="btn btn-accent btn-sm "
                                    on:click={joinGame}
                                    ><span class=" text-lg text-white">Join</span>
                                </button>
                                
                                
                                
                            {:else}
                                <span class="text pt-2 pl-2 pr-2 text-white">Game Ended you may claim remaining funds</span>
                                {#if game.host == $selectedAccount}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={claimServiceFee}
                                        ><span class="text-lg text-white">Withdraw Service Fee</span>
                                    </button> 
                                {/if}
                                {#if game.winner = $selectedAccount}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={claimPrize}
                                        ><span class="text-lg text-white">Claim Prize</span>
                                    </button>
                                {:else}
                                    <button class="btn btn-accent btn-sm "
                                        on:click={claimDeposit}
                                        ><span class="text-lg text-white">Retrieve Deposit</span>
                                    </button>
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
   