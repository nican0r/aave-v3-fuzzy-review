// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.10;

import {Errors} from '../helpers/Errors.sol';

/**
 * @title WadRayMath library
 * @author Aave
 * @notice Provides functions to perform calculations with Wad and Ray units
 * @dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 **/
library WadRayMath {
  // HALF_WAD and HALF_RAY expressed with extended notation as constant with operations are not supported in Yul assembly
  uint256 internal constant WAD = 1e18;
  uint256 internal constant HALF_WAD = 500000000000000000;

  uint256 public constant RAY = 1e27;
  uint256 internal constant HALF_RAY = 500000000000000000000000000;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  /**
   * @return One wad, 1e18
   **/

  function wad() internal pure returns (uint256) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dc0000, 1037618708700) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dc0001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dc0004, 0) }
    return WAD;
  }

  /**
   * @return Half ray, 1e27/2
   **/
  function halfRay() internal pure returns (uint256) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dd0000, 1037618708701) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dd0001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00dd0004, 0) }
    return HALF_RAY;
  }

  /**
   * @return Half ray, 1e18/2
   **/
  function halfWad() internal pure returns (uint256) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00df0000, 1037618708703) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00df0001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00df0004, 0) }
    return HALF_WAD;
  }

  /**
   * @dev Multiplies two wad, rounding half up to the nearest wad
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Wad
   * @param b Wad
   * @return c = a*b, in wad
   **/
  function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e00000, 1037618708704) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e00001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e00005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e06001, b) }
    // to avoid overflow, a <= (type(uint256).max - HALF_WAD) / b
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))) {
        revert(0, 0)
      }

      c := div(add(mul(a, b), HALF_WAD), WAD)
    }
  }

  /**
   * @dev Divides two wad, rounding half up to the nearest wad
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Wad
   * @param b Wad
   * @return c = a/b, in wad
   **/
  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00de0000, 1037618708702) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00de0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00de0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00de6001, b) }
    // to avoid overflow, a <= (type(uint256).max - halfB) / WAD
    assembly {
      if iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD)))) {
        revert(0, 0)
      }

      c := div(add(mul(a, WAD), div(b, 2)), b)
    }
  }

  /**
   * @notice Multiplies two ray, rounding half up to the nearest ray
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Ray
   * @param b Ray
   * @return c = a raymul b
   **/
  function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e10000, 1037618708705) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e10001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e10005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e16001, b) }
    // to avoid overflow, a <= (type(uint256).max - HALF_RAY) / b
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))) {
        revert(0, 0)
      }

      c := div(add(mul(a, b), HALF_RAY), RAY)
    }
  }

  /**
   * @notice Divides two ray, rounding half up to the nearest ray
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Ray
   * @param b Ray
   * @return c = a raydiv b
   **/
  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e20000, 1037618708706) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e20001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e20005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e26001, b) }
    // to avoid overflow, a <= (type(uint256).max - halfB) / RAY
    assembly {
      if iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY)))) {
        revert(0, 0)
      }

      c := div(add(mul(a, RAY), div(b, 2)), b)
    }
  }

  /**
   * @dev Casts ray down to wad
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Ray
   * @return b = a converted to wad, rounded half up to the nearest wad
   **/
  function rayToWad(uint256 a) internal pure returns (uint256 b) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e30000, 1037618708707) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e30001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e30005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e36000, a) }
    // to avoid overflow, a + HALF_RAY_RATIO >= HALF_RAY_RATIO
    assembly {
      b := add(a, div(WAD_RAY_RATIO, 2))
      if lt(b, div(WAD_RAY_RATIO, 2)) {
        revert(0, 0)
      }
      b := div(b, WAD_RAY_RATIO)
    }
  }

  /**
   * @dev Converts wad up to ray
   * @dev assembly optimized for improved gas savings, see https://twitter.com/transmissions11/status/1451131036377571328
   * @param a Wad
   * @return b = a converted in ray
   **/
  function wadToRay(uint256 a) internal pure returns (uint256 b) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e40000, 1037618708708) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e40001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e40005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00e46000, a) }
    // to avoid overflow, b/WAD_RAY_RATIO == a
    assembly {
      b := mul(a, WAD_RAY_RATIO)

      if iszero(eq(div(b, WAD_RAY_RATIO), a)) {
        revert(0, 0)
      }
    }
  }
}
