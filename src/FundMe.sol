//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from  "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address aggaddr) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(aggaddr);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough"); //1 x 10 a la 18. 1 eth === 18000000000000000000 wei
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }//msg.value sería igual a 40.000.000.000.000.000 wei

    modifier onlyOwner {
        // require(owner == msg.sender, "Only contract owner can make withdraws");// less gas efficient
        if (msg.sender != i_owner) {// more gas efficient
            revert FundMe__NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner() {
        uint256 foundersQuantity = s_funders.length;
        for (uint256 i = 0; i < foundersQuantity; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);//new array of adresses with 0 objects

        (bool callSuccess,) = payable(msg.sender).call{ value: address(this).balance }("");
        require(callSuccess, "The transaction coun't be concreted");
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);//new array of adresses with 0 objects

        (bool callSuccess,) = payable(msg.sender).call{ value: address(this).balance }("");
        require(callSuccess, "The transaction coun't be concreted");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getAddresToAmountFunded(address fundingAddress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}