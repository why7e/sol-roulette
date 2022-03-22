// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract SolRoulette {

    // Contract initialisation
    address owner = msg.sender;
    uint betAmount = 1 ether;
    uint diceMod = 37;

    // Bet type multiplier
    uint[] multiplier = [2, 35];

    /*
    0: Red/Black
    1: Number (0-36)
    */

    function makeBet(uint8 _betType, uint8 _wager) external payable returns (uint, bool) {

        // Ensure that the bet transaction is valid
        require(msg.value == betAmount, "Bet needs to be of the correct amount");
        require(_betType <= 1, "Not a valid bet type");
        require(_wager >= 0 && _wager <= 2, "Wager must be valid");

        // Setup for the bet
        uint betRoll = _rollDice();
        console.log(betRoll);
        bool success = false;
        address payable bettor = payable(msg.sender);

        // Individual bet logic
        if (_betType == 0) {

            // Color wager (0 is red (odd), 1 is black (even)),
            if (_wager == 0) {
                if (betRoll % 2 == 1 && betRoll > 0) {
                    _payoutHandler(bettor, _betType);
                    success = true;
                }
            }
            else if (_wager == 1) {
                if (betRoll % 2 == 0 && betRoll > 0) {
                    _payoutHandler(bettor, _betType);
                    success = true;
                }
            }
            else {
                revert("Invalid wager for this bet type.");
            }
        }

        else if (_betType == 1) {
            if (_wager == betRoll) {
                _payoutHandler(bettor, _betType);
                success = true;
            }
        }



        console.log(betRoll, success);
        return (betRoll, success);
    }

    // Payout function
    function _payoutHandler(address payable _bettor, uint8 _betType) private {
        uint payout = betAmount * multiplier[_betType];
        _bettor.transfer(payout);
    }

    // RNG Generator
    function _rollDice() private view returns(uint) {
        uint rHash = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        uint rValue = rHash % diceMod;
        console.log(rValue);
        return rValue;
    }
}