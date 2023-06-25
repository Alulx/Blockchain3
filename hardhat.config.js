
require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

const { ALCHEMY_APIKEY, PRIVATE_KEY } = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      { version: '0.8.18' },
      { version: '0.7.6' },
      { version: '0.9.6' },
      { version: '0.4.23' },
    ],
  },
  defaultNetwork: 'sepolia',
  networks: {
    hardhat: {
      chainId: 1337, // We set 1337 to make interacting with MetaMask simpler
    },
    sepolia: {
      url: ALCHEMY_APIKEY,
      accounts: [`0x${PRIVATE_KEY}`],
    },
   
  },
};
