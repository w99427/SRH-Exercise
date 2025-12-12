// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Fomo3D{
    address public winner;
    address[] public earlyBirds;
    uint public earlyBirdsNum;
    uint public totalBidsNum;
    uint public interval;
    bool public ended;
    uint public earlyBirdRewardPercents; 
    uint public lastBidTime;

    event GameOver(address winner, uint winningSum);
    event NewValidBid(address winner, uint potSum);

    //_earlyBirdReward 1000=10%
    //minimum for timeinterval? 
    constructor(uint _timeinterval, uint _earlyBirdReward, uint _earlyBirdsNum){
        interval = _timeinterval;
        earlyBirdRewardPercents = _earlyBirdReward;
        earlyBirdsNum = _earlyBirdsNum;
    }

    //blockchain has only blocktime
    function getRemainGameTime() public view returns (uint remainTime){

    }

    function getWinningPotBalance() public view returns (uint balance){
        
    }

    //check if it fullfill the condition
    //record the early birds
    function bid() external payable returns (bool success){

    }

    //can only be called after the game is ended
    //reward will be transfer to the early birds and the winner
    function gameover() external {

    }
}