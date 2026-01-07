// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0.0;

//contract 表示合约
// 基础数据类型
contract BaseDataTypes{
    //// 类型
    bool boolVar_1 = true;
    bool boolVar_2 = false;

    //// 整形
    // 1. 无符号
    uint8 uintValue_1 = 32;
    uint256 uintValue_2 = 255;
    // uint => unit256 默认是uint256
    // 2. 有符号
    int256 intValue = -999; 

    //// 字节 =》 字符串
    // 一个byte = 8bit  bytes32 是最大的范围 
    bytes32  bytesVar = "hello world";
    // bytes 数组  

    //// 字符串
    //  动态数组 小于bytes32就直接使用string
    string strVal = "hello world"; 

    //// 地址 独特类型
    // 地址不需要双引号
    address  add1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; 

}

