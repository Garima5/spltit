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
    // function to create new expense
    function createNewExpense(
        address _vendor,
        uint256 _deadline,
        uint256 _initialDeposit,
        uint256 _maxCapacity,
        uint256 actualAmount
    ) external{
        // later -> generate event id
        address[] memory contributors;
        address[] memory _paidOutContributor; 
        bytes32 eventId = keccak256(
        abi.encodePacked(
            msg.sender,
            _deadline,
            _initialDeposit,
            _maxCapacity
        )
    );
    //mapping(address=> uint256) _amountsDeposited;

        idToExpense[eventId]=Expense(
            eventId,
            msg.sender,
            _vendor,
            _deadline,
            false,
            _initialDeposit,
            _maxCapacity,
            actualAmount,
            contributors,
            _paidOutContributor);
    }

    // function to create new Contribution to the expense
    function createNewContribution(bytes32 expenseId) external payable {
        Expense storage myExpense = idToExpense[expenseId];
        require(msg.value >= myExpense.initialDeposit, "NOT ENOUGH DEPOSIT");
        require(block.timestamp <= myExpense.deadline, "ALREADY HAPPENED");
        require(myExpense.confirmedContributors.length<myExpense.maxCapacity, "The Expense has reached max capacity");
        for (uint8 i = 0; i < myExpense.confirmedContributors.length; i++) { 
        // Make sure that the person has not already contributed.
        require(myExpense.confirmedContributors[i] != msg.sender, "ALREADY CONFIRMED");
        }
        uint256 amountDepo = uint256(msg.value);
        amountsDeposited[msg.sender] += amountDepo; // For the person-> If contribution already exists - then add to it, else create a new entry
        // Later - > Add percentage of contribution
        // Later -> paid out should be false
        myExpense.confirmedContributors.push(msg.sender);
    }

    // Calculate total contribution per person
    function calculateContribution(bytes32 expenseId) public view returns (uint256){
        Expense storage myExpense = idToExpense[expenseId];
        uint256 totalContributors = myExpense.confirmedContributors.length;
        require(totalContributors>0, "NO CONTRIBUTORS");
        uint256 toPay = (myExpense.actualCost)/totalContributors;
        return toPay; // Every person has to pay this amount
    }

    // Function to Check contract Balance
    function contractBalance() public view returns (uint){
        // Function to just send value to Contract
        // Any payable value comes from the bixes above
        address contractAddress = address(this);
        uint contractBalance = contractAddress.balance;
        return contractBalance;
    }


    // Getter Functions to test values
    //function payBackContributor(Expense memory myExpense ,address contributor, uint256 amountPaidOut)  public  {
    function payBackContributor(bytes32 expenseId ,address contributor, uint256 amountPaidOut)  public  {
        Expense storage myExpense = idToExpense[expenseId];
        
        // Make sure vendor is paid out first
        require(myExpense.paidOut==true, "Vendor not paid yet");
        // Make sure that they are in the contributor list, 
        address confirmContributor;
        for (uint8 i = 0; i < myExpense.confirmedContributors.length; i++) {
        if(myExpense.confirmedContributors[i] == contributor){
            confirmContributor = myExpense.confirmedContributors[i];
        }
        }
        require(confirmContributor == contributor, "User not in contributor list");
        //make sure they are not already in the paidout list, 
        for (uint8 i = 0; i < myExpense.paidOutContributor.length; i++) { 
        // Make sure that the person has not already contributed.
            require(myExpense.paidOutContributor[i] != contributor, "ALREADY PAID OUT");
        }

        // reduce their deposit,
        require(amountsDeposited[contributor]>=amountPaidOut, "Deposit can't be less than 0");
        amountsDeposited[contributor] = amountsDeposited[contributor] - amountPaidOut;
        // push them to paidOut list
        myExpense.paidOutContributor.push(contributor);
        //return the money,  
        uint256 toReturn = amountsDeposited[contributor] - amountPaidOut;
        (bool sent,) = contributor.call{value: toReturn}("");
        require(sent==true, "Money not sent back");

    }



    
}