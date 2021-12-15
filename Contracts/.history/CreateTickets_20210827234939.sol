// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Create tickets smart contract
 * @dev Functions to create a payment ticket
**/

import "./Sikker.sol";

contract _CreateTickets is Sikker {

    struct CE_Ticket {
        bool Aty; // Is an "AlmostTrustYou" or not.
        uint8 Status; // Status of the ticket: For CE {0 = open, 1 = wainting for approval, 2 = closed, 3 = time_locked} For ATY {0 = open, 1 = half sent, 2 = closed, 3 = time_locked}.
        uint8 LossPercent; // % of Amount that will be loss when TimeLock is reached. If void, LossPercent = 30.
        uint256 Amount; // Amount of Eth wich the ticket is about.
        uint256 TimeLock; // Date (in seconds) when the ticket will close automatically, keeping 'LossPercent * Amount' Eth in the smartcontract, if ticket is filled.
        address Payer; // Address of the person wich sends Eth to Sikker.
        address payable Receiver; // Address of the person wich will receive Eth from Sikker.
        address Creator; // addressof the person who created the ticket.
        bytes32 Hash; // Hash to be compared with keyword to unlock payment.
    }
    
    struct TMM_Ticket {
        uint8 Status; // Status of the ticket: 0 = open, 1 = closed, 2 = time_locked;
        uint8 LossPercent; // % of Amount that will be loss when TimeLock is reached. If void, LossPercent = 70.
        uint256 Amount; // Amount of Eth wich the ticket is about.
        uint256 TimeLock; // Date (in seconds) when the ticket will close automatically, keeping LossPercent * Amount Eth in the smartcontract.
        address payable Receiver; // Address of the person wich will receive Eth from Sikker.
        address Creator; // addressof the person who created the ticket, wich also is Payer.
        bytes32 Hash; // Hash to be compared with keyword to unlock payment.
    }


    CE_Ticket[] public _CE_Tickets;
    TMM_Ticket[] public _TMM_Tickets;

    modifier IsAsshole(uint64 _amount, bytes32 _hash) {
        require (_amount > 0, "You must enter a correct amount.");
        require(_hash.length == 32, "You must enter a correct keccak256 hash starting with 0x.");
        _;
    }


    function _CreateCE(bool _aty, uint8 _percent, uint64 _amount, address _receiver, uint256 _timeLock, bytes32 _hash) public
    IsAsshole(_amount, _hash) {

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

        if (_percent >= 0 && _percent <= 100)
            _ticket.LossPercent = _percent;
        else
            _ticket.LossPercent = 70;

        _ticket.Aty = _aty;

        CE_Ticket_Number++;

        _CE_Tickets.push(_ticket);
        
        if (_timeLock > 0)
            emit CreatedTicket(CE_Ticket_Number, 'Classic Escrow', _amount, _ticket.Creator, _receiver, true, _percent, _hash);
        else
            emit CreatedTicket(CE_Ticket_Number, 'Classic Escrow', _amount, _ticket.Creator, _receiver, false, 0, _hash);
    }
    
    function _CreateTMM(uint64 _amount, bytes32 _hash, uint8 _percent, uint256 _timeLock) payable public 
    IsAsshole(_amount, _hash) {

        require(msg.value == _amount, "Bad Eth value, please retry with _amount equal msg.value.");

        TMM_Ticket memory _ticket;

        _ticket.Amount = msg.value;

        _ticket.Creator = msg.sender;
        _ticket.Receiver = payable(msg.sender);
        _ticket.Hash = _hash;
        _ticket.Status = 0;
        
        if (_timeLock != 0) {
            _ticket.TimeLock = (block.timestamp + _timeLock);
        } else {
            _ticket.TimeLock = 0;
        }
        _ticket.LossPercent = _percent;

        TotalValueEverLocked += _ticket.Amount;
        TMM_Ticket_Number++;

        _TMM_Tickets.push(_ticket);
        
        if (_timeLock > 0)
            emit CreatedTicket(CE_Ticket_Number, 'Take My Money', _amount, _ticket.Creator, 0x000000000000000000000000000000000000dEaD, true, _percent, _hash);
        else
            emit CreatedTicket(CE_Ticket_Number, 'Take My Money', _amount, _ticket.Creator, 0x000000000000000000000000000000000000dEaD, false, 0, _hash);
    }

}