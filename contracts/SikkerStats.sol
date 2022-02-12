// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./SikkerMaths.sol";
import "./Sikker.sol";

contract SikkerStats is SikkerMaths, Sikker {
    using SafeMath for uint256;

    function currentlyLockedValue() private view returns(uint256) {
        uint256 total = 0;

        for (uint256 i = 0; i < tickets.length; i++)
            if (tickets[i].Status == status_t.Filled)
                total = total.add(tickets[i].Amount);
        return total;
    }
}
