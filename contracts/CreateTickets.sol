// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Create tickets smart contract
 * @dev Functions to create a payment ticket
**/

import "./SikkerStats.sol";

contract CreateTickets is SikkerStats {
    using SafeMath for uint256;


    modifier amountCheck(uint256 _amount) {
        require(_amount > 0, "You must enter a positive amount");
        _;
    }

    function _CreateCE(
        bool _aty,
        uint8 _lossPercent,
        uint256 _amount,
        address _receiver,
        uint256 _timeLock,
        bytes32 _hash
        ) public amountCheck(_amount) {

        CE_Ticket memory _ticket;

        _ticket.Amount = _amount;

        _ticket.Creator = msg.sender;

        _ticket.Receiver = payable(_receiver);

        _ticket.Hash = _hash;
        _ticket.Status = 0;

        if (_timeLock != 0)
            _ticket.TimeLock = (block.timestamp + _timeLock);
        else
            _ticket.TimeLock = 0;

        if (_lossPercent > 0 && _lossPercent <= 100)
            _ticket.LossPercent = _lossPercent;
        else
            _ticket.LossPercent = 0;

        _ticket.Aty = _aty;

        _CE_Tickets.push(_ticket);

        UpdateStatsCE(0, NONE, 0, 0, Birth, 0);
    }

    function _CreateTMM(
        bytes32 _hash,
        uint8 _lossPercent,
        uint256 _timeLock,
        bool _designatedReceiver,
        address _receiver
        ) public payable
            amountCheck(msg.value) {

        TMM_Ticket memory _ticket;

        _ticket.Amount = msg.value;

        _ticket.Creator = msg.sender;
        _ticket.DeRe = _designatedReceiver;
        if (_designatedReceiver == true)
            _ticket.Receiver = payable(_receiver);
        else
            _ticket.Receiver = payable(Dead);
        _ticket.Hash = _hash;
        _ticket.Status = 0;

        if (_timeLock != 0)
            _ticket.TimeLock = (block.timestamp + _timeLock);
        else
            _ticket.TimeLock = 0;

        if (_lossPercent >= 5 && _lossPercent <= 100)
            _ticket.LossPercent = _lossPercent;
        else
            _ticket.LossPercent = 70;

        _TMM_Tickets.push(_ticket);

        UpdateStatsTMM(TMM_Ticket_Number, Locked, _ticket.Amount, Birth, 0);
    }
}