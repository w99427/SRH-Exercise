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
        bids[msg.sender].push(Bid({
            blindedBid: blindedBid,
            deposit: msg.value
        }));
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
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        //refund = (totol deposit) - (highst bid)
        uint refund;
        uint highstvalue=0;

        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
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
            if(!placeBid(msg.sender, highstvalue)){
                //not winning, return all diposit
                payable(msg.sender).transfer(refund);
            }
            else{
                //winning just return (total diposit - highest bid value)
                payable(msg.sender).transfer(refund-highstvalue);
            }
        }else{
            //liar, highst bid bigger than total diposit
            payable(msg.sender).transfer(refund);
        }
    }
    ///withdraw only one bid
    function withdrawOneBid(bytes32 blindedBid) 
    external
    onlyBefore(biddingEnded) 
    {
        uint refund;
        //FIXME: What happens if there are multiple identical blindBid in Bids[]?
        for (uint i=0; i < bids[msg.sender].length; i++){
            if (bids[msg.sender][i].blindedBid == blindedBid)
            {
                refund = bids[msg.sender][i].deposit;
                payable(msg.sender).transfer(refund);
                delete bids[msg.sender][i];
                break;
            }
        }
    }

    /// Withdraw a bid that was overbid.
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd()
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