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
    // 无法使用mapping 遍历，使用数组记录
    address[] public funders;

    // 内部使用
    AggregatorV3Interface internal dataFeed;
    uint256 constant TARGET_VALUE = 100 * 10 ** 18; // 表示常量
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

        if (fundersToAmount[msg.sender] == 0) {
            funders.push(msg.sender);
        }

        // 添加操作
        fundersToAmount[msg.sender] += msg.value;
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

    ///1. transfer 纯转账 ， 失败会回滚
    // payable(msg.sender).transfer(address(this).balance);

    // send     纯转账 返回是否成功
    // 2. bool success = payable(msg.sender).send(address(this).balance);
    // require(success);

    // call  带数据,可以调用其他 payable 的函数,推荐使用
    // 3. (bool,result) = addr.call{value,value}("sendeDate");

    function getFund() public {
        // 1.先这个，可以优化gas
        require(msg.sender == ower, "not owner");

        // 这个检查相对比较复杂
        // this 表示当前合约
        // address 获取地址，balance 获取余额
        require(
            covertEthToUsd(address(this).balance) >= TARGET_VALUE,
            "TargetValue is not enough"
        );

        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i]; // 获取数组
            fundersToAmount[funder] = 0; // 状态清零
        }

        funders = new address[](0); // 清空数组

        bool result;
        (result, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(result, "transfer tx failed");
    }

    // 改变所有者
    function transferOwnerShip(address newOwer) public {
        require(ower == msg.sender, "not owner");
        ower = newOwer;
    }

    function reFund() public {
        require(
            covertEthToUsd(address(this).balance) < TARGET_VALUE,
            "Target is reached"
        ); // 筹集到了对应的资产
        require(fundersToAmount[msg.sender] > 0, "Not have memory");

        // 去重，清零,防止重入攻击
        fundersToAmount[msg.sender] = 0;

        bool success;
        (success, ) = payable(msg.sender).call{
            value: fundersToAmount[msg.sender]
        }("reFund success");
        require(success, "transfer tx failed");
    }
}
