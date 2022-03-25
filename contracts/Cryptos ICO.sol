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
    uint public override totalSupply; 

    address public founder;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }

    // virtual meaning that the behaviour of the function can be changed when inherited
    function transfer(address to, uint tokens) public virtual override returns (bool success){
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){

        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        // credit the spender account
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // the function labeled as virtual is changing the behaviour in the inherited contract
    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;
        return true;
    }

}


// use derived contract to code Cryptos ICO
contract CryptoICO is Cryptos{
    address public admin;
    address payable public deposit;
    uint public tokenPrice = 0.001 ether; // 1 ETH = 1000 CRPT
    uint public hardCap = 300 ether; // max fund raising
    uint public raisedAmount;
    uint public saleStart = block.timestamp + 25; // the ICO starts in 25 seconds after deployment
    uint public saleEnd = block.timestamp + 604800; // the ICO ends in a week - 7 days (the no is in secs)
    uint public tokenTradeStarts = saleEnd + 604800; // the ICO is transferable in week after saleEnd
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;

    enum State {beforeStart, running, afterEnd, halted}
    State public icoState;

    constructor (address payable _deposit){
        deposit = _deposit; // address where the payment for CRPT will be made
        admin = msg.sender; // the address of the account that will deploy the contract
        icoState = State.beforeStart;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    // stop the ICO in case of emergency (deposit address compromissed etc)
    function halt() onlyAdmin public{
        icoState = State.halted;
    }

    // function that resume the ICO when the problem / emergency is solved
    function resume() public onlyAdmin{
        icoState = State.running;
    }

    // function that change the deposit address (if the old address is compromised)
    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }

    // function that returns the State of the ICO
    function getCurrentState() public view returns(State){
        if (icoState == State.halted){
            return State.halted;
        } else if (block.timestamp < saleStart){
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    // define an event concerning the successful investment in the ICO
    event Invest(address investor, uint value, uint tokens);

    // create a function that will be call by investor to invest in the ICO
    // there are two ways to invest in ICO; first is to call this function, and the second is to send
    // funds directly to this contracts address.
    function invest()  payable public returns(bool){
        // ICO should be in State.running state
        icoState = getCurrentState();
        require(icoState == State.running);

        // check if the amount to be invested is larger thant the minimum amount and
        // less than the maximum amount allowed to be invested
        require(msg.value >= minInvestment && msg.value <= maxInvestment);

        // check if raisedAmount is less than the hardCap
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        // calculate the tokens that will be rezerved for this investment
        uint tokens = msg.value / tokenPrice;

        // increase / decreas the balances of investor / founder
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        // transfer the funds into the deposit address
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    receive() external payable {
        // this is in order to reveive funds via deposit.transfer
        // this function is automatically called when someone sends funds in this contract address.
        invest();
    }

    // the function transfer() has the same parameters but behaves differently
    function transfer(address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStarts);
        // call the function transfer from Cryptos contract
        Cryptos.transfer(to,tokens); // or similar super.transfer(to, tokens)
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStarts);
        super.transferFrom(from, to, tokens); // similar with Cryptos.transferFrom(from, to, tokens)
        return true;
    }

    // destroy the tokens that are not sold in the ICO
    function burn() public returns(bool){
        // the function could be called by any person, but only after the ICO is ended
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0; // there is no other function that could create tokens
        return true;
    }
}
