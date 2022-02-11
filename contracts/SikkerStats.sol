// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./maths/SikkerMaths.sol";

contract SikkerStats is SikkerMaths {
    using SafeMath for uint256;
    using SafeMath for uint32;

    function UpdateStatsTMM(
        uint256 _id,
        uint8 _lockUnlock,
        uint256 _amount,
        uint8 _birthDeath,
        uint8 _newStatus)
        internal {

        SikkerProfit = SikkerProfit.add(_TMM_Tickets[_id].Amount.sub(_amount));

        if (_lockUnlock == Unlocked) {
            TMM_ValueUnLocked = TMM_ValueUnLocked.add(_amount);
            SikkerProfit = SikkerProfit.add(_TMM_Tickets[_id].Amount.sub(_amount));
        } else
            TMM_ValueEverLocked = TMM_ValueEverLocked.add(_amount);

        if (_birthDeath == Birth) {
            TMM_Ticket_Number = OneUp(TMM_Ticket_Number);
        } else if (_birthDeath == Death) {
            TMM_Inactive_Ticket_Number = OneUp(TMM_Inactive_Ticket_Number);
        }

        _TMM_Tickets[_id].Status = _newStatus;

    }

    function UpdateStatsCE(
        uint256 _id,
        uint8 _lockUnlock,
        uint256 _amount,
        uint256 _atyAmount,
        uint8 _birthDeath,
        uint8 _newStatus)
        internal {


        if (_amount > 0)
            SikkerProfit = SikkerProfit.add(_CE_Tickets[_id].Amount.sub(_amount));

        if (_lockUnlock == Unlocked) {
            CE_ValueUnLocked = CE_ValueUnLocked.add(_amount);
            SikkerProfit = SikkerProfit.add(_TMM_Tickets[_id].Amount.sub(_amount));
        } else if (_lockUnlock == Locked) {
            CE_ValueEverLocked = CE_ValueEverLocked.add(_amount);
        } else if (_lockUnlock == Both) {
            CE_ValueEverLocked = CE_ValueEverLocked.add(_amount);
            CE_ValueUnLocked = CE_ValueUnLocked.add(_atyAmount);
            SikkerProfit = SikkerProfit.add(_TMM_Tickets[_id].Amount.sub(_atyAmount));
        }
        if (_birthDeath == Birth)
            CE_Ticket_Number = OneUp(CE_Ticket_Number);
        else
            CE_Inactive_Ticket_Number = OneUp(CE_Inactive_Ticket_Number);

        _CE_Tickets[_id].Status = _newStatus;

    }

    function CurrentlyLockedValue() private view returns(uint256) {

        uint256 total = 0;

        for (uint256 i = 0; i != CE_Ticket_Number; i++) {
            if (_CE_Tickets[i].Status == 1)
                total = total.add(_CE_Tickets[i].Amount);
        }
        for (uint256 i = 0; i != TMM_Ticket_Number; i++) {
            if (_TMM_Tickets[i].Status == 0)
                total = total.add(_TMM_Tickets[i].Amount);
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