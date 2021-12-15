// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Create tickets smart contract
 * @dev Functions to create a payment ticket
**/

import "./2_Owner.sol";

contract CreateTicket is Owner {
    
    struct Ticket {
        uint256 Amount; // Amount of Eth wich the ticket is about
        uint8 Type; // Type of ticket: 1 = ClassicEscrow, 2 = TakeMyMoney, 3 = AlmostTrustYou
        address Payer; // Address of the person wich sends Eth to Sikker
        address Receiver; // Address of the person wich will receive Eth from Sikker
        address Creator; // addressof the person who created the ticket
        string Hash; // Hash to be compared with keyword to unlock payment
    }
    
    Ticket[] public _Tickets;
    
    modifier IsAsshole(uint64 _amount, uint8 _type, string memory _hash) {
        require (_amount > 0 && _type > 0 && _type <= 3 &&  bytes(_hash).length == 32);
         _;
    }
    
    function _CreateTicket(uint64 _amount, uint8 _type, string memory _hash) payable public IsAsshole(_amount, _type, _hash) {
        Ticket memory _ticket;
        
        _ticket.Type = _type;
        _ticket.Creator = msg.sender;
        _ticket.Hash = _hash;
        
        if (_type < 3) {
            _ticket.Receiver = msg.sender;
            _ticket.Amount = _amount;
        } else {
            _ticket.Payer = msg.sender;
            _ticket.Amount = msg.value;
        }

        _Tickets.push(_ticket);
    }
}