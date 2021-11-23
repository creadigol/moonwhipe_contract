const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic = "Private Key";

module.exports = {
  networks: {
    // development: {
    //   host: '127.0.0.1',
    //   port: 7545,
    //   network_id: '5777'
    // },
    rinkeby: {
      provider: function(){
         return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/4cb959c057d541df891c94432329b7f5") 
      },
      network_id: 4,
      // gas: 5000000,
      // gasPrice: 10000000000,
      skipDryRun: true
    }
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './abis/',
  compilers: {
    solc: {
      version: "^0.8.3",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
