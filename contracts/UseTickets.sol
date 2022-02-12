// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SikkerStats.sol";
import "./CreateTickets.sol";

contract UseTickets is SikkerStats, CreateTickets {
    using SafeMath for uint256;
    using SafeMath for uint32;

    modifier idCheck(uint256 _id) {
        require(_id < tickets.length, "idCheck: Invalid id");
        require(tickets[_id].Status <= 1, "statusCheck: Status error, this ticket is closed.");
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

    modifier timeCheck(uint256 _lock) {
        require(_lock != 0 || _lock > block.timestamp, "timeCheck: Ticket is locked");
        _;
    }

    function fillCE(string memory _passwd, uint256 _id) public payable idCheck(_id) passwdCheck(_passwd, tickets[_id].Hash) timeCheck(tickets[_id].TimeLock) returns(string memory timelocked) {
        Ticket memory ticket = tickets[_id];
        uint256 amount = percentage(SendPercent, ticket.Amount, SendDivider);

        require(msg.value >= ticket.Amount, "_UseCE: Not enough value was sent");

        ticket.Payer = msg.sender;
        if (ticket.Specificity)
            payable(ticket.Receiver).transfer(amount.div(2));
        return("Ticket is now filled.");
    }

    function approveCE(uint256 _id) public idCheck(_id) onlyPayer(tickets[_id].Payer) timeCheck(tickets[_id].TimeLock) returns(string memory locked) {
        Ticket memory ticket = tickets[_id];
        uint256 amount = percentage(SendPercent, ticket.Amount, SendDivider);

        ticket.Status = 2;
        if (ticket.Specificity)
            amount = amount.div(2);
        payable(ticket.Receiver).transfer(amount);
        return "Ticket is now closed.";
    }

    function useTMM(string memory _passwd, uint256 _id) public idCheck(_id) onlyReceiver(tickets[_id]) passwdCheck(_passwd, tickets[_id].Hash) timeCheck(tickets[_id].TimeLock) returns(string memory timelocked) {
        Ticket memory ticket = tickets[_id];
        uint256 amount = percentage(SendPercent, ticket.Amount, SendDivider);

        if (!ticket.Specificity) {
            ticket.Receiver = payable(msg.sender);
            ticket.Specificity = true;
            return "msg.sender is now the designated receiver.";
        }
        payable(msg.sender).transfer(amount);
        return "Ticket is now closed";
    }

    function closeTicket(uint256 _id) public idCheck(_id) onlyPayer(tickets[_id].Creator) timeCheck(tickets[_id].TimeLock) returns (string memory locked) {
        Ticket memory ticket = tickets[_id];
        uint256 amount;

        if (ticket.LossPercent == 0)
            amount = percentage(ClosPercent, ticket.Amount, ClosDivider);
        else
            amount = percentage(ticket.LossPercent, ticket.Amount, 100);
        if (ticket.Type == type_t.CE && ticket.Specificity)
            amount = amount.div(2);
        payable(ticket.Payer).transfer(amount);
        return "Ticket is now locked.";
    }

    function lockTicket(uint256 _id) public idCheck(_id) returns (bool) {
        Ticket memory ticket = tickets[_id];
        uint256 amount;

        if (ticket.TimeLock <= 0 || ticket.TimeLock > block.timestamp)
            return false;
        if (ticket.LossPercent == 0)
            amount = percentage(ClosPercent, ticket.Amount, ClosDivider);
        else
            amount = percentage(ticket.LossPercent, ticket.Amount, 100);
        if (ticket.Type == type_t.CE && ticket.Specificity)
            amount = amount.div(2);
        payable(ticket.Payer).transfer(amount);
        return true;
    }
}
