// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 
import "remix_accounts.sol";

import "../MultiSigRef.sol";

contract testMultiSig {

    MultiSigWallet ms;
    address[] public owners;
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract> with Test Account 0-4 as Owner and set min confirmation to 2
        owners.push(TestsAccounts.getAccount(0));
        owners.push(TestsAccounts.getAccount(1));
        owners.push(TestsAccounts.getAccount(2));
        owners.push(TestsAccounts.getAccount(3));
        ms = new MultiSigWallet(owners, 1);
    }

    function checkOwners() public {
        address[] memory _owners = ms.getOwners();
        Assert.equal(TestsAccounts.getAccount(0), _owners[0], "Check Owner 0 Error");
        Assert.equal(TestsAccounts.getAccount(1), _owners[1], "Check Owner 1 Error");
        Assert.equal(TestsAccounts.getAccount(2), _owners[2], "Check Owner 2 Error");
        Assert.equal(TestsAccounts.getAccount(3), _owners[3], "Check Owner 3 Error");
    }

    function checkReceive() public payable {
        payable(ms).transfer(msg.value);
        Assert.equal(msg.value, address(ms).balance, "Deposit failed");
    }

    function checkSubmitTx() public {
        bytes memory _data = "hello World";
        uint count = ms.getTransactionCount();
        Assert.equal(count,  0, "TX Count not Correct");
        require(count == 0, "TX Count not Correct");
        ms.submitTransaction(TestsAccounts.getAccount(4), 1 ether, _data);
        Assert.equal(ms.getTransactionCount(), count + 1, "SummitTx Failed");
        require( ms.getTransactionCount() == count + 1, "SummitTx Failed");
    }
    function checkconfirmation() public {
        ms.confirmTransaction(ms.getTransactionCount()-1);
        MultiSigWallet.Transaction memory x;
        (x.to, x.value, x.data, x.executed, x.numConfirmations)=ms.getTransaction(ms.getTransactionCount());
        Assert.equal(x.numConfirmations, 1, "Confirmation Failed");
    }
    function checkExecution() public {
        ms.executeTransaction(ms.getTransactionCount()-1);
    }
}

