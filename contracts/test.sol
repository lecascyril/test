// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;
//test

contract Test {
    
    
    fallback() external payable{
        sendfalback();
    }
    receive() external payable{
        sendReceive();
    }
    

    
    function sendfalback() public view returns (string memory) {
        return "TEST";
    }
    function sendReceive() public view returns (string memory) {
        return "TEST2";
    }
    
}
