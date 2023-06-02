// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IBalance {
    function balanceOf(address _account) external view returns (uint256);
}
