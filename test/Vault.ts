import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { network } from "hardhat";
import { Vault } from "../typechain-types";

describe("Vault", function () {
  let token: Contract;
  let vault: Vault;
  let alice: SignerWithAddress;
  const amount = 10000;

  const wallet = "0x6cb4890d712c91020df2e62fb7bb869ce6ca3e8a";

  beforeEach(async function () {
    const asset = "0x4a77ef015ddcd972fd9ba2c7d5d658689d090f1a";
    const beefyVault = "0x108a7474461dC3059E4a6f9F8c7C8612056195A7";
    const beefyBooster = "0x022221f19a2ed9124c5c9b9f19a58eb6da2c018e";

    const name = "VaultToken";
    const symbol = "VT";

    token = await ethers.getContractAt("MockToken", asset);

    const Vault = await ethers.getContractFactory("Vault");
    vault = await Vault.deploy(beefyVault, beefyBooster, asset, name, symbol);
  });

  describe("Deposit", async function () {
    it("Should deposit correct amount", async function () {
      await network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [wallet],
      });

      alice = await ethers.getSigner(wallet);

      //Approving tokens for deposit
      await token.connect(alice).approve(vault.address, amount);

      const balanceBefore = await token.balanceOf(alice.address);
      await vault.connect(alice).deposit(amount, alice.address);

      const balanceAfter = await token.balanceOf(alice.address);
      expect(balanceBefore).to.be.equal(balanceAfter.add(amount));
    });
  });

  describe("Withdraw", async function () {
    it("Should withdraw tokens", async function () {
      await network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [wallet],
      });

      alice = await ethers.getSigner(wallet);

      //Approving tokens for deposit
      await token.connect(alice).approve(vault.address, amount);

      const balanceBefore = await token.balanceOf(alice.address);
      await vault.connect(alice).deposit(amount, alice.address);

      const maxWithdraw = await vault.maxWithdraw(alice.address);
      await vault
        .connect(alice)
        .withdraw(maxWithdraw, alice.address, alice.address);

      const balanceAfter = await token.balanceOf(alice.address);
      expect(balanceBefore).to.be.closeTo(balanceAfter, 1);
    });
  });
});
