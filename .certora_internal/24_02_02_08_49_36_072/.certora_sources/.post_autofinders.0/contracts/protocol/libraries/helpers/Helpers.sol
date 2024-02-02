// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.10;

import {IERC20} from '../../../dependencies/openzeppelin/contracts/IERC20.sol';
import {Errors} from './Errors.sol';
import {DataTypes} from '../types/DataTypes.sol';

/**
 * @title Helpers library
 * @author Aave
 */
library Helpers {
  /**
   * @notice Fetches the user current stable and variable debt balances
   * @param user The user address
   * @param reserve The reserve data object
   * @return The stable debt balance
   * @return The variable debt balance
   **/
  function getUserCurrentDebt(address user, DataTypes.ReserveData storage reserve)
    internal
    view
    returns (uint256, uint256)
  {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003c0000, 1037618708540) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003c0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003c0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003c6001, reserve.slot) }
    return (
      IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  /**
   * @notice Fetches the user current stable and variable debt balances
   * @param user The user address
   * @param reserve The reserve data object
   * @return The stable debt balance
   * @return The variable debt balance
   **/
  function getUserCurrentDebtMemory(address user, DataTypes.ReserveData memory reserve)
    internal
    view
    returns (uint256, uint256)
  {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003d0000, 1037618708541) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003d0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003d0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003d6001, reserve) }
    return (
      IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  function castUint128(uint256 input) internal pure returns (uint128) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003e0000, 1037618708542) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003e0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003e0005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003e6000, input) }
    require(input <= type(uint128).max, Errors.HLP_UINT128_OVERFLOW);
    return uint128(input);
  }
}
