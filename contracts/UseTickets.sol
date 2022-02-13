// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SikkerStats.sol";
import "./CreateTickets.sol";

contract UseTickets is SikkerStats, CreateTickets {
    using SafeMath for uint256;
    using SafeMath for uint32;

    //  -------------------------------------------  Modifiers

    modifier idCheck(uint256 _id) {
        require(_id < tickets.length, "idCheck: Invalid id");
        require(tickets[_id].Status != status_t.Closed, "statusCheck: Status error, this ticket is closed.");
        _;
    }

    modifier onlyReceiver(Ticket memory _ticket) {
        require(!_ticket.Specificity || _ticket.Receiver == msg.sender, "onlyReceiver: You are not the legitimate receiver for this ticket.");
        _;
    }

    modifier onlyPayer(address _payer) {
        require(_payer == msg.sender, "onlyPayer: You have no rights to do this.");
        _;
    }

    modifier passwdCheck(string memory _password, bytes32 _hash) {
        require(_hash == keccak256(bytes(_password)), "passwordCheck: Wrong password.");
        _;
    }

    modifier timeCheck(uint256 _id) {
        require(!lockTicket(_id), "timeCheck: Ticket is locked");
        _;
    }

    modifier onlyType(type_t _type, uint256 _id) {
        require(tickets[_id].Type == _type, "onlyType: This ticket type is not compatible with this function.");
        _;
    }

    //  -------------------------------------------  Functions

    function fillCE(string memory _passwd, uint256 _id) public payable idCheck(_id) passwdCheck(_passwd, tickets[_id].Hash) timeCheck(_id) onlyType(type_t.CE, _id) returns(string memory fill) {
        uint256 amount = percentage(sendingTax.percent, tickets[_id].Amount, sendingTax.divider);

        require(tickets[_id].Status == status_t.New, "fillCE: Ticket already filled.");
        require(msg.value >= tickets[_id].Amount, "fillCE: Not enough value was sent");
        emit LockValue(_id, msg.value);

        tickets[_id].Payer = msg.sender;
        tickets[_id].Status = status_t.Filled;
        if (tickets[_id].Specificity) {
            payable(tickets[_id].Receiver).transfer(amount.div(2));
            emit UnlockValue(_id, amount.div(2));
        }
        return("Ticket is now filled.");
    }

    function approveCE(uint256 _id) public idCheck(_id) onlyPayer(tickets[_id].Payer) timeCheck(_id) onlyType(type_t.CE, _id) returns(string memory locked) {
        uint256 amount = percentage(sendingTax.percent, tickets[_id].Amount, sendingTax.divider);

        require (tickets[_id].Status == status_t.Filled, "approveCE: Can not approve an empty ticket.");
        tickets[_id].Status = status_t.Closed;
        if (tickets[_id].Specificity)
            amount = amount.div(2);
        payable(tickets[_id].Receiver).transfer(amount);
        return "Ticket is now closed.";
    }

    function useTMM(string memory _passwd, uint256 _id) public idCheck(_id) onlyReceiver(tickets[_id]) passwdCheck(_passwd, tickets[_id].Hash) timeCheck(_id) onlyType(type_t.TMM, _id) returns(string memory timelocked) {
        uint256 amount = percentage(sendingTax.percent, tickets[_id].Amount, sendingTax.divider);

        if (!tickets[_id].Specificity) {
            tickets[_id].Status = status_t.Filled;
            tickets[_id].Receiver = payable(msg.sender);
            tickets[_id].Specificity = true;
            return "msg.sender is now the designated receiver.";
        }
        tickets[_id].Status = status_t.Closed;
        emit UnlockValue(_id, amount);
        payable(msg.sender).transfer(amount);
        return "Ticket is now closed";
    }

    function closeTicket(uint256 _id) public idCheck(_id) onlyPayer(tickets[_id].Creator) timeCheck(_id) returns (string memory locked) {
        uint256 amount;

        tickets[_id].Status = status_t.Closed;
        if (tickets[_id].Type == type_t.CE && tickets[_id].Status == status_t.New)
            return "New CE ticket is now closed.";
        if (tickets[_id].LossPercent == 0)
            amount = percentage(closingTax.percent, tickets[_id].Amount, closingTax.divider);
        else
            amount = percentage(tickets[_id].LossPercent, tickets[_id].Amount, 100);
        if (tickets[_id].Type == type_t.CE && tickets[_id].Specificity)
            amount = amount.div(2);
        payable(tickets[_id].Payer).transfer(amount);
        emit UnlockValue(_id, amount);
        return "Ticket is now closed.";
    }

    function lockTicket(uint256 _id) public idCheck(_id) returns (bool) {
        uint256 amount;

        if (tickets[_id].TimeLock == 0 || tickets[_id].TimeLock > block.timestamp)
            return false;
        tickets[_id].Status = status_t.Closed;
        amount = percentage(tickets[_id].LossPercent, tickets[_id].Amount, 100);
        amount = percentage(closingTax.percent, amount, closingTax.divider);
        if (tickets[_id].Type == type_t.CE && tickets[_id].Specificity)
            amount = amount.div(2);
        payable(tickets[_id].Payer).transfer(amount);
        emit UnlockValue(_id, amount);
        emit CloseTicket(_id, tickets[_id].Type, true);
        return true;
    }
}
