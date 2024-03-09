// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
* @title A Sample Raffle contract
* @author Johnson
* @tutor Patrick Collins
* @notice This contract is for creating a sample raffle
* @dev Implements Chainlink VRFv2
 */
contract Raffle{
    error Raffle__NotEnoughETHSent();

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval; //duration of the lottery in seconds
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /** Events */

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }
    function enterRaffle() external payable{
        //require(msg.value >= i_entranceFee, "Not enough ETH sent");
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETHSent();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }


    function pickWinner() external {
        //check if enough time is passed
        if ((block.timestamp - s_lastTimeStamp ) < i_interval){
            revert();
        }
    }

    /** getter functions */

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}