const Web3 = require('web3')
const fs = require('fs')
const path = require('path')
const Web3HDWalletProvider = require("web3-hdwallet-provider");
const mnemonic = "expand inform intact february false keep bargain relief tissue bounce crime like"
const endpoint = 'https://ropsten.infura.io/v3/8d6c150c2e7c4bacbd59d4ab8e0905fe'
const provider = new Web3HDWalletProvider(mnemonic, endpoint);


// const contractAddress = '0x4d8081104446D2746e313ec58774460A0B52C010' // Too much gas
// const contractAddress = '0x0c20EDa9eBC8fE84f4696601c6AdE22E64327F3F' // 1
const contractAddress = '0xe6859C840E2F5Be1e06B669104ad898D05E2a4B1'

const web3 = new Web3(provider);
const abi = JSON.parse(fs.readFileSync(path.join(__dirname, '../build/contracts/Product.json'))).abi
const from = '0xefE41472125d922AcAC8Ff19365Bdb479C5AcB48'
const gas = 8000000;
const productContract = new web3.eth.Contract(abi, contractAddress);

(async function () {
  const value = await productContract.methods.productName().call();
  console.log(value);
})();

// (async function () {
//   const value = await productContract.methods.operationList(0).call();
//   console.log(value);
// })();

const _operationName = "調理作業(調理作業)"
const _inputNumber = 0
const _outputNumber = 0
const _sourceList = ['0x0c20EDa9eBC8fE84f4696601c6AdE22E64327F3F', '0x4d8081104446D2746e313ec58774460A0B52C010']
const _startTime = 1612715765
const _endTime = 1612725765


productContract.methods.addOperation(_operationName, _inputNumber, _outputNumber, _startTime, _endTime, _sourceList)
  .estimateGas(
    {
      from,
      gasPrice: 1e8
    }).then((gas) => { console.log("Gas Amount is ", gas) })

productContract.methods.addOperation(_operationName, _inputNumber, _outputNumber, _startTime, _endTime, _sourceList)
  .send({ from, gas, gasPrice: 1e8}, function (error, transactionHash) {
    console.log("In Send")
    console.log(error)
    console.log(transactionHash)
    console.log("======================")
  })
  .on('error', function (error) {
    console.log("In error")
    console.log("======================")
  })
  .on('transactionHash', function (transactionHash) {
    console.log("On transactionHash")
    console.log(transactionHash)
    console.log("======================")
  })
  .on('receipt', function (receipt) {
    console.log("On receipt")
    console.log(receipt.contractAddress) // contains the new contract address
    console.log("======================")
  })
  .on('confirmation', function (confirmationNumber, receipt) {
    console.log("On confirmation")
    console.log("======================")
  })
  .then(function (newContractInstance) {
    console.log("Then")
    console.log(newContractInstance.options.address) // instance with the new contract address
    console.log("======================")
  });
