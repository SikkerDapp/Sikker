// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Create tickets smart contract
 * @dev Functions to create a payment ticket
**/

import "./SikkerStats.sol";

contract CreateTickets is Sikker, SikkerStats {
    using SafeMath for uint256;


    function createTicket(type_t _type, bool _specificity, uint8 _lossPercent, uint256 _amount, address _receiver, uint256 _timeLock, bytes32 _hash) minAmount(_amount) public payable {
        Ticket memory ticket;

        ticket = Ticket(
            _type,
            _amount,
            _timeLock != 0 ? block.timestamp.add(_timeLock) : 0,
            _lossPercent > 1 && _lossPercent <= 100 ? _lossPercent : 15,
            msg.sender,
            Dead,
            payable(Dead),
            _hash,
            _specificity,
            status_t.New
        );
        if (_type == type_t.CE) {
            require (msg.value == 0, "Ticket is CE type, user should not send ether creating a CE ticket.");

            ticket.Receiver = payable(_receiver);
        } else {
            require (msg.value >= _amount, "Ticket is TMM type, user must send as many ether as _amount entered.");
            ticket.Payer = msg.sender;
            if (_specificity)
                ticket.Receiver = payable(_receiver);
        }
        tickets.push(ticket);
        if (_type == type_t.TMM)
            emit LockValue(tickets.length, msg.value);
        emit CreatedTicket(tickets.length, _type, _specificity, _amount, msg.sender, _receiver, _lossPercent);
    }
}
