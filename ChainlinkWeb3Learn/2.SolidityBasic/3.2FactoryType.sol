// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. 引入全部合约
// import "./3.storageType.sol";

// 2. 引入指定的合约
// 2.1本地获取
import {StorageType} from "./3.storageType.sol";
// 2.2从网络上获取合约
import  {HelloWorld} from "https://github.com/smartcontractkit/Web3_tutorial_Chinese/blob/main/lesson-2/HelloWorld.sol";
// 2.3 第三方，通过包引入


// 工厂模式的使用
contract FactoryType{
    StorageType storType;
    StorageType[] storageTypes;

    function createFactory()public{
        // 创建新的合约，调用构造函数
        storType = new StorageType();
        storageTypes.push(storType);
    }
    function getFactoryByIndex(uint256 _index)public view returns(StorageType){
        return storageTypes[_index];
    }

    function callFactorySetHelloWorld(uint256 _index,string memory _str,uint256 _id)public {
       storageTypes[_index].setHelloWorld(_str,_id);
    }

    function callFcatrySayHelloworld(uint256 _index,uint256 _id)public view returns(string memory){
        return storageTypes[_index].sayHelloworld(_id);
    }


}
