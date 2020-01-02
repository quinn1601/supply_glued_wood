pragma solidity ^0.5.13;

contract SupplyWood {
  address public creator;                         // Address of the creator of the Contract
  string[] public batchID;                        // Array to store all of the Batch Numbers
  mapping (string => batchData) public batchMap;  // Mapping for storing the Details of the Batches
  mapping (address => bool) public certMap;       // Mapping for storing the Accounts eligible for Certification
  uint public amount;                             // Uint to store the total amount/quantity of product available
  uint public unitPrice;                          // Unit Price of the item

  // Structure to store details of a Batch
  struct batchData {
    uint amount;          // Amount/Quantity of the Product in the particular batch
    string id;            // Batch ID
    bool certified;       // Boolean to declare the batch is Certified or NOT
    address assigner;     // Address of Assigner of the Batch
    address certifier;    // Address of Batch Certifier.
    uint ctimestamp;      // TimeStamp of creation of the Batch
    uint atimestamp;      // TimeStamp of approval/certification of the Batch
    bool exhausted;       // Boolean to declare whether the Batch is completely consumed
  }

  // Constructor to create the Contract
  constructor(uint _unitPrice) public {
    creator = msg.sender;       // Setting creator as the msg.sender
    batchID = new string[](0);  // Init. the batchID array
    amount = 0;                 // Init. the global amount
    unitPrice = _unitPrice;     // Set the unitPrice
  }

  // Function to create a new Batch of Product
  function createBatch (uint _amount, string memory _id) public {
    batchData memory newBatch = batchData({ // Assigning the values to a new batchData Variable
      amount : _amount,
      id : _id,
      certified : false,
      assigner : msg.sender,
      certifier : address(0),
      ctimestamp : now,
      atimestamp : 0,
      exhausted : false
    });
    batchID.push(_id);        // Adding Batch Number/ID to the array of BatchID's
    batchMap[_id] = newBatch; // Adding the Batch Data to the BatchMap Mapping Variable
  }

  // Function to add Certifiers to the certMap
  function addCertifier (address _certifier) public {
    require(msg.sender == creator, "Caller is NOT creator of the Contract");   // Check for Admin Priviledges
    certMap[_certifier] = true;                                                // Add certifier address to certMap
  }

  // Function to Approve a Batch of Product
  function approveBatch (string memory _id) public {
    require(certMap[msg.sender], "Caller Address NOT in certMap");  // Check if Caller is in certMap or NOT
    batchMap[_id].certified = true;                                 // Set Batch as Certified
    batchMap[_id].atimestamp = now;                                 // Set Batch certification Timestamp
    batchMap[_id].certifier = msg.sender;                           // Set Batch certifier as Function Caller
    amount += batchMap[_id].amount;                                 // Update Global amount
  }

  // Function to consume Product
  function consume (uint _amount) public payable returns (bool) {
    require(amount >= _amount, "NOT enough Product available!");            // Check if enough product is available for consumption
    require(msg.value == _amount*unitPrice, "Value sent is not Correct!");  // Check if Sender sent enough ether or NOT
    amount -= _amount;                                                      // Deduct amount from Global Variable.
    return true;                                                            // Return True if everything works
  }
}
