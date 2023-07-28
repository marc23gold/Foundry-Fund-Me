//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol"; 

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint constant ETH = 0.1 ether;
    uint constant START = 10 ether;


    function setUp() external {
        // set up test environment
       DeployFundMe deployFundMe = new DeployFundMe();
       fundMe = deployFundMe.run();
       vm.deal(USER, START);
    }   

    function testMinimumDollarIsFive() public {
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);   
        assertEq(fundMe.i_owner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public payable {
        vm.expectRevert(); //next line should revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //next tx will be sent by user
        fundMe.fund{value:ETH}();
        uint amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, ETH);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); //next tx will be sent by user
        fundMe.fund{value:ETH}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); 
    }

    modifier funded() {
        vm.prank(USER); //next tx will be sent by user
        fundMe.fund{value:ETH}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //next tx will be sent by user
        vm.expectRevert(); //next line should revert
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;
        //Act
        //Assert 
    }

}