// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00700000, 1037618708592) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00700001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00700004, 0) }
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {assembly { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00710000, 1037618708593) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00710001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00710004, 0) }
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
