// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IVault} from "./IVault.sol";
import {IBooster} from "./IBooster.sol";
import {IBalance} from "./IBalance.sol";
import {IStrategy} from "./IStrategy.sol";

contract Vault is ERC4626 {
    using SafeERC20 for ERC20;
    using Math for uint256;

    IVault public vault;
    IBooster public booster;
    IBalance public iBalance;

    constructor(
        address _vault,
        address _booster,
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC4626(_underlying) {
        vault = IVault(_vault);
        booster = IBooster(_booster);

        _underlying.approve(_vault, type(uint256).max);

        require(
            address(IVault(_vault).want()) == asset(),
            "INVALID Asset or Vault"
        );

        iBalance = _booster == address(0)
            ? IBalance(_vault)
            : IBalance(_booster);

        if (_booster != address(0)) {
            ERC20(_vault).approve(_booster, type(uint256).max);
        }
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        harvest();
        ERC20(asset()).safeTransferFrom(caller, address(this), assets);

        vault.deposit(ERC20(asset()).balanceOf(address(this)));

        _mint(receiver, shares);
        if (address(booster) != address(0)) {
            booster.stake(vault.balanceOf(address(this)));
        }
    }

    function totalAssets() public view virtual override returns (uint256) {
        uint256 _totalShares = iBalance.balanceOf(address(this));

        return
            _totalShares.mulDiv(
                vault.balance(),
                vault.totalSupply(),
                Math.Rounding.Down
            );
    }

    function convertToBeefyShares(
        uint256 shares
    ) public view returns (uint256) {
        return
            totalSupply() == 0
                ? shares
                : shares.mulDiv(
                    iBalance.balanceOf(address(this)),
                    totalSupply(),
                    Math.Rounding.Up
                );
    }

    function previewWithdraw(
        uint256 assets
    ) public view override returns (uint256) {
        IStrategy strat = IStrategy(vault.strategy());
        uint256 fee = strat.withdrawFee();

        uint256 wantBal = assets;
        if (fee != 0) {
            uint256 WITHDRAWAL_MAX = strat.WITHDRAWAL_MAX();

            uint256 withdrawalFeeAmount = (assets * fee) / WITHDRAWAL_MAX;
            wantBal = assets - withdrawalFeeAmount;
        }

        return _convertToShares(wantBal, Math.Rounding.Up);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        harvest();

        uint256 beefyShares = convertToBeefyShares(shares);

        if (address(booster) != address(0)) {
            booster.withdraw(beefyShares);
        }
        IVault(vault).withdraw(beefyShares);

        ERC20(asset()).safeTransfer(receiver, assets);
        _burn(owner, shares);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function harvest() public {
        if (address(booster) != address(0)) {
            booster.getReward();
        }

        IStrategy strat = IStrategy(vault.strategy());
        strat.harvest();
    }
}
