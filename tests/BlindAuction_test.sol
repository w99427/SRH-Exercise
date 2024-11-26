// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../BlindAuction.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    BlindAuction blindAuction;
    address beneficiary;
    address acc1;
    address acc2; 
    address acc3;
    struct Bids
    {
        uint[] values;
        bool[] fakes;
        bytes32[] secrets;
    }
    Bids[3] bids; 



    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        blindAuction = new BlindAuction(uint(30), uint(30), payable(TestsAccounts.getAccount(0)));
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        for (uint i=0; i<3; i++){
            for (uint j=0; j<3; j++)
            {
                bids[i].values.push(i*j*2 ether);
                bids[i].fakes.push(false);
                bids[i].secrets.push("secret ");
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
    //sender acc2
    function checkBidAcc2() public payable {
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender==acc2, "sender should be acc2");
        uint accnum = 1;
        for (uint i=0; i<3; i++){
            bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/3}(bidi);
        }
    }
    //sender acc3
    function checkBidAcc3() public payable {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.equal(msg.sender, acc3, "sender should be acc3");
        require(msg.sender==acc3, "sender should be acc3");
        uint accnum = 2;
        for (uint i=0; i<3; i++){
            bytes32 bidi = keccak256(abi.encodePacked(bids[accnum].values[i], bids[accnum].fakes[i], bids[accnum].secrets[i]));
            blindAuction.bid{value: msg.value/3}(bidi);
        }
    }
    function checkRevealAcc1() public {
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        Bids memory bids1 = bids[0];
        blindAuction.reveal(bids1.values, bids1.fakes, bids1.secrets);
    }
    function checkRevealAcc2() public {
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender==acc2, "sender should be acc2");
        Bids memory bids2 = bids[1];
        blindAuction.reveal(bids2.values, bids2.fakes, bids2.secrets);
    }
    function checkRevealAcc3() public {
        Assert.equal(msg.sender, acc3, "sender should be acc3");
        require(msg.sender==acc3, "sender should be acc3");
        Bids memory bids3 = bids[2];
        blindAuction.reveal(bids3.values, bids3.fakes, bids3.secrets);
    }

    function checkWithdrawAcc1() public {
        Assert.ok(blindAuction.ended(),"Auction not Ended");
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        require(msg.sender==acc1, "sender should be acc1");
        blindAuction.withdraw();
    }

    function checkWithdrawAcc2() public {
        Assert.ok(blindAuction.ended(),"Auction not Ended");
        Assert.equal(msg.sender, acc2, "sender should be acc2");
        require(msg.sender==acc2, "sender should be acc2");
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

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    /*function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
    */
}
    