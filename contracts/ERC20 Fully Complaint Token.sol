//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------
 

interface ERC20Interface {

    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Cryptos is ERC20Interface{

    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0;
    uint public totalSupply; 

    address public founder;
    mapping(address => uint) public balances;
    // first address is of the account that gives allowance to spent a certain amount of tokens
    // identified by an address
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }


    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens);

        // increase the account of the recipient
        balances[to] += tokens;
        // decrease the account of the sender
        balances[msg.sender] -= tokens;

        // emit the Transfer event
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    // the function will return how many tokens the owner has allowed to the spender to withdraw
    // this is a getter function
    function allowance(address tokenOwner, address spender) public view override returns (uint){
        return allowed[tokenOwner][spender];
    }

    // the function will set the amount of tokens that the owner of funds is granting to the spender
    // to withdraw
    // this is a setter function
    function approve(address spender, uint tokens) public override returns (bool success){
        // the number of tokens held by the owner should be greater or equal to the number of tokens
        // grant to the spender to withdrow
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        // credit the spender account
        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;
    }


    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        // check if the allowed number of tokens are greater or equal with the tokens that are to be transferred
        require(allowed[from][to] >= tokens);
        // check if there are enough tokens in the owner account / address
        require(balances[from] >= tokens);

        // decrease the balance of owner - from
        balances[from] -= tokens;
        // increase the balance of the recipient - to
        balances[to] += tokens;
        // decrease the amount allowed
        allowed[from][to] -= tokens;

        return true;
    }

}