pragma solidity ^0.8.6;

// To DO:
// IPFS CID generate
// Event Id - unique generate
// Assign Vendor
// For each contributor - add the percentage that they are offering
contract Splitit{
    uint256 tempId = 0;
    struct Expense{
        bytes32 expenseId;
        // string expenseDataCID;
        address expenseOwner;
        address expenseVendor;
        uint256 deadline; // deadline upto which users can contribute
        bool paidOut; // If paidOut - then no new person can add their contribution
        uint256 initialDeposit;
        uint256 maxCapacity;
        uint256 actualCost;
        address[] confirmedContributors;
        address[] paidOutContributor; // list of contributors who have been paid theor deposit back
        // where to store each contributor's deposit value?
    }
    mapping (address=> uint256) amountsDeposited; // amount deposited per person 
    mapping (bytes32 => Expense) public idToExpense;
}