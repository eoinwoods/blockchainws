pragma solidity ^0.4.2 ;

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract MegaCoin is Ownable {
    
    string public name ;
    string public symbol ;
    uint64 totalSupply ;
    uint64 totalAllocation ;
    uint64 transferLimit ;
    mapping(address => uint64) balances ;
    address owner ;
    
    event Transfer(address to, uint64 amount, uint64 outstanding) ;
    event InsufficientFunds(address to, uint64 value, uint64 totalOutstanding);
    event TransferLimitExceeded(address to, uint64 value, uint64 transferLimit);

    function MegaCoin(string _name, string _symbol, uint64 _totalSupply) public {
        owner = msg.sender ;  
        name = _name ;
        symbol = _symbol ;
        totalSupply = _totalSupply ;
        transferLimit = 100 ;
    }
    
    function allocate(address to, uint64 amount) onlyOwner public {
        uint64 available = totalSupply - totalAllocation ;
        if (amount > transferLimit) {
            TransferLimitExceeded(to, amount, transferLimit) ;
            return ;            
        }
        if (amount > available) {
            InsufficientFunds(to, amount, available) ;
            return ;
        }
        
        totalAllocation += amount ;
        balances[to] += amount ;
        Transfer(to, amount, available - amount) ;
    }
    
    function setTransferLimit(uint64 limit) onlyOwner public {
        transferLimit = limit ;
    }
    
    function getHolding(address holder) view public returns(uint64) {
        return balances[holder] ;
    }
    
    function getOutstanding() view public returns(uint64) {
        return totalSupply - totalAllocation;
    }
}

