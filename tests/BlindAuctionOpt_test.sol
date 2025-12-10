
// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../BlindAuctionOpt.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite2 {
    BlindAuctionOpt blindAuction;
    address beneficiary;
    address acc1;
    address acc2; 
    address acc3;
    struct Bids
    {
        uint[] values;
        bool[] fakes;
        bytes32[] secrets;
        bytes32[] blindBid;
    }
    Bids[3] bids; 



    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        beneficiary = TestsAccounts.getAccount(0);
        blindAuction = new BlindAuctionOpt(payable(TestsAccounts.getAccount(0)));
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        
        //3(Bidder) X 4(bids)
        for (uint i =0; i <3; i++)
        {
            for (uint j = 0; j < 4; j++)
            {
                bids[i].values.push(((i+1)*(j+1))%3+1);
                bids[i].fakes.push((i*j%2==0)); 
                bids[i].secrets.push("secrect");
                bids[i].blindBid.push(keccak256(abi.encodePacked(bids[i].values[j], bids[i].fakes[j], bids[i].secrets[j])));
            }
        }
    }

    function checkBenificiary() public {
        Assert.equal(blindAuction.beneficiary(),TestsAccounts.getAccount(0),"Benificiary Wrong");
        require(blindAuction.beneficiary() == TestsAccounts.getAccount(0),"Benificiary Wrong");
    }
    //sender acc1
    function checkBidAcc1() public payable {
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        require(msg.value > 10 ether, "need at least 10 ETH value");
        uint accnum = 0;
        for (uint i=0; i<4; i++){
            //bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/4}(bids[accnum].blindBid[i]);
        }
    }

        //sender acc1
    function checkBidAcc2() public payable {
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender==acc2, "sender should be acc2");
        require(msg.value > 10 ether, "need at least 10 ETH value");
        uint accnum = 1;
        for (uint i=0; i<4; i++){
            //bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/4}(bids[accnum].blindBid[i]);
        }
    }

        //sender acc1
    function checkBidAcc3() public payable {
        Assert.equal(msg.sender, acc3, "sender should be acc3");
        require(msg.sender==acc3, "sender should be acc3");
        require(msg.value > 10 ether, "need at least 10 ETH value");
        uint accnum = 2;
        for (uint i=0; i<4; i++){
            //bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/4}(bids[accnum].blindBid[i]);
        }
    }

    //withdraw one bid from Acc1
    function checkWithdrawOneBidAcc1() public payable{
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        uint accnum = 0;
        uint bidindex = 1;
        //bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[bidindex], bids[accnum].fakes[bidindex], bids[accnum].secrets[bidindex]));
        bytes32 bidi = bids[accnum].blindBid[bidindex];
        blindAuction.withdrawOneBid(bidi);
    }

    function checkBiddingEnd() public {
        blindAuction.setBiddingEnd();
        require(blindAuction.biddingEnded() == true, "set bidding end failed");
    }

    function checkRevealEnd() public {
        blindAuction.setRevealEnd();
        require(blindAuction.revealEnded() == true, "set reveal end failed");
    }

    function checkRevealAcc1() public {
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        blindAuction.reveal(bids[0].values, bids[0].fakes, bids[0].secrets);
    }

    //TODOs for acc2 and acc3
    function checkRevealAcc2() public {
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender == acc2, "sender should be acc2");
        blindAuction.reveal(bids[1].values, bids[1].fakes, bids[1].secrets);
    }

    function checkRevealAcc3() public {
        Assert.equal(msg.sender, acc3, "sender should be acc3");
        require(msg.sender == acc3, "sender should be acc3");
        blindAuction.reveal(bids[2].values, bids[2].fakes, bids[2].secrets);
    }
    //TODO for acc1 and acc2
    function checkWithdrawAcc1() public {
        Assert.ok(blindAuction.ended(), "Auction not Ended");
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender == acc1, "sender should be acc1");
        blindAuction.withdraw();
    }

    function checkWithdrawAcc2() public {
        Assert.ok(blindAuction.ended(), "Auction not Ended");
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender == acc2, "sender should be acc2");
        blindAuction.withdraw();
    }
    function checkWithdrawAcc3() public {
        Assert.ok(blindAuction.ended(),"Auction not Ended");
        Assert.equal(msg.sender, acc3, "sender should be acc2");
        require(msg.sender==acc3, "sender should be acc3");
        blindAuction.withdraw();
    }


    function checkAuctionEnd() public  {
        Assert.equal(blindAuction.ended(),true, "Auction not Ended");
        require(blindAuction.ended(), "Auction not Ended");
        blindAuction.auctionEnd();
    }
    function checkBalance() public {
        Assert.greaterThan(uint(acc1.balance), uint(99 ether), "Test Account Balance Incorrect");
        Assert.greaterThan(uint(acc2.balance), uint(99 ether), "Test Account Balance Incorrect");
        Assert.lesserThan(uint(acc3.balance), uint(91 ether), "Test Account Balance Incorrect");
    }

}

    