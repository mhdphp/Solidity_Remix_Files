// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; // timestamp;
    uint public goal;
    uint public raisedAmount;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    // can't store the Request in an array, if struct contains mappin
    mapping(uint => Request) public requests;
    // index of mapping is created separately
    uint public numRequests;


    // create three events that are useful for a front-end interface (web3);
    // the events are starting with capital letters
    // create an event when a contributor send funds
    event ContributeEvent(address _sender, uint _value);
    // create an event when a Request is created
    event CreateRequest(string _description, address _recipient, uint _value);
    // create an event when the payment is made according to the request
    event MakePayment(address _recipient, uint _value);


    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline =block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }


    // for testing purposes, to see how much time we have till the deadline
    function deadlineStatus() public view returns(uint){
        return deadline - block.timestamp;
    }


    function contribute() public payable{
        require(block.timestamp <= deadline, "Deadline has passed!");
        require(msg.value >= minimumContribution, "Minimum contribution not met!");

        // if the account sent contribution for the first time
        if (contributors[msg.sender] == 0){
            noOfContributors ++;
        }

        // add value to the existing contributor
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        // emit ContributeEvent in this function
        emit ContributeEvent(msg.sender, msg.value);
    }


    // in order to receive ETH sent directly from a wallet
    receive() payable external{
        contribute();
    }


    // public getter function that returns the balance of this contract
    function getBalance() public view returns(uint){
        return address(this).balance;
    }


    function getRefund() public{
        // the donor can ask for refund when the deadline for fundraising is
        // passed and the goal of the crowdfunding is not reached
        require(block.timestamp > deadline && raisedAmount < goal);
        // and the caller of this function has donated funds during the campaign
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        // send the funds to the recipient
        recipient.transfer(value);

        // or these lines of code can be simplified
        // payable(msg.sender).transfer(contributors[msg.sender]);

        // set the contribution of the caller - msg.sender to 0
        contributors[msg.sender] = 0;
    }


    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin can call this function.");
        _;
    }


    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        // since struct Request has a mapping variable should be kept in storage
        // numRequests start with 0
        Request storage newRequest = requests[numRequests];
        // increase by one unit the index - numRequests
        numRequests ++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        // emit CreateRequest event
        emit CreateRequest(_description, _recipient, _value);
    }


    function voteForRequest(uint _requestNo) public{
        require(contributors[msg.sender] > 0, "Only contributers are allowed to vote");
        // initialize a Request type variable named thisRequest
        // it saves in storage because I work on it and not on a copy
        Request storage thisRequest = requests[_requestNo];

        // next requirement is that the contributor has not voted yet
        require(thisRequest.voters[msg.sender] == false, "You have already voted!");
        // then after the vote
        thisRequest.voters[msg.sender] = true;
        // increment the number of voters
        thisRequest.noOfVoters++;
    }


    function makePayment(uint _requestNo) public onlyAdmin{
        require(raisedAmount >= goal);
        // initialize a Request struc which will be kept in storage
        Request storage thisRequest = requests[_requestNo];
        // Reject payment if the Request is completed
        require(thisRequest.completed == false, "This request has been completed.");
        // The no of voters has to be minimum 50% of the total number of contributors
        require(thisRequest.noOfVoters >= noOfContributors/2);

        // once the condition are met, make the transfer and change the completed variable to true
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        // emit MakePayment event
        emit MakePayment(thisRequest.recipient, thisRequest.value);
    }

}