//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------
 
// the ERC20 standard require that 6 functions and 2 events to be implemented
// in a Token Contract ERC20
// however only the first 3 functions are mandatory (a minimum requirement)
interface ERC20Interface {
    // for a token to be transferred from one contract to another, only 3 functions
    // are necessary
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    // function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    // function approve(address spender, uint tokens) external returns (bool success);
    // function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    // the event is inheritable in the contract Cryptos
    // then the event can be emited in a function in the contract Cryptos
    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Cryptos is ERC20Interface{
    // the standart require that additional functions to be defines such as:
    // name(), symbol(), decimals(), totalSupply()
    // however declaring public state variables with initialization makes
    // that the getters function will be automatically created for this variables
    string public name = "Cryptos"; // name of the token
    string public symbol = "CRPT"; // symbol of the token, 3 or 4 characters
    uint public decimals = 0; // max is 18
    uint public totalSupply; // totalSupply is a getter function created automatically for public vars

    address public founder;
    mapping(address => uint) public balances;

    constructor() {
        totalSupply = 1000000; // there will be 1000000 of tokens
        founder = msg.sender; // the founder will be the account that deployes the contract
        balances[founder] = totalSupply; // all the token are held by the founder;
    }

    // chage external with public and add keyword override
    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success){
        // the transfer can be made only if the balances of the account is greater or equal to tokens
        require(balances[msg.sender] >= tokens); // on failure the transaction will revert.

        // increase the account of the recipient
        balances[to] += tokens;
        // decrease the account of the sender
        balances[msg.sender] -= tokens;

        // emit the Transfer event
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

}