// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Owner {
    address private owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address _newOwner) public isOwner {
        owner = _newOwner;
        emit OwnerSet(owner, _newOwner);
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
