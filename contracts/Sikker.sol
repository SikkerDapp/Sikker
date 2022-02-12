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
@@@@@@@@@@@,.          ,@@@@@@@@@      ,@@@@@@@@@@@@@@@       @@%      %@@      ,@@       %@@@@@@@@@@(      ,,,,,,,,,,,,,,     ,@@@@@,      ,@@@@@
@@@@@@@@@@@@@@@@,        ,@@@@@@@      ,@@@@@@@@@@@@@@@@@      @%      %@@      ,@      @@@@@@@@@@@@@,                         ,@@@@@,      (@@@@@
@@@@@@@@@@@@@@@@@@#       &@@@@@@      ,@@@@@@@@@@@@@@@       @@%      %@@      ,@@        @@@@@@@@@@,      ,*******************@@@@@,      (@@@@@
@@@@@@@@@@@@@@@@@@@,      ,@@@@@@      ,@@@@@@@@@@@@@       @@@@%      %@@      ,@@@@        @@@@@@@@@      ,@@@@@@@@@@@@@@@@@@@@@@@@,      (@@@@@
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
  - CE tickets = Classic Escrow ticket, seller creates one with defined needed amount,
    defined timeLock, percentage of the ticket lost if timeLock is reached,
    defined receiver (should be the creator unless it is used by a fourth-party)

  - ATY tickets = Almost Trust You ticket, exactly like a CE but when money is
    sent to the ticket, half of it is directly sent to the seller.
    *** !!! PLEASE BE CAUTIONOUS, OR CREATE TICKET AS CUSTOMER TO AVOID FIRST-PAYMENT ABUSE !!! ***

  - TMM tickets = Take My Money ticket, basically a password-protected money bag
    threw in the blockchain. Make sure not to lose your password.

**/

pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Sikker is Owner {
    using SafeMath for uint256;

    //--------------------------------------  Stats

    enum checking_t {Checking, NoCheck}

    address Dead = 0x000000000000000000000000000000000000dEaD;

    //--------------------------------------  tickets

    enum type_t {CE, TMM}

    struct Ticket {
        type_t Type;                // Type of the ticket: True = CE, False = TMM
        uint256 Amount;             // Amount of wei locked in ticket
        uint256 TimeLock;           // Date in seconds when the ticket expires
        uint8 LossPercent;          // Percent of Amount lost when TimeLock triggers or is canceled

        address Creator;            // Address of the ticket creator
        address Payer;              // Address of the ticket filler
        address payable Receiver;   // Address of the ticket's Amount destination

        bytes32 Hash;               // Hash of the ticket password
        bool Specificity;           // Specify if: CE ticket is ATY / TMM ticket has a designated Receiver
        uint8 Status;               // Health status of the ticket, 0 = newborn, 1 = filled
    }

    Ticket[] public tickets;

    //--------------------------------------  Leading

    uint256 public SikkerProfit;
    uint256 public WddProfit;
    uint256 public Withdrawable;

    //--------------------------------------  Fees

    enum when_t {Sending, Closing, Both}    // If you change that, you NEED to check changeFees function

    uint32 public SendPercent;
    uint32 public SendDivider;
    uint32 public ClosPercent;
    uint32 public ClosDivider;

    uint256 DiscountTrigger;
    uint8 Discount;

    //--------------------------------------  Events

    event LockValue(uint256 indexed _id, uint256 _amount);

    event UnlockValue(uint256 indexed _id, uint256 _amount);

    event CreatedTicket(
        uint256 _id,
        type_t indexed _type,
        bool _specificity,
        uint256 _amount,
        address _creator,
        address _receiver,
        uint8 _lossPercent
    );

    event FilledTicket(
        uint256 _id,
        uint256 _amount,
        address _payer,
        type_t indexed _type
    );

    event SentHalfATY(
        uint256 _id,
        uint256 _sentAmount,
        address indexed _creator,
        address indexed _payer,
        address indexed _receiver
    );

    event ClosedTicket(
        uint256 _id,
        type_t indexed _type,
        uint256 _amount,
        address indexed _payer,
        bool indexed _isTimeBlocked,
        uint8 _lostPercent
    );

//------------------------------------------------------------------------------  Functions  ----------------------------------------------------------------------------

    constructor() {
        SendPercent = 9999;
        SendDivider = 10000;
        ClosPercent = 99;
        ClosDivider = 100;
    }

    function changeFees(when_t _when, uint8 _percent, uint8 _divider) public isOwner() {
        if (_when != when_t.Closing) {
            SendPercent = _percent;
            SendDivider = _divider;
        }
        if (_when != when_t.Sending) {
            ClosPercent = _percent;
            ClosDivider = _divider;
        }
    }

    function changeDiscount(uint256 _triggerAmount, uint8 _discount) public isOwner() {
        require(_triggerAmount > 100000, "ChangeDiscount: wrong arguments");

        DiscountTrigger = _triggerAmount;
        Discount = _discount;
    }

    function payTheDevs(uint256 _amount, address payable _receiver) public isOwner() {
        if (Withdrawable == 0)
            Withdrawable = SikkerProfit.sub(WddProfit);

        require(_amount > 0 && _amount <= Withdrawable, "PayTheDevs: _amount is null or higher than Sikker's profit");

        if (_receiver == Dead)
            _receiver = payable(msg.sender);
        _receiver.transfer(_amount);
    }
}
