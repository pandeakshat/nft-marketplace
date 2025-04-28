require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

const { INFURA_PROJECT_ID, PRIVATE_KEY } = process.env;
const accounts = PRIVATE_KEY ? [PRIVATE_KEY] : [];

module.exports = {
  solidity: {
    compilers: [
      { version: '0.8.18' },   // for your NFTMarketplace.sol
      { version: '0.8.28' }    // for the sample Lock.sol
    ]
  },
  networks: {
    localhost: { url: 'http://127.0.0.1:8545' },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts
    }
  }
};
