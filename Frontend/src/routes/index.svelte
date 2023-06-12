<script lang="ts">
import NavigationBar from '../lib/layout/navigation-bar.svelte';
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";
import Game_ABI from "../contracts/guessinggame.json";
import proxyContractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

let factoryContract: any;
let fee: number;
let games: string[];
// filter games to only include active games by checking where or not the variable gameEnde in the contract is true or false
let activeGames: string[];
evm.attachContract('guessingfactorycontract',proxyContractAddress.proxyFactory, Factory_ABI.abi as AbiItem[])


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
    games = await $contracts.guessingfactorycontract.methods.getGames().call();
    console.log("games: ", games);
  /*   for (let game in games) {
        evm.attachContract('guessinggamecontract',game, Game_ABI.abi as AbiItem[]);
        let gameStatus = await $contracts.guessinggamecontract.methods.gameEnded.call()
        if (gameStatus){
            activeGames.push(game);
        }
    } */
    //attach activegames contract to the guessinggame contract
    console.log("games: ", games);

}

async function joinGame(){
   /*  evm.attachContract('guessinggamecontract',game, Game_ABI.abi as AbiItem[])
    console.log("game: ",game);
    console.log("game contract: ",$contracts.guessinggamecontract);
    console.log("game contract: ",$contracts.guessinggamecontract.methods);
    console.log("game contract: ",$contracts.guessinggamecontract.methods.getGameInfo().call());
 */
}



</script>

<div class="flex flex-col border m-10  h-full ">
  
    <div class="border basis-1/3  ">
        <button class="btn btn-accent btn-lg "
            on:click={createGameFront}
            ><span class=" text-3xl text-white">Create new Game</span>
        </button>
        
        <input
            bind:value={fee}
            type="text"
            placeholder="Betting Amount"
            class="input input-bordered input-accent "
        />
    </div>

    <div class="border basis-2/3  ">
        <button class="btn-rounded  gap-2 btn-accent" 
            on:click={getGames}
            >
            <span class=" text text-white">Refresh &#x21bb</span>
        </button>

        <div class="flex flex-col">
           <!-- if games avaialble show them otherwise say no page online right now -->
      <!--       {#if activeGames.length > 0}
                {#each activeGames as game}
                    <div class="flex flex-row border">
                        <span class="text text-white">Game: {game}</span>
                        <button class="btn btn-accent btn-lg "
                            on:click={joinGame}
                            ><span class=" text-3xl text-white">Join</span>
                        </button>
                    </div>
                {/each}
            {:else}
                <span class="text text-white">No games available</span>
            {/if} -->
        </div>
    </div>
    
</div> 
  
 
   