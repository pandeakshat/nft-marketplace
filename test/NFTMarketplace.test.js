const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarketplace", function () {
  let marketplace, nft;
  let owner, seller, buyer;

  beforeEach(async function () {
    [owner, seller, buyer] = await ethers.getSigners();

    // Deploy the marketplace contract
    const Mkt = await ethers.getContractFactory("NFTMarketplace");
    marketplace = await Mkt.deploy();
    await marketplace.waitForDeployment();

    // Deploy our ERC721 mock
    const Mock = await ethers.getContractFactory("ERC721Mock");
    nft = await Mock.deploy("MockNFT", "MNFT", "https://token-cdn/");
    await nft.waitForDeployment();
  });

  it("mints, lists, and sells an ERC721", async function () {
    // Mint token to seller using deployer (owner has MINTER_ROLE)
    await nft.mint(seller.address);
    const tokenId = 0;

    // Seller approves and lists for 1 ETH
    await nft.connect(seller).approve(marketplace.target, tokenId);
    const price = ethers.parseEther("1");
    await expect(
      marketplace.connect(seller).createMarketItem(nft.target, tokenId, price)
    )
      .to.emit(marketplace, "MarketItemCreated")
      .withArgs(1, nft.target, tokenId, seller.address, price, false);

    // Buyer purchases it
    await expect(
      marketplace.connect(buyer).createMarketSale(1, { value: price })
    )
      .to.emit(marketplace, "MarketItemSold")
      .withArgs(1, buyer.address, price);

    // Ownership has transferred
    expect(await nft.ownerOf(tokenId)).to.equal(buyer.address);

    // No unsold items remain
    const items = await marketplace.fetchMarketItems();
    expect(items.length).to.equal(0);
  });
});
