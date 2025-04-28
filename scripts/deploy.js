const hre = require("hardhat");
require('dotenv').config();

async function main() {
  // Get the contract factory
  const { ethers } = hre;
  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");

  console.log("Deploying NFTMarketplace contract...");
  // Deploy the contract
  const marketplace = await NFTMarketplace.deploy();

  // Wait for the deployment to be mined
  await marketplace.waitForDeployment();

  // Log the deployed address
  console.log(`NFTMarketplace deployed to: ${marketplace.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// Usage:
// npx hardhat run scripts/deploy.js --network localhost
// npx hardhat run scripts/deploy.js --network goerli
// npx hardhat run scripts/deploy.js --network mumbai