// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//@title Basically Sikker"s user interface, to be used by tickets users
//@dev Functions to use and close tickets


/**
 * @title Use tickets smart contract
 * @dev Functions to use a payment ticket
**/

import "./SikkerStats.sol";
import "./CreateTickets.sol";

contract UseTickets is SikkerStats, CreateTickets {
    using SafeMath for uint256;
    using SafeMath for uint32;

//------------------------------------------------------   Modifiers  --------------------------------------------------------

    modifier IdCheck(uint8 _type, uint256 _id) {

        require(_type == isTMM || _type == isCE, "IdCheck: Wrong type entered");
        require(_id >= 0, "IdCheck: _id must be > 0");
        if (_type == isCE)
            require(_id < CE_Ticket_Number, "IdCheck: Invalid CE _id");
        else
            require(_id < TMM_Ticket_Number, "IdCheck: Invalid TMM _id");
        _;
    }

    modifier OnlyReceiver(address _receiver, bool _designated, uint256 _id) {

        require(_designated == false || _receiver == msg.sender, "OnlyReceiver: You are not the legitimate receiver for this ticket.");
        _;
    }

    modifier OnlyPayer(address _payer) {

        require(_payer == msg.sender, "OnlyPayer: You have no rights to do this.");
        _;
    }

    modifier PasswordCheck(string memory _password, bytes32 hash) {
        require(hash == keccak256(bytes(_password)), "Wrong password entered.");
        // Compare password hash to stored hash
        _;
    }

    modifier StatusCheck(uint8 _status, uint8 _type) {
        require(_type == isCE || _type == isTMM, "StatusCheck: Wrong type");
        require(_status == 0 || (_status == 1 && _type == isCE), "Status error, this ticket is closed.");
        // Verify that the ticket status is correct
        _;
    }

    modifier TimeCheck(uint256 _lock, uint8 _type, uint256 _id) {
        if (_lock != 0) {
            if (_type == isCE)
                require(_CE_Tickets[_id].TimeLock > block.timestamp, "TimeCheck: CE Ticket is locked");
            else if (_type == isTMM)
                require(_TMM_Tickets[_id].TimeLock > block.timestamp, "TimeCheck: TMM Ticket is locked");
        }
        _;
    }

//------------------------------------------------------   Functions  --------------------------------------------------------

    function _FillCE(string memory _password, uint _id) public payable
        IdCheck(isCE, _id)
        StatusCheck(_CE_Tickets[_id].Status, isCE)
        PasswordCheck(_password, _CE_Tickets[_id].Hash)
        returns(string memory timelocked)
    {

        uint8 _lockUnlock;
        uint256 _amount = Percentage(SendPercent, _CE_Tickets[_id].Amount, SendDivider);
        uint256 _aty = _amount.div(2);

        require(_LockCE(_id) == false, "FillCE: Ticket is timelocked!");
        require(msg.value >= _CE_Tickets[_id].Amount, "_UseCE: Not enough value was sent");

        _CE_Tickets[_id].Payer = msg.sender;

        if (_CE_Tickets[_id].Aty == true) {
            _lockUnlock = Both;
            payable(_CE_Tickets[_id].Receiver).transfer(_amount);
        } else
            _lockUnlock = Locked;

        UpdateStatsCE(_id, _lockUnlock, _amount, _aty, NONE, 1);
        return("Ticket is now filled.");
    }

    function _ApproveCE(uint _id) public
        OnlyPayer(_CE_Tickets[_id].Payer)
        IdCheck(isCE, _id)
        StatusCheck(_CE_Tickets[_id].Status, isCE)
        returns(string memory locked)
    {

        require(_LockCE(_id) == false, "ApproveCE: Ticket is timelocked!");

        uint256 _amount = Percentage(SendPercent, _CE_Tickets[_id].Amount, SendDivider);

        if (_CE_Tickets[_id].Aty == true)
            _amount = _amount.div(2);

        UpdateStatsCE(_id, Unlocked, _amount, _amount, Death, 2);

        payable(_CE_Tickets[_id].Receiver).transfer(_amount);

        return("Ticket is now closed.");
    }

    function _CloseCE(uint256 _id) public
        IdCheck(isCE, _id)
        OnlyPayer(_CE_Tickets[_id].Payer)
        StatusCheck(_CE_Tickets[_id].Status, isCE)
        returns(string memory locked)
    {

        uint256 _amount;

        if (_CE_Tickets[_id].LossPercent == 0)
            _amount = Percentage(ClosPercent, _CE_Tickets[_id].Amount, ClosDivider);
        else
            _amount = Percentage(_CE_Tickets[_id].LossPercent, _CE_Tickets[_id].Amount, 100);

        if (_LockCE(_id) != false)
            return ("Ticket is timelocked!");

        if (_CE_Tickets[_id].Aty == true)
            _amount = _amount.div(2);

        UpdateStatsCE(_id, Unlocked, _amount, 0, Death, 2);

        payable(_CE_Tickets[_id].Payer).transfer(_amount);
        return ("Ticket is now locked.");
    }

    function _UseTMM(string memory _password, uint256 _id)
        public
        IdCheck(isTMM, _id)
        OnlyReceiver(_TMM_Tickets[_id].Receiver, _TMM_Tickets[_id].DeRe, _id)
        StatusCheck(_TMM_Tickets[_id].Status, isTMM)
        PasswordCheck(_password, _TMM_Tickets[_id].Hash)
        returns(string memory timelocked) {

        if (_LockTMM(_id) != false)
            return ("Ticket is timelocked!");

        uint256 _amount = Percentage(SendPercent, _TMM_Tickets[_id].Amount, SendDivider);

        if (_TMM_Tickets[_id].DeRe == false) {
            _TMM_Tickets[_id].Receiver = payable(msg.sender);
            _TMM_Tickets[_id].DeRe = true;
            return ("msg.sender is now the designated receiver.");
        } else {
            payable(msg.sender).transfer(_amount);
            UpdateStatsTMM(_id, Unlocked, _amount, Death, 1);
            return("Ticket is now closed");
        }
    }

    function _CloseTMM(uint256 _id) public
            IdCheck(isTMM, _id)
            OnlyPayer(_TMM_Tickets[_id].Creator)
            StatusCheck(_TMM_Tickets[_id].Status, isTMM)
            returns(string memory locked)
        {

        if (_LockTMM(_id) != false)
            return ("Ticket is timelocked!");

        uint256 _amount;

        if (_TMM_Tickets[_id].LossPercent == 0)
            _amount = Percentage(ClosPercent, _TMM_Tickets[_id].Amount, ClosDivider);
        else
            _amount = Percentage(_TMM_Tickets[_id].LossPercent, _TMM_Tickets[_id].Amount, 100);

        UpdateStatsTMM(_id, Unlocked, _amount, Death, 1);
        payable(_TMM_Tickets[_id].Creator).transfer(_amount);

        return("Ticket is now losed.");

    }

//------------------------------------------------- Lock functions

    function _LockCE(uint256 _id) public 
        IdCheck(isCE, _id)
        StatusCheck(_CE_Tickets[_id].Status, isCE)
        returns(bool) {

        if (_CE_Tickets[_id].TimeLock > 0 && _CE_Tickets[_id].TimeLock <= block.timestamp) {

            uint256 _amount;

            if (_CE_Tickets[_id].LossPercent == 0)
                _amount = Percentage(ClosPercent, _CE_Tickets[_id].Amount, ClosDivider);
            else
                _amount = Percentage(_CE_Tickets[_id].LossPercent, _CE_Tickets[_id].Amount, 100);

            if (_CE_Tickets[_id].Aty == true)
                _amount = _amount.div(2);
            UpdateStatsCE(_id, Unlocked, _amount, _amount, Death, 3);

            payable(_CE_Tickets[_id].Payer).transfer(_amount);
            return (true);
        }
        else
            return (false);
    }

    function _LockTMM(uint256 _id) public
        IdCheck(isTMM, _id)
        StatusCheck(_TMM_Tickets[_id].Status, isTMM)
        returns(bool) {

        if (_TMM_Tickets[_id].TimeLock > 0 && _TMM_Tickets[_id].TimeLock <= block.timestamp) {

            uint256 _amount;

            if (_TMM_Tickets[_id].LossPercent == 0)
                _amount = Percentage(ClosPercent, _TMM_Tickets[_id].Amount, ClosDivider);
            else
                _amount = Percentage(_TMM_Tickets[_id].LossPercent, _TMM_Tickets[_id].Amount, 100);

            UpdateStatsTMM(_id, Unlocked, _amount, Death, 2);

            payable(_TMM_Tickets[_id].Creator).transfer(_amount);
            return (true);
        }
        else
            return (false);
    }

}