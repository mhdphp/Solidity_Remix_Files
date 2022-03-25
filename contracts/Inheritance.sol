// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// any contract which has at least one function without implementation with keyword
// vitual should be mark as abstract
abstract contract BaseContract{ 
    uint public x;
    address public owner; // the account that deploys the contract

    constructor(){
        x = 50;
        owner = msg.sender;
    }

    // function without implementation should be marked with the keyword virtual
    function setX(uint _x) public virtual; 
}


// when a derive contract (A) inherits a function virtual should be marked as abstract or,
// it should implement the function marked as virtual
contract A is BaseContract{
    int public y;
    constructor(){
        y = 974;
    }

    // when a virtual labeled function is implemented, keyword override should be used.
    function setX(uint _x) public override{
        x = _x;
    }
}