// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IBooster {
    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function getReward() external;
}
