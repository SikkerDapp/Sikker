// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//@title Basically Sikker"s user interface, to be used by tickets users
//@dev Functions to use and close tickets


/**
 * @title Use tickets smart contract
 * @dev Functions to use a payment ticket
**/

import "./CreateTickets.sol";
import "./maths/SafeMath.sol";

contract _UseTickets is _CreateTickets {
    using SafeMath for uint256;

    modifier OnlyReceiverTMM(uint256 _id) {
        require(_id > 0, "Id must be greater than 0.");
        require(msg.sender == _TMM_Tickets[_id].Receiver, "You are not the legitimate receiver for this ticket.");
        // Verify if the user is legitimate to unlock Eth
        _;
    }

    modifier OnlyReceiverCE(uint256 _id) {
        require(_id > 0, "Id must be greater than 0.");
        require(msg.sender == _CE_Tickets[_id].Receiver, "You are not the legitimate receiver for this ticket.");
        // Verify if the user is legitimate to unlock Eth
        _;
    }

    modifier PasswordCheck(bytes memory _password, bytes32 hash) {
        require(hash == keccak256(_password), "Wrong password entered.");
        // Compare password hash to stored hash
        _;
    }

    modifier StatusCheck(uint8 _status, uint8 _type) {
        require(_status == 0 || (_status == 1 && _type != 2), "Status error, this ticket is closed.");
        // Verify that the ticket status is correct
        _;
    }

    modifier TimeCheck(uint256 _lock, int8 _type, uint256 _id) {    // Type 0 = CE, type 1 = TMM
        if (_lock != 0) {
            if (_type == 1)
                require(_LockCE(_id) == false, "TimeCheck: Ticket is locked");
            else if (_type == 2)
                require(_LockTMM(_id) == false, "TimeCheck: Ticket is locked");
        }
        _;
    }


    function RequestEth(uint256 _amount) internal {
        require(msg.value > _amount, "RequestEth: Message value is not high enough");
    }


    function _UseCE(bytes memory _password, uint _id) public payable
    PasswordCheck(_password, _CE_Tickets[_id].Hash) StatusCheck(_CE_Tickets[_id].Status, 1) TimeCheck(_CE_Tickets[_id].TimeLock, 0, _id) {

        if (_CE_Tickets[_id].Status == 0) {

            require(msg.sender.balance > _CE_Tickets[_id].Amount, "_UseCE: Not enough value was sent");
            _CE_Tickets[_id].Payer = msg.sender;
            while (msg.value < _CE_Tickets[_id].Amount) {
                RequestEth(_CE_Tickets[_id].Amount);
            }

            if (_CE_Tickets[_id].Aty == true)
                _CE_Tickets[_id].Receiver.transfer(_CE_Tickets[_id].Amount / 2);

            emit SentHalfATY(
                _id,
                _CE_Tickets[_id].Amount,
                _CE_Tickets[_id].Amount / 2,
                _CE_Tickets[_id].Creator,
                msg.sender,
                _CE_Tickets[_id].Receiver
            );

            _CE_Tickets[_id].Status == 1;
            TotalValueEverLocked += _CE_Tickets[_id].Amount;
            emit FilledCE(_id, _CE_Tickets[_id].Amount, _CE_Tickets[_id].Creator, msg.sender, _CE_Tickets[_id].Receiver);

        } else if (_CE_Tickets[_id].Status == 1) {

            require(msg.sender == _CE_Tickets[_id].Payer, "_UseCE: message sender is not the ticket.payer");

            if (_CE_Tickets[_id].Aty == true) {
                _CE_Tickets[_id].Receiver.transfer(_CE_Tickets[_id].Amount / 2);
            } else {
                _CE_Tickets[_id].Receiver.transfer(_CE_Tickets[_id].Amount);
            }
            _CE_Tickets[_id].Status = 2; // Ticket is closed
            CE_Inactive_Ticket_Number++;
            TotalValueUnlocked += _CE_Tickets[_id].Amount;
            emit ClosedTicket(_id, "Classic Escrow", _CE_Tickets[_id].Amount, _CE_Tickets[_id].Payer, false, 0);
        }
    }

    function _UseTMM(bytes memory _password, uint256 _id) public
            OnlyReceiverTMM(_id)
            PasswordCheck(_password, _TMM_Tickets[_id].Hash)
            StatusCheck(_TMM_Tickets[_id].Status, 2)
            TimeCheck(_TMM_Tickets[_id].TimeLock, 1, _id)
        {

        address payable _receiver = payable(msg.sender);
        _TMM_Tickets[_id].Receiver = _receiver;
        _receiver.transfer(_TMM_Tickets[_id].Amount);
        _TMM_Tickets[_id].Status = 1; // Ticket is closed

        TMM_Inactive_Ticket_Number++;
        TotalValueUnlocked += _TMM_Tickets[_id].Amount;

    }

    function _LockCE(uint256 _id) public returns(bool) {
        require(_CE_Tickets[_id].Amount != 0, "_LockCE: Ticket does not exist");
        require(_CE_Tickets[_id].Status == 0 || _CE_Tickets[_id].Status == 1, "_LockCE: This ticket is already closed");
        if (_CE_Tickets[_id].TimeLock >= block.timestamp) {
            _CE_Tickets[_id].Payer.transfer([(100 - _CE_Tickets[_id].LossPercent) / 100] * _CE_Tickets[_id].Amount);
            _CE_Tickets[_id].Status = 3;
            emit ClosedTicket(_id, "Classic Escrow", _CE_Tickets[_id].Amount, _CE_Tickets[_id].Payer, true, _CE_Tickets[_id].LossPercent);
            return (true);
        }
        else
            return(false);
    }

    function _LockTMM(uint256 _id) public returns(bool) {
        require(_TMM_Tickets[_id], "_LockCE: Ticket does not exist");
        require(_CE_Tickets[_id].Status == 0, "_LockTMM: This ticket is already closed");
        if (_TMM_Tickets[_id].TimeLock >= block.timestamp) {
            _TMM_Tickets[_id].Payer.transfer([(100 - _TMM_Tickets[_id].LossPercent) / 100] * _TMM_Tickets[_id].Amount);
            _TMM_Tickets[_id].Status = 2;
            emit ClosedTicket(_id, "Take My Money", _CE_Tickets[_id].Amount, _CE_Tickets[_id].Payer, true, _CE_Tickets[_id].LossPercent);
            return (true);
        }
        else
            return(false);
    }

}