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

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
* @title A Sample Raffle contract
* @author Johnson(under the tutorship of Patrick Collins)
 
* @notice This contract is for creating a sample raffle
* @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSent();
    error Raffle__TransferFailed(); 
    error RaffleNotOpen();

    /** Type declaration */ 
    enum RaffleState{
        OPEN,
        CALCULATING
    }

    /** Sate Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval; //duration of the lottery in seconds
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState; 

    /** Events */

    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface (vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN; 
        s_lastTimeStamp = block.timestamp;
    }
    function enterRaffle() external payable{
        //require(msg.value >= i_entranceFee, "Not enough ETH sent");
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETHSent();
        }
        if(s_raffleState != RaffleState.OPEN){
            revert RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }


    function pickWinner() external {
        //check if enough time is passed
        if ((block.timestamp - s_lastTimeStamp ) < i_interval){
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomwords
    ) internal override{
        uint256 indexOfWinner = randomwords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;

        s_players = new address payable[](0);
           
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();  
        }

        emit PickedWinner(winner);
    }

    /** getter functions */

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}