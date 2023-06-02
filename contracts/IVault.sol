// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault is IERC20 {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function balance() external view returns (uint256);

    function want() external view returns (IERC20);

    function strategy() external view returns (address);
}
