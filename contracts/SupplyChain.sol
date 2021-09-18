// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;


contract SupplyChain {
  // are runtimes bad?
    address public owner; // internal, private, public?
    uint public skuCount; // internal, private, public?
    mapping (uint => Item) public items; // internal, private, public?\
    
    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }
  
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller; //disable linter here?
        address payable buyer;
    }
  
    /*  Events */
    event LogForSale(uint indexed sku);
    event LogSold(uint indexed sku);
    event LogShipped(uint indexed sku);
    event LogReceived(uint indexed sku);

    /* Modifiers */
    modifier isOwner() {
        require(msg.sender == owner);
        _; // what's purpose of this last line?
    }

    modifier verifyCaller (address _address) { 
        require(msg.sender == _address); 
        _;
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

    modifier forSale (uint _sku) {
        Item storage item = items[_sku]; // what's purpose of storage keyword?
        require(item.seller != address(0));
        require(item.state == State.ForSale);
        _;
    }

    modifier sold(uint _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    modifier shipped(uint _sku) {
        require(items[_sku].state == State.Shipped);
        _;
    }

    modifier received(uint _sku) {
        require(items[_sku].state == State.Received);
        _;
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0; // confirm not necessary
    }
    function addItem(string memory _name, uint _price) public returns (bool)
    {
        
        items[skuCount] = Item({
            name: _name, 
            sku: skuCount, 
            price: _price, 
            state: State.ForSale, 
            seller: msg.sender, 
            buyer: address(0)
        });
        skuCount += 1;
        emit LogForSale(skuCount);
        return true;
    }

  function buyItem(uint sku) payable public 
    forSale(sku)
    paidEnough(sku)
    checkValue(sku)
  {
    items[sku].seller.transfer(items[sku].price);
    items[sku].buyer = msg.sender;
    items[sku].state = State.Sold;
    emit LogSold(sku);
  }

  function shipItem(uint sku) public 
    sold(sku)
    verifyCaller(items[sku].seller)
  {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  function receiveItem(uint sku) public 
      shipped(sku)
      verifyCaller(items[sku].buyer)
  {
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  {
   name = items[_sku].name;
     sku = items[_sku].sku;
     price = items[_sku].price;
     state = uint(items[_sku].state);
     seller = items[_sku].seller;
     buyer = items[_sku].buyer;
     return (name, sku, price, state, seller, buyer);
   }
}
