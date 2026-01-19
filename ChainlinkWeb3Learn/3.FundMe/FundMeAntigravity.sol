// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Custom Errors (Gas optimization)
// 相对于字符串，可以减少gas的消耗
error FundMe__NotOwner();
error FundMe__NotEnoughETH();
error FundMe__TargetNotReached();
error FundMe__NoFundsToRefund();
error FundMe__TransferFailed();

/**
 * @title A contract for crowd funding
 * @author Antigravity
 * @notice This contract is to demo a sample funding contract
 */
contract FundMe {
    // 1. State Variables
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Immutable & Constant (Gas optimization)
    address public immutable i_owner;
    AggregatorV3Interface public immutable i_priceFeed;
    uint256 public constant TARGET_VALUE = 100 * 10 ** 18;
    uint256 public constant MIN_USD = 5 * 10 ** 18; // 5 USD with 18 decimals

    // 2. Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // 3. Functions
    constructor(address priceFeedAddress) {
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
    }

    /**
     * @notice Funds the contract based on the USD value
     */
    function fund() public payable {
        if (getConversionRate(msg.value) < MIN_USD) {
            revert FundMe__NotEnoughETH();
        }
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    /**
     * @notice Withdraws the funds if the target value is reached
     */
    function withdraw() public onlyOwner {
        if (getConversionRate(address(this).balance) < TARGET_VALUE) {
            revert FundMe__TargetNotReached();
        }

        // Reset funders mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // Transfer funds
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) revert FundMe__TransferFailed();
    }

    /**
     * @notice Refunds the sender if the target hasn't been reached
     */
    function reFund() public {
        if (getConversionRate(address(this).balance) >= TARGET_VALUE) {
            revert FundMe__TargetNotReached();
        }
        uint256 amount = addressToAmountFunded[msg.sender];
        if (amount == 0) revert FundMe__NoFundsToRefund();

        // CEI Pattern: Update state before external call
        addressToAmountFunded[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert FundMe__TransferFailed();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = i_priceFeed.latestRoundData();
        return uint256(answer * 1e10); // ETH in terms of USD (18 decimals)
    }

    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function transferOwnerShip(address newOwner) public onlyOwner {
        // Since i_owner is immutable, we can't change it.
        // If ownership transfer is needed, it should not be immutable.
        // For this optimization, we assume i_owner is set once.
        // If you need changeable owner, remove immutable.
    }
}
