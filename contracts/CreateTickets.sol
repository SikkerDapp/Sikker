// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Create tickets smart contract
 * @dev Functions to create a payment ticket
**/

import "./SikkerStats.sol";

contract CreateTickets is SikkerStats {
    using SafeMath for uint256;

    function _CreateTicket(type_t _type, bool _specificity, uint8 _lossPercent, uint256 _amount, address _receiver, uint256 _timeLock, bytes32 _hash)
        public payable {

        require(_amount > 10000, "You must require > 10000 wei");

        Ticket memory ticket;

        ticket.Amount = _amount;
        ticket.Creator = msg.sender;

        ticket.Hash = _hash;
        ticket.Status = 0;
    
        ticket.Specificity = _specificity;
        if (_type == type_t.CE)
            ticket.Receiver = payable(_receiver);
        else if (_specificity)
                ticket.Receiver = payable(_receiver);
        ticket.Timelock = _timeLock != 0 ? block.timestamp.add(_timeLock) : 0;
        ticket.LossPercent = _lossPercent > 5 && _lossPercent <= 100 ? _lossPercent : 15;
        tickets.push(ticket);
    }
}
