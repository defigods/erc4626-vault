// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IStrategy {
    function withdrawFee() external view returns (uint256);

    function WITHDRAWAL_MAX() external view returns (uint256);

    function harvest() external;
}
