// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract BlindAuctionOpt {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address payable public beneficiary;
    address public owner;
 //   uint public biddingEnd;
 //   uint public revealEnd;
    bool public ended;
    bool public biddingEnded;
    bool public revealEnded;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);
    event BidCompelete(address bidder, uint bidslength);

    // Errors that describe failures.

    /// The function has been called too early.
    /// Try again at `time`.
    //error TooEarly(uint time);
    /// The function has been called too late.
    /// It cannot be called after `time`.
    //error TooLate(uint time);

    error TimingNotAllowed(bool con1, bool con2, bool con3);
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();
    error PermissionCheckFailed();

    // Modifiers are a convenient way to validate inputs to
    // functions. `onlyBefore` is applied to `bid` below:
    // The new function body is the modifier's body where
    // `_` is replaced by the old function body.
    modifier onlyBefore(bool con) {
        if (con) revert TimingNotAllowed(biddingEnded, revealEnded, ended);
        _;
    }
    modifier onlyAfter(bool con) {
        if (!con) revert TimingNotAllowed(biddingEnded, revealEnded, ended);
        _;
    }

    constructor(
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        owner = msg.sender;
    }
    ///set Bidding End Status
    function setBiddingEnd()
    external 
    {
        if (msg.sender != owner){
            revert PermissionCheckFailed();
        }
        biddingEnded = true;
    }

    function setRevealEnd()
    external 
    {
        if (msg.sender != owner){
            revert PermissionCheckFailed();
        }
        revealEnded = true;
    }

    /// Place a blinded bid with `blindedBid` =
    /// keccak256(abi.encodePacked(value, fake, secret)).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.
    function bid(bytes32 blindedBid)
        external
        payable
        onlyBefore(biddingEnded)
    {
        bids[tx.origin].push(Bid({
            blindedBid: blindedBid,
            deposit: msg.value
        }));
        emit BidCompelete(tx.origin, bids[tx.origin].length);
    }

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
        uint[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    )
        external
        onlyAfter(biddingEnded)
        onlyBefore(revealEnded)
    {
        uint length = bids[tx.origin].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        //refund = (totol deposit) - (highst bid)
        uint refund;
        uint highstvalue=0;

        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[tx.origin][i];
            (uint value, bool fake, bytes32 secret) =
                    (values[i], fakes[i], secrets[i]);
            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                // Bid was not actually revealed.
                // Do not refund deposit.
                continue;
            }
            refund += bidToCheck.deposit;
            if (value > highstvalue){
                highstvalue = value;
            }
        
            /*
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
            */
            // Make it impossible for the sender to re-claim
            // the same deposit.
            bidToCheck.blindedBid = bytes32(0);
        }

        if (refund > highstvalue){
            if(!placeBid(tx.origin, highstvalue)){
                //not winning, return all diposit
                payable(tx.origin).transfer(refund);
            }
            else{
                //winning just return (total diposit - highest bid value)
                payable(tx.origin).transfer(refund-highstvalue);
            }
        }else{
            //liar, highst bid bigger than total diposit
            payable(tx.origin).transfer(refund);
        }
    }
    ///withdraw only one bid
    function withdrawOneBid(bytes32 blindedBid) 
    external
    onlyBefore(biddingEnded) 
    {
        for (uint i = 0; i < bids[tx.origin].length; i++) {
            if (bids[tx.origin][i].blindedBid == blindedBid) {
                //TODO: refund deposit if we found matching bid
                //FIXME: something wrong with transfer
                //payable(msg.sender).transfer(bids[msg.sender][i].deposit);
                uint deposit = bids[tx.origin][i].deposit;
                uint balance = address(this).balance;
                require(deposit > 2 ether, "deposit");
                require(balance > deposit, "Contract balance should be greater than the deposit");
                payable(tx.origin).transfer(deposit);
                //TODO: remove/delete the bid from mapping/bid array if we found matching bid
                
                removeElementByIndex(tx.origin, i);
                break;
            }
        }
    }

       function removeElementByIndex(address addr, uint _index) public returns (bool) {
        if (_index >= bids[addr].length) {
            return false;
        }
 
        for (uint i = _index; i < bids[addr].length - 1; i++) {
            bids[addr][i] = bids[addr][i + 1];
        }
        bids[addr].pop();
 
        return true;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() external {
        uint amount = pendingReturns[tx.origin];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[tx.origin] = 0;

            payable(tx.origin).transfer(amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function setAuctionEnd()
        external
        onlyAfter(revealEnded)
    {
        if (ended) revert AuctionEndAlreadyCalled();
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }
}