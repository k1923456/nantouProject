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
      const Item1Data = {
        shid: 1234,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization,
        name: "茶葉",
        organizationName: "8D Tea",
      };
      const number = 1500;
      const packnumber = 5;
      const unit = "ML";
      const item1 = await Item.new(Item1Data, number, packnumber, unit, {
        from: organization,
      });
      console.log(`Item1 address is ${item1.address}`)

      const Item2Data = {
        shid: 1235,
        organizationID: 1,
        producedDate: 1637857385,
        expirationDate: 2637857385,
        organization: organization,
        name: "茶葉",
        organizationName: "8D Tea",
      };
      const number2 = 1500;
      const packnumber2 = 5;
      const unit2 = "ML";
      const item2 = await Item.new(Item2Data, number2, packnumber2, unit2, {
        from: organization,
      });
      console.log(`Item2 address is ${item2.address}`)

      const item1Dests = [
        {
          shid: 1235,
          phid: 0,
          usedItem: item2.address,
          usedNumber: 50,
        },
      ];
      await item1.addDests(item1Dests);
      console.log(await item1.destination(item2.address))
      const item2Sources = [
        {
          shid: 1234,
          phid: 0,
          usedItem: item1.address,
          usedNumber: 50,
        },
      ];
      await item2.addSources(item2Sources);
    });
  });
});
