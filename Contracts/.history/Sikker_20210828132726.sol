/** SPDX-License-Identifier: MIT

 * @title Sikker maintenance Smart Contract
 * @dev Functions to maintain Sikker alive

    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,@@@@@@
@@@@@@@@,,            .,%@@@@@@@,      ,@@@@@
@@@@,                   ,@@@@@@@,       @@@@@                @@@@@@@@@@@@@@@@@@@@@@
@@         ,,,#@@#,,,   ,@@@@@@@@@,,,,@@@@@@                @@@@%      %@@     %@@@@%
@       ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@%      %@@      ,@@@%
,      ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%      %@@      ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;
@       ,@@@@@@@@@@@@@@@@@@@@@@@@      ,@@@@@@        @@@@@@@@@@%      %@@      ,@@@@@@@@@@        @@@@@@@@*,             ,@@@@@@@@@@,      |@,      |
@#         ,@@@@@@@@@@@@@@@@@@@@@      ,@@@@@@@@@       @@@@@@@@%      %@@      ,@@@@@@@@        @@@@@@@@,        ..        .@@@@@@@@,      (        |
@@@*            ,%@@@@@@@@@@@@@@@      ,@@@@@@@@@@@       @@@@@@%      %@@      ,@@@@@@        @@@@@@@@,      ,@@@@@@@@,      ,@@@@@@,         ,@@@@@
@@@@@@#,            ,@@@@@@@@@@@@      ,@@@@@@@@@@@@@       @@@@%      %@@      ,@@@@        @@@@@@@@@,     .@@@@@@@@@@@@      @@@@@@,       ,@@@@@
      @@@@@,.          ,@@@@@@@@@      ,@@@@@@@@@@@@@@@       @@%      %@@      ,@@       %@@@@@@@@@@(      ,,,,,,,,,,,,,,     ,@@@@@,      ,@@@@@
          @@@@@@,        ,@@@@@@@      ,@@@@@@@@@@@@@@@@@      @%      %@@      ,@      @@@@@@@@@@@@@,                         ,@@@@@,      (@@@@@
            @@@@@@#       &@@@@@@      ,@@@@@@@@@@@@@@@       @@%      %@@      ,@@        @@@@@@@@@@,      ,*******************@@@@@,      (@@@@@
             @@@@@@,      ,@@@@@@      ,@@@@@@@@@@@@@       @@@@%      %@@      ,@@@@        @@@@@@@@@      ,@@@@@@@@@@@@@@@@@@@@@@@@,      (@@@@@
, ,@@@@@@@@@@@@@@@,       @@@@@@@      ,@@@@@@@@@@&       @@@@@@%      %@@      ,@@@@@@        @@@@@@@,      ,@@@@@@@@@@@@@@@,@@@@@@@,      (@@@@@
|       .,,,,,          ,@@@@@@@@      ,@@@@@@@@        @@@@@@@@%      %@@      ,@@@@@@@@        @@@@@@%        .,,@@@@,,,   ,@@@@@@@,      (@@@@@
|                     ,@@@@@@@@@@      ,@@@@@@        @@@@@@@@@@%      %@@      ,@@@@@@@@@@        @@@@@@&,                  ,@@@@@@@,      (@@@@@
@@@@@,,,,     ,,,,@@@@@@@@@@@@@@@,,,,,,,@@@@@@@@@@@@@@@@@@@@@@@@%      %@@      ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,.     ,,,,@@@@@@@@@@@,,,,,,,(@@@@@
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@%      %@@      ,@@@@@@@@@@               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                                             @@@@@%    %@@      ,@@@@@
                                                               @@@@@@@@@@@@@@@@@@@@@@
  _____                      _
/\__  _\                   /\ \__                                                                    __
\/_/\ \/ _ __  __  __   ___\ \ ,_\         __      ____         __          ____    __  _ __  __  __/\_\    ___     __
   \ \ \/\`'__/\ \/\ \ /',__\ \ \/       /'__`\   /',__\      /'__`\       /',__\ /'__`/\`'__/\ \/\ \/\ \  /'___\ /'__`\
    \ \ \ \ \/\ \ \_\ /\__, `\ \ \_     /\ \L\.\_/\__, `\    /\ \L\.\_    /\__, `/\  __\ \ \/\ \ \_/ \ \ \/\ \__//\  __/
     \ \_\ \_\ \ \____\/\____/\ \__\    \ \__/.\_\/\____/    \ \__/.\_\   \/\____\ \____\ \_\ \ \___/ \ \_\ \____\ \____\
      \/_/\/_/  \/___/ \/___/  \/__/     \/__/\/_/\/___/      \/__/\/_/    \/___/ \/____/\/_/  \/__/   \/_/\/____/\/____/

                                                     (Sikker - Trust as a service)

-----------------------------------------------------------------------------------------------------------------------------------------------------

Sikker is a decentralised escrow (third-party) platform, an algorythm you can trust if you don't trust your commercial partner.

Use:   Create a ticket that your commercial partner will fill or collect.

They are three types of tickets:
   - CE tickets = CLassic Escrow ticket, seller creates one with defined needed amount,
    defined timelock, percentage of the ticket lost if timelock is reached,
    defined receiver (should be the creator unless it is used by a fourth-party)

   - ATY tickets = Almost Trust You ticket, exactly like a CE but when money is
    sent to the ticket, half of it is directly sent to the seller.
    *** !!! PLEASE BE CAUTIONOUS, OR CREATE TICKET AS CUSTOMER TO AVOID FIRST-PAYMENT ABUSE !!! ***

   - TMM tickets = Take My Money ticket, basically a password-protected money bag
    throw in the blockchain. Make sure not to lose your password.

**/


pragma solidity >=0.7.0 <0.9.0;


import "./2_Owner.sol";

contract Sikker is Owner {
    using SafeMath for uint256;

    uint256 CE_Ticket_Number;
    uint256 CE_Inactive_Ticket_Number;
    uint256 TMM_Ticket_Number;
    uint256 TMM_Inactive_Ticket_Number;
    uint256 TotalValueEverLocked;
    uint256 TotalValueUnlocked;


    event CreatedTicket(
        uint256 _id,
        string _type,
        uint256 _amount,
        address _creator,
        address _receiver,
        bool _timelocked,
        uint8 _lossPercent,
        bytes32 _hash
    );

    event FilledCE(
        uint256 _id,
        uint256 _amount,
        address _creator,
        address _payer,
        address _receiver
    );

    event SentHalfATY(
        uint256 _id,
        uint256 _totalAmount,
        uint256 _sentAmount,
        address _creator,
        address _payer,
        address _receiver
    );

    event ClosedTicket(
        uint256 _id,
        string _type,
        uint256 _amount,
        address _payer,
        bool _isTimeBlocked,
        uint8 _lostPercent
    );

    function _Total_CE_Tickets_Created() public view returns(uint256) {
        return(CE_Ticket_Number);
    }

    function _Total_CE_Tickets_Active() public view returns(uint256) {
        return(CE_Ticket_Number = CE_Ticket_Number.sub(CE_Inactive_Ticket_Number));
    }

    function _Total_TMM_Tickets_Created() public view returns(uint256) {
        return(TMM_Ticket_Number);
    }

    function _Total_TMM_Tickets_Active() public view returns(uint256) {
        return(TMM_Ticket_Number = TMM_Ticket_Number.sub(TMM_Inactive_Ticket_Number));
    }

    function _TotalValueLocked() public view returns(uint256) {
        return(TotalValueEverLocked = TotalValueEverLocked.sub(TotalValueUnlocked));
    }
}