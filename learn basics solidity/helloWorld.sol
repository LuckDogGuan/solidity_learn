// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    // 默认公开可读的状态变量，部署时或之后可更新
    string public greeting;

    // 记录每次更新，方便前端或脚本监听
    event GreetingUpdated(address indexed updater, string newGreeting);

    constructor(string memory initialGreeting) {
        if (bytes(initialGreeting).length == 0) {
            greeting = "Hello, World!";
        } else {
            greeting = initialGreeting;
        }
    }

    // 任何人都可以更新问候语，演示状态变化
    function setGreeting(string calldata newGreeting) external {
        require(bytes(newGreeting).length > 0, "Greeting required");
        greeting = newGreeting;
        emit GreetingUpdated(msg.sender, newGreeting);
    }
}