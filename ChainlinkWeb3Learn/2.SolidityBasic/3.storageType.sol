// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0.0;

/// 存储类型

/// 类型定义
/*
    1.storage   永久性  合约内,默认为storage
    2.memory    暂时性  可以被修改 一般为函数入参
    3.calldata  暂时性  无法被修改 一般为函数入参
    4.stack
    5.codes
    6.logs

*/

///  数据结构
/* 
    1. struct 结构体
    2. array 数组
    3. mapping 映射 k-v 
*/

contract StorageType{
    struct Info{
        string phrase; // 短语
        uint256 id;
        address addr;
    }
    Info[] infos;
    string strVal = "Hello World";

    mapping (uint256 id=>Info info) infomaping; // mapping 


    function setHelloWorld(string memory str,uint256 _id)public{
        Info memory info = Info(str,_id,msg.sender);
        // infos.push(info);
        infomaping[_id] = info; // 将结构体传入到mapping中,替换为mapping使用
    }

    function addInfo(string memory hellworldStr)internal pure returns (string memory){
        return string.concat(hellworldStr," add For mapping...");
    }
    
    function sayHelloworld(uint256 _id)public view returns (string memory){
        if(infomaping[_id].addr != address(0x00)){
            return addInfo(infomaping[_id].phrase); 
        }
        // 替换为mapping
        /*
        for (uint256 i=0;i< infos.length;i++){
            if(infos[i].id ==_id){
                return addInfo(infos[i].phrase);
            }
        }
        */
        return addInfo(strVal);
    }
}
