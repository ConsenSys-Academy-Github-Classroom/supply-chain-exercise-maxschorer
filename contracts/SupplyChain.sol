// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address owner; // internal, private, public?
  uint skuCount; // internal, private, public?
  mapping (uint => Item) items; // internal, private, public?
  enum State{ ForSale, Sold, Shipped, Received };
  
  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address seller;
    address buyer;
  }
  
  /* 
   * Events
   */
  event LogForSale(uint indexed sku);
  event LogSold(uint indexed sku);
  event LogShipped(uint indexed sku);
  event LogReceived(uint indexed sku);

  /* 
   * Modifiers
   */

  // <modifier: isOwner
  modifier isOwner(){
    require(msg.sender == owner);
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _; // what's this line for?
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
    _;
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale (uint _sku) {
    Item item = items[_sku];
    require(item.seller > "0x0"); // not sure what to check?
    require(item.state == State.ForSale);
  }

  modifier sold(uint _sku){
    require(items[_sku].state == State.Sold);
  }
  // modifier sold(uint _sku) 
  modifier shipped(uint _sku){
    require(items[_sku].state == State.Shipped);
  }

  modifier received(uint _sku){
    require(items[_sku].state == State.Received);
  }

  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary?
    skuCount = 0; // not necessary, default value is 0
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    skuCount += 1;
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0)
    });
    emit LogForSale(skuCount);
    return true;
  }

  function buyItem(uint sku) payable public // 1. it should be payable in order to receive refunds
  // 5. this function should use 3 modifiers to check 
    forSale(sku) //    - if the item is for sale, 
    paidEnough(sku) //    - if the buyer paid enough, 
    checkValue(sku) //    - check the value after the function is called to make sure the buyer is refunded any excess ether sent. 
  {
    msg.sender.transfer(items[sku].seller); // 2. this should transfer money to the seller, 
    items[sku].buyer = msg.sender; // 3. set the buyer as the person who called this transaction, 
    items[sku].state = State.Sold; // 4. set the state to Sold. 
    emit LogSold(sku); // 6. call the event associated with this function!
  }

  function shipItem(uint sku) public 
    sold(sku) //    - the item is sold already 
    // verifyCaller() //    - the person calling this function is the seller. 
  {
    items[sku].state = State.Shipped; // 2. Change the state of the item to shipped. 
    emit LogShipped(sku); // 3. call the event associated with this function!
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public {}

  // Uncomment the following code block. it is needed to run tests
  /* function fetchItem(uint _sku) public view */ 
  /*   returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) */ 
  /* { */
  /*   name = items[_sku].name; */
  /*   sku = items[_sku].sku; */
  /*   price = items[_sku].price; */
  /*   state = uint(items[_sku].state); */
  /*   seller = items[_sku].seller; */
  /*   buyer = items[_sku].buyer; */
  /*   return (name, sku, price, state, seller, buyer); */
  /* } */
}
