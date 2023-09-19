// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import "../src/FundMe.sol";
import "../script/DeployFundMe.s.sol";
import "../script/Interactions.s.sol";

contract InteractionsTest is Test {

    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether; 
    uint256 constant GAS_PRICE = 1;
    //address public constant USER = address(1);

    function setUp() external {
       DeployFundMe deploy = new DeployFundMe(); 
        fundMe = deploy.run();
        vm.deal(USER, 100 ether);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundeMe = new FundFundMe();
        fundFundeMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
}