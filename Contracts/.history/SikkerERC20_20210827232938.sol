// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./2_Owner.sol";

contract SikkerToken is Owner {      // The Sikker token will be a governance token, first to make and approve proposals (when locked) that devs will deploy in next Sikker version

    uint128 public constant TotalSupply = 50000000;
    uint256 Circulating;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    struct holdings {

        uint256 Balance;
        uint256 FirstTokenDate;

        uint256 LockedBalance;
        uint256 LockBegining;
        uint256 LockDuration;   // Should be a defined amount, inspired by curve.fi: more time locked = more voting power
        address DelegatedTo;    // Locked tokens can be delegated to whales to make votes count more
        uint256 VotingPower;

    }
    mapping(address => holdings) Tokens;

    modifier OnlySender(address _sender) {
        require(_sender == msg.sender, "_transfer: Message sender is not _sender");
        _;
    }

    function CreateTokkens(uint256 _amount) public isOwner {
        require(_amount > 0 && _amount <= (TotalSupply + Circulating));

        emit Transfer(0x0, this, _amount);
    }

    function name() public view returns(string memory) {
        return("Sikker");
    }
    
    function symbol() public view returns(string memory) {
        return("SIK");
    }

    function _transfer(address _receiver, address _sender, uint256 _amount) public OnlySender(_sender) {
        require(Tokens[_sender].Balance >= _amount);

        Tokens[_sender].Balance -= _amount;
        Tokens[_receiver].Balance += _amount;

        emit Transfer(_sender, _receiver, _amount);
    }
}