// SPDX-License-Identifier:MIT

// Layout of Contract:
// license
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title DecentralizedStableCoin contract
 * @author Kuteesa Joash
 * @notice This contract is meant to be governed by DSCEngine and is just the ERC20 implementation of our stablecoin system.
 * Collateral: Exogenous (ETH & BTC)
 * Minting:Algorithmic
 * Relative Stability:Pegged to USD
 */
contract DecentralizedStableCoin is ERC20Burnable {
    constructor() ERC20("DecentralizedStableCoin", "DSC") {}
}
