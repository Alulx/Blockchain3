import { writable, derived, readable } from 'svelte/store';

/**
 * Tracks the currently logged in user.
 */
export const user = writable('No Account Connected');

/* export const test = makeContractStore(SBT_ABI.abi as AbiItem[], contractAddress.SBT);
 */