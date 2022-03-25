// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract A{
    address public ownerA;
    constructor(address eoa){
        // assign the account that deploys the contract
        // to ownerA
        ownerA = eoa;
    }
}

contract Creator{
    address public ownerCreator;
    // an array of type of contract A
    A[] public deployedA;

    constructor(){
        ownerCreator = msg.sender;
    }

    function deployA() public{
        // create a new instance of contract A
        // the owner of this contract will be EOA that calls this
        // function
        // Note that the argument in new A(argument) is passed into
        // the contract A constructor
        A new_A_address = new A(msg.sender);
        // push this new instance in the A type array
        deployedA.push(new_A_address);
    }
}