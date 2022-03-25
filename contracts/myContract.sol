// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract auctionCreator{
    // create an array that will hold the Action contracts
    Auction[] public auctions;

    function createAuction() public {
        // create a new instance of Auction contract named newAuction
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}

contract Auction{
    address payable public owner;  // the auction organizator
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash; // interplanetary file system

    enum State {Started, Running, Ended, Canceled}
    State public auctionState;

    uint public highestBindingBid;
    address payable highestBidder;

    // the addresse of the bidders and the amount they sent
    // 0 is the default value of any key in mapping
    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor(address eoa) {
        owner = payable(eoa);
        auctionState = State.Running;
        // auction starts with this block number;
        startBlock = block.number;
        // since it takes 15s to mine a block, in order the ending block
        // to be in a week (7x24/3600/15=40320)
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 100; // wei
    }

    function min(uint a, uint b) pure internal returns(uint){
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    // create several functions modifiers
    modifier notOwner(){
        require(owner != msg.sender);
        _;
    }

    modifier afterStart(){
        require(block.number > startBlock);
        _;
    }

    modifier beforeEnd(){
        require(block.number < endBlock);
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        require(msg.value >=100);
        
        // currentBid is the previous bid + the new bid increase
        uint currentBid = bids[msg.sender] + msg.value;

        require(currentBid > highestBindingBid);
        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() public {
        // conditions to finalize the auction
        require(auctionState == State.Canceled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] >0);

        // declare variables
        address payable recipient;
        uint value;

        if(auctionState == State.Canceled){ 
            // the auction is canceled any bidder or owner can reclaim the money
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else { 
            // the auction is ended not cancelled, then the owner and the bidders
            // withdraw their money
            if(msg.sender == owner){
                recipient = owner; // the owner / seller take the money
                value = highestBindingBid;
            } else { 
              if(msg.sender == highestBidder){ // if the bidder is either the highest bidder or not
                recipient = highestBidder;
                value = bids[highestBidder] - highestBindingBid;
              } else { // msg.sender is a common bidder
                recipient = payable(msg.sender);
                value = bids[msg.sender];
              }
            }
        }
        // in order to prevent the bidder to call this function multiple times
        // in this case the security breach in this contract is solved.
        bids[recipient] = 0;

        recipient.transfer(value);
    }
}


