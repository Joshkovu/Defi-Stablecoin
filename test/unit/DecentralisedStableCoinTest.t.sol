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

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin decentralizedStableCoin;
    address user = makeAddr("user");
    uint256 starting_balance = 100;

    function setUp() public {
        decentralizedStableCoin = new DecentralizedStableCoin();
    }

    function testBurn() public {
        vm.prank(user);
        uint256 amount = 100;
        decentralizedStableCoin.burn(amount);

        assertEq(starting_balance, amount);
    }
}
