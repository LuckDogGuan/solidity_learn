// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// 1.创建收款函数
// 2.记录透支人并查看
// 3. 在锁定期内，达到目标值，生产商可以提款
// 4. 在锁定期内,没有达到目标值，投资人在锁定期后退款

contract FundMe {
    // 投资人和投资数量
    mapping(address => uint256) public fundersToAmount;

    // 内部使用
    AggregatorV3Interface internal dataFeed;
    uint256 constant TARGET_VALUE = 10 * 10 ** 18; // 表示常量
    address public ower;

    // 初始化
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        ); // Sepolia 测试网 usdt/Eth交易对
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 usdt/eth
        // 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43 usdt/etc
        ower = msg.sender; // 初始化构造函数
    }

    uint256 MIN_VALUE = 5 * 10 ** 18; // 最小的值 5$

    // 外部使用 payable 支付函数
    function fund() external payable {
        require(
            covertEthToUsd(msg.value) >= MIN_VALUE,
            "error Sender more Eth(1ETH)"
        );
        fundersToAmount[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function covertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer()); //eht价格
        // 价格 / 精度
        return (ethAmount * ethPrice) / (10 ** 8);
        // eth /usd = 10**8
        // x /eth = 10*18
    }

    function getFund() public{
        // this 表示当前合约
        // address 获取地址，balance 获取余额
        require(
            covertEthToUsd(address(this).balance) >= TARGET_VALUE,
            "TargetValue is not enough"
        );
        require(msg.sender == ower, "not owner");
        // transfer 纯转账 ， 失败会回滚
        payable(msg.sender).transfer(address(this).balance);
        // send     纯转账
        // call  带数据
    }

    function transferOwnerShip(address newOwer) public {
        require(ower == msg.sender, "not owner");
        ower = newOwer;
    }
}
