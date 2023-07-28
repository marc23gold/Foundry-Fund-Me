//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
 /*
 *Deploy mocks when we are on a local chain 
 *Keep track of contract addresses accross different chains
 */

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }   

    constructor() {
        if(block.chainid  == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) { 
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //price feed address
        /*
        *Deploy mocks
        *Return the mock address 
        */
       vm.startBroadcast(); 
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
       vm.stopBroadcast();

       NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
       return anvilConfig;
    }
}