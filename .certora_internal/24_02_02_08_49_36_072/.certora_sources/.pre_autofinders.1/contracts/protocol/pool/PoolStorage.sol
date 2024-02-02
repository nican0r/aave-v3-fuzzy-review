// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.10;

import {UserConfiguration} from '../libraries/configuration/UserConfiguration.sol';
import {ReserveConfiguration} from '../libraries/configuration/ReserveConfiguration.sol';
import {ReserveLogic} from '../libraries/logic/ReserveLogic.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';

/**
 * @title PoolStorage
 * @author Aave
 * @notice Contract used as storage of the Pool contract.
 * @dev It defines the storage layout of the Pool contract.
 */
contract PoolStorage {
  using ReserveLogic for DataTypes.ReserveData;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;
  using UserConfiguration for DataTypes.UserConfigurationMap;

  mapping(address => DataTypes.ReserveData) internal _reserves;
  mapping(address => DataTypes.UserConfigurationMap) internal _usersConfig;

  // the list of the available reserves, structured as a mapping for gas savings reasons
  mapping(uint256 => address) internal _reservesList;
  mapping(uint8 => DataTypes.EModeCategory) _eModeCategories;
  mapping(address => uint8) _usersEModeCategory;

  uint256 internal _bridgeProtocolFee;
  uint128 internal _flashLoanPremiumTotal;
  uint128 internal _flashLoanPremiumToProtocol;

  uint64 internal _maxStableRateBorrowSizePercent;
  uint16 internal _reservesCount;
}
