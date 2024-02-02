// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.10;

import {Pool} from 'contracts/protocol/pool/Pool.sol';
import {IPoolAddressesProvider} from 'contracts/interfaces/IPoolAddressesProvider.sol';
import {DataTypes} from 'contracts/protocol/libraries/types/DataTypes.sol';

contract PoolHarness is Pool {
  struct UserConfigurationMap {
    uint256 data;
  }

  struct EModeCategory {
    // each eMode category has a custom ltv and liquidation threshold
    uint16 ltv;
    uint16 liquidationThreshold;
    uint16 liquidationBonus;
    // each eMode category may or may not have a custom oracle to override the individual assets price oracles
    address priceSource;
    string label;
  }

  struct CalculateInterestRatesParams {
    uint256 unbacked;
    uint256 liquidityAdded;
    uint256 liquidityTaken;
    uint256 totalStableDebt;
    uint256 totalVariableDebt;
    uint256 averageStableBorrowRate;
    uint256 reserveFactor;
    address reserve;
    address aToken;
  }

  constructor(IPoolAddressesProvider provider) Pool(provider) {}

  function getEModeCategory(uint8 category) external view returns (DataTypes.EModeCategory memory) {
    return _eModeCategories[category];
  }
}
