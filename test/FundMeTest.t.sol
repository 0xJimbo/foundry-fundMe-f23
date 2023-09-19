// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import "../src/FundMe.sol";
import "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // this allows us to test in same way as deploying without updating both each time
        vm.deal(USER, 100 ether);
    }

    function testMinUsdIs5() public { 
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log("OWNER", fundMe.getOwner());
        console.log("THIS", address(this));
        // assertEq(fundMe.i_owner(), address(this)); will fail with new deploy method
        assertEq(fundMe.getOwner(), msg.sender);

    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("<<<<Version =", version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //expects next line to revert
        fundMe.fund(); // 0 value
    }

    function testUpdatesFundedDataStructure() public {
        vm.prank(USER); // next tx will be sent by user
        fundMe.fund{value: 10e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18);
    }

    function testAddsFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: 5e18}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:10e18}();
        _;
    }

    function testOnlyOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // arrange 
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingcontractBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // assert
        assertEq(fundMe.getOwner().balance, (startingOwnerBalance + startingcontractBalance));
    }

    function testWithdrawFromMultiplefunders() public funded {
        uint256 noOfFunders = 10; 
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < noOfFunders; i++){
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: 0.1 ether}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingcontractBalance = address(fundMe).balance;
        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // assert
        assertEq(fundMe.getOwner().balance, (startingOwnerBalance + startingcontractBalance));
    }
    // gas cost 487,777
    
        function testWithdrawFromMultiplefundersCheaper() public funded {
        uint256 noOfFunders = 10; 
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < noOfFunders; i++){
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: 0.1 ether}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingcontractBalance = address(fundMe).balance;
        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        // assert
        assertEq(fundMe.getOwner().balance, (startingOwnerBalance + startingcontractBalance));
    }

    // gas cost 486,830













}

