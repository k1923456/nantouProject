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
const Item = artifacts.require("contracts/Item.sol:Item");

contract("MSStaking", async (accounts) => {
  const [organization, procedure, owner] = accounts;

  describe("Item Test", function () {
    it("Test decrease", async function () {
      const item1Data = {
        shid: 1234,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization,
        name: "茶葉",
        organizationName: "8D Tea",
      };
      const item1Quantity = {
        producedNumber: 1500,
        restNumber: 1500,
        packNumber: 5,
        unit: "ML",
      };
      const item1 = await Item.new(item1Data, item1Quantity, {
        from: organization,
      });
      console.log(`Item1 address is ${item1.address}`);

      const item2Data = {
        shid: 1235,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization,
        name: "茶葉",
        organizationName: "8D Tea22",
      };
      const item2Quantity = {
        producedNumber: 900,
        restNumber: 900,
        packNumber: 3,
        unit: "ML",
      };
      const item2 = await Item.new(item2Data, item2Quantity, {
        from: organization,
      });
      console.log(`Item2 address is ${item2.address}`);

      const item1Dests = [
        {
          id: 1235,
          usedObject: item2.address,
          usedNumber: 50,
        },
      ];
      await item1.addDests(item1Dests);
      console.log(await item1.isDestination(item2.address));
      const item2Sources = [
        {
          id: 1234,
          usedObject: item1.address,
          usedNumber: 50,
        },
      ];
      await item2.addSources(item2Sources);
      const item1QuantityAfter = await item1.quantity();
      expect(item1QuantityAfter.restNumber).to.bignumber.equal(new BN(1450));

      // console.log(await ethers.provider.getCode(item1.address))
      await item1.destruct();
      expect(await ethers.provider.getCode(item1.address)).to.equal("0x")
    });
  });
});
