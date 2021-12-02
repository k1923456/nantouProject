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
        restNumber: 1500,
        maxNumber: 1500,
        maxPackNumber: 5,
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
        restNumber: 900,
        maxNumber: 900,
        maxPackNumber: 3,
        unit: "ML",
      };
      const item2 = await Item.new(item2Data, item2Quantity, {
        from: organization,
      });
      console.log(`Item2 address is ${item2.address}`);

      const item1Dests = [
        {
          shid: 1235,
          phid: 0,
          usedItem: item2.address,
          usedNumber: 50,
        },
      ];
      await item1.addDests(item1Dests);
      console.log(await item1.destination(item2.address));
      const item2Sources = [
        {
          shid: 1234,
          phid: 0,
          usedItem: item1.address,
          usedNumber: 50,
        },
      ];
      await item2.addSources(item2Sources);
      const item1QuantityAfter = await item1.quantity();
      expect(item1QuantityAfter.restNumber).to.bignumber.equal(new BN(1450));
    });
  });
});
