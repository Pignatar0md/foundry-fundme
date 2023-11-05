// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// deploy mock when we are on a local anvil chain
// keep track of a contract address across different chains

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';

contract HelperConfig is Script {

  // if local anvil ? deploy mocks : grab existing addrs from the live network
  struct NetworkConfig {
    address priceFeed;//eth/usd price feed addr
  }
  NetworkConfig public activeNetworkConfig;
  uint256 public constant SEPOLIA_CHAINID = 11155111;
  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  constructor() {
    if (block.chainid == SEPOLIA_CHAINID) {
      activeNetworkConfig = getSepoliaEthConfig();
    } else if (block.chainid == 1) {
      // activeNetworkConfig = getMainnetEthConfig();
    } else {
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
  }
  
  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    // priceFeed addr
    NetworkConfig memory sepoliaConfig = NetworkConfig({ priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
    return sepoliaConfig;
  }

  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
    if (activeNetworkConfig.priceFeed != address(0)) {
      return activeNetworkConfig;
    }
    // priceFeed addr
    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });

    return anvilConfig;
  }

  // function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
  //   // priceFeed addr
  //   NetworkConfig memory mainnetConfig = NetworkConfig({ priceFeed: 0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419 });
  //   return mainnetConfig;
  // }

}