<script lang="ts">
import NavigationBar from '../lib/layout/navigation-bar.svelte';
import { defaultEvmStores as evm, connected,  web3, contracts , selectedAccount } from 'svelte-web3'
import Factory_ABI from "../contracts/proxyFactory.json";
import contractAddress from "../contracts/proxy-contract-address.json";
import type { AbiItem } from "web3-utils";

let factoryContract: any;
let fee: number 
evm.attachContract('guessingfactorycontract',contractAddress.proxyFactory, Factory_ABI.abi as AbiItem[])


async function createGameFront(){

    if (fee < 0) {
        alert("Please enter a positive betting amount");
        return;
    }
    const id = await $web3.eth.getChainId();
    console.log(id);
    console.log(await $contracts.guessingfactorycontract.methods.logicContractAddress().call());
    const game = await $contracts.guessingfactorycontract.methods.createGame(fee).send({from: $selectedAccount, gas: 3000000});
    console.log(game)
   
    // factoryContract =  new $web3.eth.Contract(Factory_ABI.abi as AbiItem[] , contractAddress.proxyFactory)

}


</script>
    <NavigationBar> </NavigationBar>

<div class=" w-full h-full fixed bg-neutral ">
  
    <div class=" btn btn-accent fixed top-1/2 left-1/2">
    <button
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
    
   
</div> 
  
 
   