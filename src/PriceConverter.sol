//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //contract address that retrieves the eth price in usd: 	0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e 
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10); //eth price (in usd) x (1x10 a la 18)
    }

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {//40.000.000.000.000.000 wei es igual a 50 usd 
        uint256 ethPrice = getPrice(priceFeed);//ex 1.340 usd
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;// what is 1e18? 1x 10 *18
        return ethAmountInUsd;
    }

}