require('@nomicfoundation/hardhat-toolbox');


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
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 1337, // We set 1337 to make interacting with MetaMask simpler
    },
   
  },
};
