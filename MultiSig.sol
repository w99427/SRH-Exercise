// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract MultiSig {

    ///using indexed to hide information because indexed only diliver the hash value 
    event Deposit(
        address sender, 
        uint256 amount, 
        uint256 balance);
    event SubmitTransaction(
        address owner,
        uint256 txIndex,
        address to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(
        address owner, 
        uint256 txIndex);
    event RevokeConfirmation(
        address owner, 
        uint256 txIndex);
    event ExecuteTransaction(
        address owner, 
        uint256 txIndex);

    address[] public owners;
    uint minConfirmationCount; 

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] public transactions;

    constructor (address[] memory _owners, uint minCount){
        //check owners and minCount

        //assign owners and minCount

    }

    receive() external payable {
        //emit event of recieving
    }

    ///initilize Transaction, limited to owner, emit event, put it in pending list
    function submitTransaction(address _to, uint256 _value, bytes memory _data)
    public
    {

    }

    ///confirm transaction with _txIndex
    function confirmTransaction(uint _txIndex)
    public
    {

    }

    ///excution transaction with index _txIndex
    function executeTransaction(uint _txIndex)
    public
    {

    }

    ///revoke confirmation for transaction with index _txIndex
    function revokeConfirmation(uint _txIndex) 
    public {

    }
    
    ///return owner list
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
    public
    view
    returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 numConfirmations
    ){

    }
}