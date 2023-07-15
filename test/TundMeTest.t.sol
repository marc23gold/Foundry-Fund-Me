//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test, FundMe{
    FundMe fundMe;
    function setUp() external {
        // set up test environment
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public {
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);   
        assertEq(fundMe.i_owner(),address (this));
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

}