<script lang=ts>
import {  user } from "$lib/stores";


import ButtonPrimary from "$lib/universal/button-primary.svelte";
import TextInput from "$lib/universal/TextInput.svelte";
import { onMount } from "svelte";
import { web3,connected, defaultEvmStores, selectedAccount } from "svelte-web3";

/* defaultEvmStores.attachContract('sbtcontract',contractAddress.SBT, SBT_ABI.abi as AbiItem[])
 */
/**
 * Disconnect all connections form metamask
 */
async function disconnect(){
    await defaultEvmStores.disconnect()
    user.set("No Account Connected")
    localStorage.setItem('isWalletConnected', "false");
}

async function connect(){
        await defaultEvmStores.setProvider() 
        localStorage.setItem('isWalletConnected', "true");
        let address =  await $web3.eth.getAccounts()
        user.set(address[0]);
    }

/**
 *  Check if User is still connected after page reload
*/
onMount(async () => {
		if (localStorage?.getItem('isWalletConnected') === 'true'){
            try{
                console.log("Reconnecting...")
                await defaultEvmStores.setProvider();
                let address = await $web3.eth.getAccounts();
                user.set(address[0]);

                localStorage.setItem('isWalletConnected', "true");
            } catch (ex){
                console.log(ex);
            }
        }
	});

let address: string;

user.subscribe(value => {
    address = value;
});

</script>

<div class="navbar bg-gradient-to-r from-primary via-neutral to-secondary w-full gap-5">
    <p class="btn btn-ghost normal-case text-2xl "><a href ='/' >Guessing Game™</a></p>
    <p class="btn btn-ghost normal-case text-xl "><a href ='/leaderboard' >Leaderboard</a></p>
    <p class="btn btn-ghost normal-case text-xl "><a href ='/leaderboard' >History</a></p>
    <p class="btn btn-ghost normal-case text-xl "><a href ='/leaderboard' >Tournaments</a></p>


    
    <div style="margin-left:auto;" class=" w-auto gap-5">

        {#if $connected}
        <p class="ml-auto">{$selectedAccount}</p>
        {/if}
        {#if $connected}
        <button  on:click={disconnect} class="btn btn-ghost normal-case text-xl">Disconnect </button>
        {:else}
        <button  on:click={connect} class="btn btn-ghost normal-case text-xl">Connect </button>
        {/if}
      
        
    </div>
    
</div>

