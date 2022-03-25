// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Token{
    // the events are useful if there is a front-end application that listens for them
    event Transfer(address _to, uint _value);

    function transfer(address payable _to, uint _value) public{
        // the function body
        // ...

        emit Transfer(_to, _value);
    }

}