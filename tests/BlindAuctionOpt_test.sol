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
        uint accnum = 0;
        for (uint i=0; i<3; i++){
            bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/3}(bidi);
        }
    }

    //withdraw one bid from Acc1
    function checkWithdrawOneBid() public {
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        uint accnum = 0;
        uint bidindex = 1;
        bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[bidindex], bids[accnum].fakes[bidindex], bids[accnum].secrets[bidindex]));
        blindAuction.withdrawOneBid(bidi);
    }
}
    