<script lang="ts">
import NavigationBar from '../lib/layout/navigation-bar.svelte';
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";
import Game_ABI from "../contracts/guessinggame.json";
import proxyContractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

let factoryContract: any;
let fee: number;
$: getGames();
let testGames: Game[] = [];
let activeGames: Game[] = [];
$: activeGames = testGames.filter(game => !game.gameEnded);
$: console.log("test  Games:", testGames);
evm.attachContract('guessingfactorycontract',proxyContractAddress.proxyFactory, Factory_ABI.abi as AbiItem[])

interface Game {
    fee: number;
    gameEnded: boolean;
    host: string;

}


async function createGameFront(){
    //Fee should be positive number only, so not empty and no characters
    if (fee < 0 || fee == null ) {
        alert("Please enter a positive betting amount");
        return;
    }
    activeGames.push({fee: fee, gameEnded: true, host: "test"});

   
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
    // games = await $contracts.guessingfactorycontract.methods.getGames().call();
    const game1: Game = {fee: 11, gameEnded: false, host: "0x0324872tz8bsaldjf83"}
    const game2: Game = {fee: 20, gameEnded: false, host: "0xGAMER2"}
    const game3: Game = {fee: 20, gameEnded: true, host: "0xGAMER3"}

    testGames.push(game1);
    //testGames.pop();

    //it looks stupid but is best practice, trust me 
    testGames = testGames;
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
                placeholder="Betting Amount"
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
                {#if activeGames != undefined && activeGames.length > 0}
                    {#each activeGames as game}
                        <div class="flex flex-col border-2 bg-secondary  border-orange-600 ">
                            <span class="text pt-2 pl-2 pr-2 text-white">Host: {game.host}</span>
                            <span class="flex text  p-2 pr-2  text-white">EntryFee: {game.fee} <img src="/img/eth.png"  width=30 height=20 alt="ether" /> </span>

                            <button class="btn btn-accent btn-sm "
                                on:click={joinGame}
                                ><span class=" text-lg text-white">Join</span>
                            </button>
                        </div>
                    {/each}
                {:else}
                    <span  style="text-align:center" class="  text-5xl  text-white">There are currently no active games </span>
                {/if} 
            </div>
        </div>
        
    </div> 
  
</div>
   