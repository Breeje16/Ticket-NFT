// Import ethers from Hardhat package
const { ethers } = require("hardhat");

async function main() {
  /*
A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
so nftContract here is a factory for instances of our GameItem contract.
*/
  const ticketNftContract = await ethers.getContractFactory("TicketNFT");

  // here we deploy the contract
  const deployedticketNFTContract = await ticketNftContract.deploy();

  // wait for the contract to deploy
  await deployedticketNFTContract.deployed();

  // print the address of the deployed contract
  console.log("Ticket NFT Contract Address:", deployedticketNFTContract.address);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });