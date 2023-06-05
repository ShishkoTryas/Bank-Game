// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Banka {
    address public owner;
    uint256 public counter;


    struct Game {
        bool started;
        address winner;
        uint256 bank;
        uint256 StartDate;
        uint256 Period;
        uint256 maxBet;
    }

    mapping (uint256 => Game) public Games;
    uint8 public immutable Comission;

    event gameCreated(uint256 indexed gameID, uint256 startDate);
    event betCreated(uint256 indexed gameID);
    // , address winnerNow, uint256 bank, uint256 maxBet, uint256 period);

    constructor(uint8 _Comission) {
        owner = msg.sender;
        Comission = _Comission;
    }

    modifier gameAccess(uint256 _gameID) {
        require(
            !Games[_gameID].started, "Game Started or Ended"
        );
        _;
    }

    function startGame(uint256 _gameID) external gameAccess(_gameID) payable {
        require(msg.value > 0, "To start the game, the transaction must be greater than 0");
        uint256 value = msg.value;
        counter++;
        Games[_gameID].started = true;
        Games[_gameID].bank = value;
        Games[_gameID].winner = msg.sender;
        Games[_gameID].maxBet = value;
        Games[_gameID].Period = 5 minutes;
        Games[_gameID].StartDate = block.timestamp;

        emit gameCreated(_gameID, block.timestamp);
    }

    function Bet(uint256 _gameID) external payable {
        require(Games[_gameID].started, "Games not started yet");
        require(
            Games[_gameID].StartDate + Games[_gameID].Period >
            block.timestamp,
            "Voting is ended"
        );
        uint256 value = msg.value;
        require(msg.value > Games[_gameID].maxBet, "The bet must be higher than the maximum");
        uint256 duration = 1 minutes;

        Games[counter].bank += value;
        Games[counter].maxBet = value;
        Games[counter].winner = msg.sender;
        if(block.timestamp >= Games[_gameID].StartDate + Games[_gameID].Period - 1 minutes) {
            Games[_gameID].Period += duration;
        }

        emit betCreated(_gameID);
    }
    function winthrdraw(uint256 _gameID) external {
        require(Games[_gameID].started, "Games not started yet");
        require(
            Games[_gameID].StartDate + Games[_gameID].Period <
            block.timestamp,
            "Voting is not over yet!"
        );
        require(
            msg.sender == Games[_gameID].winner,
            "You are not a winner!"
        );
        require(
            Games[_gameID].bank > 0,
            "You have already received your prize!"
        );

        uint256 amount = Games[_gameID].bank;
        uint256 ownersComission = (Comission * amount) / 100;
        uint256 clearAmount = amount - ownersComission;
        Games[_gameID].bank = 0;
        payable(owner).transfer(ownersComission);
        payable(msg.sender).transfer(clearAmount);
    }

    function getGameInfo(uint256 _gameID)
    public
    view
    returns (
        bool,
        address,
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        return (
        Games[_gameID].started,
        Games[_gameID].winner,
        Games[_gameID].bank,
        Games[_gameID].StartDate,
        Games[_gameID].Period,
        Games[_gameID].maxBet
        );
    }
}