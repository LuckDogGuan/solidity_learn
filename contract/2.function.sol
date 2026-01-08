// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0.0;

// 简单函数使用
// 函数
contract Helloworld{
    string strVar = "hello world";
    
    // 调用方式 
    // external  外部调用 + 导出使用
    // public    权限最大
    // private   内部使用
    // internal  内部调用 + 继承/派生使用
    
    /// view 只对状态做读取
     
    // 返回string 类型   returns xxx类型
    // 对应的string 需要使用memory
    function sayHello()public view returns (string memory){
        // return strVar;
        return addinfo(strVar);
    }

    // 设置值
    function setSayHello(string memory newstr)public{
        strVar = newstr;
    }

    /// pure 纯运算操作,不读取也不写 变量
    function addinfo(string memory helloWorldStr)internal pure returns (string memory){
        return string.concat(helloWorldStr," from Frank's contrace.");
    }

}


