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
  {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b80000, 1037618708664) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b80001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b80005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b86001, reserve.slot) }
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
  {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b90000, 1037618708665) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b90001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b90005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00b96001, reserve) }
    return (
      IERC20(reserve.stableDebtTokenAddress).balanceOf(user),
      IERC20(reserve.variableDebtTokenAddress).balanceOf(user)
    );
  }

  function castUint128(uint256 input) internal pure returns (uint128) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00ba0000, 1037618708666) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00ba0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00ba0005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00ba6000, input) }
    require(input <= type(uint128).max, Errors.HLP_UINT128_OVERFLOW);
    return uint128(input);
  }
}
