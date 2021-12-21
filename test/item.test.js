/* global artifacts, contract */
const { ethers } = require("hardhat");
const {
  BN,
  expectRevert,
  expectEvent,
  constants,
  balance,
} = require("@openzeppelin/test-helpers");
const { ZERO_ADDRESS } = constants;
const { expect } = require("chai");
// const Item = artifacts.require("contracts/Item.sol:Item");
let Item;
const itemJSON = require('../artifacts/contracts/Item.sol/Item.json')

contract("MSStaking", () => {

  beforeEach(async () => {
    Item = await new ethers.ContractFactory(
      itemJSON.abi,
      itemJSON.bytecode,
    );
    // console.log(Item)
  })

  describe("Item Test", function () {
    it("Test decrease", async function () {
      let accounts = await ethers.getSigners();
      const [organization, procedure, owner] = accounts;
      console.log(organization)
      // await organization.unlock()
      const item1Data = {
        shid: 1234,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization.address,
        name: "茶葉",
        organizationName: "8D Tea",
      };
      const item1Quantity = {
        producedNumber: 1500,
        restNumber: 1500,
        packNumber: 5,
        unit: "ML",
      };
      const item1 = await Item.connect(organization).deploy(item1Data, item1Quantity);
      await item1.deployed();
      console.log(`Item1 address is ${item1.address}`);

      const item2Data = {
        shid: 1235,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization.address,
        name: "茶葉",
        organizationName: "8D Tea22",
      };
      const item2Quantity = {
        producedNumber: 900,
        restNumber: 900,
        packNumber: 3,
        unit: "ML",
      };

      // Create item2 with source item1
      const item2 = await Item.connect(organization).deploy(item2Data, item2Quantity);
      console.log(`Item2 address is ${item2.address}`);
      const item1Dests = [
        {
          id: "1235",
          usedObject: item2.address,
          usedNumber: "50",
          isDeleted: false
        },
      ];
      const tx1 = await item1.addDests(item1Dests);
      await tx1.wait(1)
      // console.log(tx1)
      // console.log(await item1.isDestination(item2.address));
      console.log(await item1.getDestinationList());
      const item2Sources = [
        {
          id: 1234,
          usedObject: item1.address,
          usedNumber: 50,
          isDeleted: false
        },
      ];
      const tx2 = await item2.addSources(item2Sources);
      console.log(tx2)
      await tx2.wait()
      // console.log(await item2.getSourceList())
      const item1QuantityAfter = await item1.quantity();
      expect(item1QuantityAfter.restNumber.toString()).to.equal('1450');

      // delete Item2
      const tx3 = await item1.delDest(item2.address);
      await tx3.wait(1);
      const item1destinationList = await item1.getDestinationList();
      console.log(item1destinationList);
      expect(item1destinationList[0].isDeleted).to.equal(true);
      const tx4 = await item2.destruct(organization.address);
      await tx4.wait(1);
      expect(await ethers.provider.getCode(item2.address)).to.equal("0x");
      const item1QuantityAfter2 = await item1.quantity();
      expect(item1QuantityAfter2.restNumber.toString()).to.equal('1500');
    });
  });
});
