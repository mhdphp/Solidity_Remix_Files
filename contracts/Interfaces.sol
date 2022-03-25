// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// all functions in interface are virtual (not implemented) and external
interface BaseContract{
    function setX(uint _x) external;
}

// Contract A is inherited interface BaseContract
contract A is BaseContract{
    // should be declared here (not in the interface contract) it is use in
    // function setX;
    uint public x; 

    int public y;
    constructor(){
        y = 974;
    }

    function setX(uint _x) public override{
        x = _x;
    }
}