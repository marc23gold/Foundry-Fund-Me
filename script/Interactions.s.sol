//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
    uint constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {

        vm.startBroadcast();
        
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        
        console.log("Funded the contract with %s", SEND_VALUE);
        vm.stopBroadcast();
    }
    //Fund
    function run() external {
        vm.startBroadcast();
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script{

    //Withdraw
     uint constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address mostRecentlyDeployed) public {

        vm.startBroadcast();
        
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        
       

        console.log("Funded the contract with %s", SEND_VALUE);
         vm.stopBroadcast();

    }
    //Fund
    function run() external {
        
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
        
    }
}