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
    threw in the blockchain. Make sure not to lose your password.

**/


pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Owner.sol";

contract Sikker is Owner {
    using SafeMath for uint256;

//--------------------------------------  Backbone & stats

    uint256 CE_Ticket_Number;
    uint256 CE_Inactive_Ticket_Number;
    uint256 CE_ValueEverLocked;
    uint256 CE_ValueUnLocked;

    uint256 TMM_Ticket_Number;
    uint256 TMM_Inactive_Ticket_Number;
    uint256 TMM_ValueEverLocked;
    uint256 TMM_ValueUnLocked;

    uint8 isCE = 0;
    uint8 isTMM = 1;

    uint8 Unlocked = 0;
    uint8 Locked = 1;
    uint8 Birth = 0;
    uint8 Death = 1;
    uint8 NONE = 3;

    bool Checkin = true;
    bool Nocheck = false;

    address Dead = 0x000000000000000000000000000000000000dEaD;

//--------------------------------------  tickets

    struct CE_Ticket {
        uint256 Amount; // Amount of Eth wich the ticket is about.
        uint256 TimeLock; // Date (in seconds) when the ticket will close automatically, keeping 'LossPercent * Amount' Eth in the smartcontract, if ticket is filled.
        uint8 Status; // Status of the ticket: For CE {0 = open, 1 = wainting for approval, 2 = closed, 3 = time_locked} For ATY {0 = open, 1 = half sent, 2 = closed, 3 = time_locked}.
        uint8 LossPercent; // % of Amount that will be loss when TimeLock is reached. If void, LossPercent = 30.
        bool Aty; // Is an "AlmostTrustYou" or not.
        address Payer; // Address of the person wich sends Eth to Sikker.
        address Receiver; // Address of the person wich will receive Eth from Sikker.
        address Creator; // addressof the person who created the ticket.
        bytes32 Hash; // Hash to be compared with keyword to unlock payment.
    }

    struct TMM_Ticket {
        uint256 Amount; // Amount of Eth wich the ticket is about.
        uint256 TimeLock; // Date (in seconds) when the ticket will close automatically, keeping LossPercent * Amount Eth in the smartcontract.
        uint8 Status; // Status of the ticket: 0 = open, 1 = closed, 2 = time_locked;
        uint8 LossPercent; // % of Amount that will be loss when TimeLock is reached. If void, LossPercent = 70.
        bool DeRe;  // If Receiver is designated on the ticket's creation.
        address payable Receiver; // Address of the person wich will receive Eth from Sikker.
        address Creator; // addressof the person who created the ticket, wich also is Payer.
        bytes32 Hash; // Hash to be compared with keyword to unlock payment.
    }


    CE_Ticket[] public _CE_Tickets;
    TMM_Ticket[] public _TMM_Tickets;

//--------------------------------------  Leading

    uint256 SikkerProfit;
    uint256 WddProfit;
    uint256 Withdrawable;

//--------------------------------------  Fees

    uint8 Sending = 0;
    uint8 Closing = 1;
    uint8 Both = 2;

    uint32   SendPercent;
    uint32   SendDivider;
    uint32   ClosPercent;
    uint32   ClosDivider;

    uint256 DiscountTrigger;
    uint8 Discount;

//--------------------------------------  Events

    event CreatedTicket(
        uint256 _id,
        string _type,
        uint256 _amount,
        address _creator,
        bool _designatedReceiver,
        address _receiver,
        uint8 _lossPercent
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

//------------------------------------------------------------------------------  Functions  ----------------------------------------------------------------------------

    constructor() {
        SendPercent = 9999;
        SendDivider = 10000;
        ClosPercent = 99;
        ClosDivider = 100;
    }


    function ChangeFees(
        uint8 _when,
        uint8 _percent,
        uint8 _divider)
        public isOwner() {

        require(_when == Sending || _when == Closing || _when == Both, "ChangeFees: _when is neither 0 or 1");
        if (_when == Sending) {
            SendPercent = _percent;
            SendDivider = _divider;
        } else if (_when == Closing) {
            ClosPercent = _percent;
            ClosDivider = _divider;
        } else if (_when == Both) {
            SendPercent = _percent;
            SendDivider = _divider;
            ClosPercent = _percent;
            ClosDivider = _divider;
        }
    }

    function ChangeDiscount(
        uint256 _triggerAmount,
        uint8 _discount)
        public isOwner() {

        require(_triggerAmount > 100000 && _discount >= 0, "ChangeDiscount: wrong arguments");

        DiscountTrigger = _triggerAmount;
        Discount = _discount;
    }

    function PayTheDevs(
        uint256 _amount,
        address payable _receiver)
        public isOwner() {

        if (Withdrawable == 0)
            Withdrawable = SikkerProfit.sub(WddProfit);

        require(_amount > 0 && _amount <= Withdrawable, "PayTheDevs: _amount is null or higher than Sikker's profit");

        if (_receiver == Dead)
            _receiver = payable(msg.sender);

        _receiver.transfer(_amount);
    }

}
