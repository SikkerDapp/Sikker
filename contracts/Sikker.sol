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

They are two types of tickets:
  - CE tickets = Classic Escrow ticket, seller creates one with defined needed amount,
    defined timeLock, percentage of the ticket lost if timeLock is reached,
    defined receiver (should be the creator unless it is used by a fourth-party)

  - TMM tickets = Take My Money ticket, basically a password-protected money bag
    threw in the blockchain. Make sure not to lose your password.

For each type, you can precise if you want to enable its specification:
  - CE specification makes the ticket ATY (Almost Trust You):
    When the payer fills the ticket, half of the amount is automatically sent
    to the receiver.

  - TMM specification forces a pre-entered address as the ticket receiver.
    Note that by default, the receiver will be 0xDEAD until someone registers
    as receiver.

**/

pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Sikker is Owner {
    using SafeMath for uint256;

    //--------------------------------------  Stats

    enum checking_t {Checking, NoCheck}

    address constant Dead = 0x000000000000000000000000000000000000dEaD;

    //--------------------------------------  tickets

    enum status_t {New, Filled, Closed}
    enum type_t {CE, TMM}

    struct Ticket {
        type_t Type;                // Type of the ticket
        uint256 Amount;             // Amount of wei locked in ticket
        uint256 TimeLock;           // Date in seconds when the ticket expires
        uint8 LossPercent;          // Percent of Amount lost when TimeLock triggers or is canceled

        address Creator;            // Address of the ticket creator
        address Payer;              // Address of the ticket filler
        address payable Receiver;   // Address of the ticket's Amount destination

        bytes32 Hash;               // Hash of the ticket password
        bool Specificity;           // Specify if: CE ticket is ATY / TMM ticket has a designated Receiver
        status_t Status;            // Health status of the ticket
    }

    Ticket[] public tickets;

    //--------------------------------------  Leading

    uint256 public SikkerProfit;
    uint256 public WddProfit;

    //--------------------------------------  Fees

    enum when_t {Sending, Closing, Both}    // If you change that, you NEED to check changeFees function

    struct tax_s {
        uint24 percent;
        uint24 divider;
    }

    tax_s public sendingTax;
    tax_s public closingTax;

    uint256 public DiscountTrigger;
    uint8 public Discount;

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

    event CloseTicket(
        uint256 _id,
        type_t indexed _type,
        bool indexed _isTimeBlocked
    );

    modifier minAmount(uint256 _amount) {
        require(_amount > 10000, "Sikker: At least 10000 wei are required.");
        _;
    }

//------------------------------------------------------------------------------  Functions  ----------------------------------------------------------------------------

    fallback() external payable {
        if (msg.value > 0)
            emit LockValue(0, msg.value);
    }

    receive() external payable {
        if (msg.value > 0)
            emit LockValue(0, msg.value);
    }

    constructor() {
        sendingTax.percent = 9999;
        sendingTax.divider = 10000;
        closingTax.percent = 99;
        closingTax.divider = 100;
        Discount = 90;
        DiscountTrigger = 500000000000000000;
        tickets.push(Ticket(type_t(0), 0, 0, 0, Dead, Dead, payable(Dead), 0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d, false, status_t.Closed));
    }

    function changeFees(when_t _when, uint24 _percent, uint24 _divider) public isOwner() {
        if (_when != when_t.Closing) {
            sendingTax.percent = _percent;
            sendingTax.divider = _divider;
        }
        if (_when != when_t.Sending) {
            closingTax.percent = _percent;
            closingTax.divider = _divider;
        }
    }

    function changeDiscount(uint256 _triggerAmount, uint8 _discount) public minAmount(_triggerAmount) isOwner() {
        require(_discount <= 100, "changeDiscount: Discount can not be > 100.");

        DiscountTrigger = _triggerAmount;
        Discount = _discount;
    }

    function getWithdrawable() public view returns (uint256) {
        return SikkerProfit - WddProfit;
    }

    function payTheDevs(uint256 _amount, address payable _receiver) public isOwner() {
        require(_amount > 0 && _amount <= getWithdrawable(), "PayTheDevs: _amount is null or higher than Sikker's profit");

        if (_receiver == Dead)
            _receiver = payable(msg.sender);
        WddProfit =  WddProfit.add(_amount);
        _receiver.transfer(_amount);
        emit UnlockValue(0, _amount);
    }
}
