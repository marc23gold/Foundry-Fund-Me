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
    uint256 constant GAS_PRICE = 1;


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
        uint startingOwnerBalance = fundMe.getOwner().balance; //getting of who ever deploys the contract
        uint startingFundMeBalance = address(fundMe).balance; // getting the balance of the balance
        //Act
        vm.prank(fundMe.getOwner()); //making the next tx be sent by the owner
        fundMe.withdraw(); //withdrawing the funds
        //Assert 
        uint endingOwnerBalance = fundMe.getOwner().balance; //making the ending balance of the 
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //assign
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
             //vm.prank
             //vm.deal
             //address(0)
             hoax(address(i), ETH);
             fundMe.fund{value:ETH}();
             //fund the fundMe

        }
       
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

         //act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed", gasUsed);

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

        function testWithdrawFromMultipleFundersCheaper() public funded {
        //assign
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
             //vm.prank
             //vm.deal
             //address(0)
             hoax(address(i), ETH);
             fundMe.fund{value:ETH}();
             //fund the fundMe

        }
       
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

         //act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed", gasUsed);

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

}