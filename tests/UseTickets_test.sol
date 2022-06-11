// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/UseTickets.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is UseTickets {

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }

    /// #sender: account-0
    /// #value: 0
    function checkCeTicketCreation() public {
        createTicket(
            type_t.CE,
            false,
            0,
            10000000000000000000,
            TestsAccounts.getAccount(5),
            0,
            0xdc6ec0436bf057ac25500c9a3af7d31c429e1d289ddf2f0fe05e828c7bbac99d
        );
        Assert.equal(tickets[1].Type, type_t.CE, "Invalid ticket type");
        Assert.equal(tickets[1].Specificity, false, "Invalid ticket specificity");
        Assert.equal(tickets[1].TimeLock, 15, "Invalid ticket timelock");
        Assert.equal(tickets[1].Amount, 10000000000000000000, "Invalid ticket amount");
        Assert.equal(tickets[1].Receiver, TestsAccounts.getAccount(5), "Invalid ticket receiver");
        Assert.equal(tickets[1].Creator, TestsAccounts.getAccount(0), "Invalid ticket creator");
        Assert.equal(tickets[1].Hash, 0xdc6ec0436bf057ac25500c9a3af7d31c429e1d289ddf2f0fe05e828c7bbac99d, "Invalid ticket hash");
        Assert.equal(tickets[1].Status, status_t.New, "Invalid ticket status");
    }

    /// #sender: account-1
    /// #value: 0
    function checkAtyTicketCreation() public payable {
        createTicket(
            type_t.CE,
            true,
            50,
            20000000000000000000,
            TestsAccounts.getAccount(8),
            0,
            0xdc6ec0436bf057ac25500c9a3af7d31c429e1d289ddf2f0fe05e828c7bbac99d
        );
        Assert.equal(tickets[1].Type, type_t.CE, "Invalid ticket type");
        Assert.equal(tickets[1].Specificity, true, "Invalid ticket specificity");
        Assert.equal(tickets[1].TimeLock, 50, "Invalid ticket timelock");
        Assert.equal(tickets[1].Amount, 20000000000000000000, "Invalid ticket amount");
        Assert.equal(tickets[1].Receiver, TestsAccounts.getAccount(8), "Invalid ticket receiver");
        Assert.equal(tickets[1].Creator, TestsAccounts.getAccount(1), "Invalid ticket creator");
        Assert.equal(tickets[1].Hash, 0xdc6ec0436bf057ac25500c9a3af7d31c429e1d289ddf2f0fe05e828c7bbac99d, "Invalid ticket hash");
        Assert.equal(tickets[1].Status, status_t.New, "Invalid ticket status");
    }

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.ok(2 == 2, 'should be true');
        Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    function checkFailure() public {
        Assert.notEqual(uint(1), uint(1), "1 should not be equal to 1");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
