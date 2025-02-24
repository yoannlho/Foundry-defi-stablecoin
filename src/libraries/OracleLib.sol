//SPDX-license-identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; 

/*
* @title OracleLib
* @author Yoann Lhomme
* @notice This library is used to check the Chainlink Oracle for stale data
* If a price is stable, the function will revert, and render the DSCEngine contract unusable - This is by design
* We want the DSCEngine to freeze if prices become stale
*
*
* So if the chainlink network explodes and you have a lot of money locked in the protocol... Too bad
*/

library OracleLib {
    error OracleLib__StalePrice(); 

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLastestRoundData(AggregatorV3Interface priceFeed) public view returns(uint80, int256, uint256, uint256, uint80) {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = 
            priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) {
            revert OracleLib__StalePrice();
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}