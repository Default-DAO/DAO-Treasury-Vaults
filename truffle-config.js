require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraKey = "https://kovan.infura.io/v3/365762272fac45ed9040f1e26b331f9c";


module.exports = {
  networks: {
    development: {
      network_id: '*',
      host: 'localhost',
      port: process.env.PORT
    },
    main: {
      provider: function() {
        return new HDWalletProvider(
          //private keys array
          process.env.MNEMONIC,
          //url to ethereum node
          process.env.WEB3_PROVIDER_ADDRESS
        )
      },
      network_id: 1,
      gas: 4000000,
      gasPrice: 200000000000,
      confirmations: 2,
      websockets: true
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(
          //private keys array
          mnemonic,
          //url to ethereum node
          infuraKey
        )
      },
      network_id: 42,
      gas: 12450000,
      gasPrice: 20000000000,
      confirmations: 2,
      skipDryRun: false
    },
    bsctestnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: 'VHCGJHCCBIQTQSQ2FEWNGKQF4TE7YYMNGE'
  }
};