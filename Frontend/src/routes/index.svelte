<script lang="ts">
import NavigationBar from '../lib/layout/navigation-bar.svelte';
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";
import Game_ABI from "../contracts/guessinggame.json";
import proxyContractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

let factoryContract: any;
let fee: number;
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

    const id = await $web3.eth.getChainId();
    console.log(id);
 
    await $contracts.guessingfactorycontract.methods.createGame(fee).send({from: $selectedAccount, gas: 3000000});
   
    console.log("games: ",await $contracts.guessingfactorycontract.methods.games(0).call());
     await $contracts.guessingfactorycontract.events.NewGame({fromBlock: 0}, (error: any, event: any) => {
        console.log("event: ",event.returnValues);
    }); 
    // factoryContract =  new $web3.eth.Contract(Factory_ABI.abi as AbiItem[] , contractAddress.proxyFactory)

}

async function getGames(){
    //get all elements of the games array in the factory contract
    activeGames = await $contracts.guessingfactorycontract.methods.getGames().call();
    //attach activegames contract to the guessinggame contract
    evm.attachContract('guessinggamecontract',activeGames[0], Game_ABI.abi as AbiItem[])
    console.log("games: ", activeGames);

}
</script>

<div class="flex flex-col border m-5  h-screen ">
  
    <div class="border basis-1/3 ">
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

    <div class="border basis-2/3">
        <button class="btn-rounded gap-2 btn-accent" 
            on:click={getGames}
            >
            <span class=" text text-white">Refresh &#x21bb</span>
        </button>
    </div>
    
</div> 
  
 
   