import { AttackVulnerable, AttackGuarded } from "../typechain-types";
import { ethers } from "hardhat"
const { expect } = require("chai");

describe("Deploy Vulnerable Contract", async function () {
    var vulnerableContract: AttackVulnerable;
    it("Successfully deployed Vulnerable Contract", async function () {
        const vulnerableContractFactory =
            await ethers.getContractFactory("AttackVulnerable");
        vulnerableContract = await vulnerableContractFactory.deploy();
    })
    it("Successfully attack", async function () {
        await vulnerableContract.attack(3);
        expect(await vulnerableContract.counter()).to.equal(3);
    })
})

describe("Deploy Guarded Contract", async function () {
    var guardedContract: AttackGuarded;
    it("Successfully deployed Vulnerable Contract", async function () {
        const guardedContractFactory =
            await ethers.getContractFactory("AttackGuarded");
        guardedContract = await guardedContractFactory.deploy();
    })
    it("Revert attack Reentered()", async function () {
        //Deploy test contract to access custom errors.
        const testFactory = await ethers.getContractFactory("Test");
        const testContract = await testFactory.deploy();

        await expect(guardedContract.attack(2)).to.be.revertedWithCustomError(
            testContract,
            'Reentered'
        );
    })
    it("Non-reentrant call successful", async function () {
        await guardedContract.attack(0);
        expect(await guardedContract.counter()).to.be.equal(1);
    })
})


