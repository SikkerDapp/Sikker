// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./SikkerMaths.sol";

contract SikkerStats is SikkerMaths {
    using SafeMath for uint256;
    using SafeMath for uint32;

    function CurrentlyLockedValue() private view returns(uint256) {

        uint256 total = 0;

        for (uint256 i = 0; i != tickets.length; i++) {
            if (tickets[i].Status == 1)
                total = total.add(tickets[i].Amount);
        }
        return (total);
    }

    function CE_Stats() public view returns(
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256
        ) {

        return (
                "Total CE tickets created:",
                CE_Ticket_Number,
                "Total active CE tickets:",
                CE_Ticket_Number.sub(CE_Inactive_Ticket_Number),
                "Total inactive CE tickets:",
                CE_Inactive_Ticket_Number,
                "Total value actually locked on CE:",
                CE_ValueEverLocked - CE_ValueUnLocked,
                "Total value ever locked on CE:",
                CE_ValueEverLocked,
                "Total value unlocked on CE:",
                CE_ValueUnLocked
            );
    }

    function TMM_Stats() public view returns(
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256,
        string memory, uint256
        ) {

        return (
                "Total TMM tickets created:",
                TMM_Ticket_Number,
                "Total active TMM tickets:",
                TMM_Ticket_Number.sub(TMM_Inactive_Ticket_Number),
                "Total inactive TMM tickets:",
                TMM_Inactive_Ticket_Number,
                "Total value actually locked on TMM:",
                TMM_ValueEverLocked.sub(TMM_ValueUnLocked),
                "Total value ever locked on TMM:",
                TMM_ValueEverLocked,
                "Total value unlocked on TMM:",
                TMM_ValueUnLocked
            );
    }

    function Sikker_Stats() public view returns(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256, uint256,
        uint256, uint256
        ) {

            uint256 TotalValueEverLocked;
            uint256 TotalValueUnlocked;

            TotalValueEverLocked = CE_ValueEverLocked.add(TMM_ValueEverLocked);
            TotalValueUnlocked = CE_ValueUnLocked.add(TMM_ValueUnLocked);

        return (
                //Total value locked (TVL):
                TotalValueEverLocked.sub(TotalValueUnlocked),
                //Total value ever locked:
                TotalValueEverLocked,
                //Total value ever unlocked:
                TotalValueUnlocked,
                //Total Sikker's profit:
                SikkerProfit,
                //Total profit withdrew:
                WddProfit,
                //Sending fees (Percent / Divider):
                SendPercent, SendDivider,
                //Closing fees (Percent / Divider):
                ClosPercent, ClosDivider
        );
    }

}