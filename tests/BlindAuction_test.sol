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
    address payable beneficiary;
    address acc1;
    address acc2; 
    address acc3;
    uint value1 = 10000000;
    uint value2 = 20000000;
    uint value3 = 30000000;
    string secret1 = "secret 1";
    string secret2 = "secret 2";
    string secret3 = "secret 3";



    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        blindAuction = new BlindAuction(uint(30), uint(30), payable(TestsAccounts.getAccount(0)));
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
    }

    function checkBenificiary() public {
        //Assert.equal(TestsAccounts.getAccount(0),TestsAccounts.getAccount(0),"Benificiary Successfully set");
        Assert.equal(blindAuction.beneficiary(),TestsAccounts.getAccount(0),"Benificiary Successfully set");
    }

    function checkBidAcc1() public payable {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.equal(msg.sender, acc1, "sender should be acc1");
        bytes32 bid1 = keccak256(abi.encodePacked(value1, secret1));
        blindAuction.bid{value: msg.value}(bid1);
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    function checkFailure() public {
        Assert.notEqual(uint(1), uint(1), "1 should not be equal to 1");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
    