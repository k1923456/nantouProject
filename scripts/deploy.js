const hre = require("hardhat");

async function main() {
  const accounts = await hre.ethers.getSigners();
  const Item1Data = {
    shid: 1234,
    organizationID: 1,
    producedDate: 1637857385,
    expirationDate: 2637857385,
    organization: accounts[0].address,
    name: "茶葉",
    organizationName: "8D Tea",
  };
  const number = 1500;
  const packnumber = 5;
  const unit = "ML";
  const Item = await hre.ethers.getContractFactory("Item");
  const item = await Item.deploy(Item1Data, number, packnumber, unit);

  await item.deployed();

  console.log("Item deployed to:", item.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
