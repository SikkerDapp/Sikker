// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./2_Owner.sol";

// The Sikker token will be a governance token, first to make and approve proposals (when locked) that devs will deploy in next Sikker version
contract SikkerToken is Owner {

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

    mapping (address => mapping (address => uint256)) private _allowed;

    modifier OnlySender(address _sender) {
        require(_sender == msg.sender, "_transfer: Message sender is not _sender");
        _;
    }

    function CreateTokkens(uint256 _amount) public isOwner {
        require(_amount > 0 && _amount <= (TotalSupply + Circulating), "CreateTokkens: _amount is below 0 or too big");

        emit Transfer(address(0), this, _amount);
    }

    function name() public view returns(string memory) {
        return("Sikker");
    }

    function symbol() public view returns(string memory) {
        return("SIK");
    }

    function decimals() public view returns(uint8) {
        return(18);
    }

    function totalSupply() public view returns(uint256) {
        return(TotalSupply);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return (_allowed[owner][spender]);
    }

    function balanceOf(address _owner) public view returns(uint256 balance) {
        return(Tokens[_owner].Balance);
    }

    function transfer(address _receiver, address _sender, uint256 _amount) public OnlySender(_sender) {
        require(_receiver != address(0), "Invalid address");
        require(Tokens[_sender].Balance >= _amount, "transfer: Insuficient balance");
        require(_amount >= 0, "transfer: _amount must be positive");

        Tokens[_sender].Balance -= _amount;
        Tokens[_receiver].Balance += _amount;

        emit Transfer(_sender, _receiver, _amount);
    }
}