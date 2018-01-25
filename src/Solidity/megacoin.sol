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

contract TransferLimited {
    uint64 transferLimit;
    
    function TransferLimited() public {
        
    }
    
    modifier withTransferLimit(address to, uint64 amount) {
        if (amount > transferLimit) {
            return ;
        }
        _ ;
    }
    
    function setTransferLimit(uint64 limit) public {
        transferLimit = limit ;
    }
}

contract AccessControlled {
    
    mapping(address=>bool) whiteList ;
    function AccessControlled() public {
        addAddress(msg.sender) ;
    }
    function addAddress(address _addr) public {
        whiteList[_addr] = true ;
    }
    modifier withAccessControl(address _addr) {
        if (!whiteList[_addr]) {
            return ;
        } 
        _ ;
    }
    
}

contract MegaCoin is Ownable, TransferLimited, AccessControlled  {
    
    string public name ;
    string public symbol ;
    uint64 totalSupply ;
    uint64 totalAllocation ;
    mapping(address => uint64) balances ;
    address owner ;
    
    event Transfer(address to, uint64 amount, uint64 outstanding) ;
    event InsufficientFunds(address to, uint64 value, uint64 totalOutstanding);
    event OverflowCondition(address to, uint64 balance, uint64 amount) ;

    function MegaCoin(string _name, string _symbol, uint64 _totalSupply) public {
        owner = msg.sender ;  
        name = _name ;
        symbol = _symbol ;
        totalSupply = _totalSupply ;
        setTransferLimit(100) ;
    }
    
    function allocate(address to, uint64 amount) public onlyOwner withTransferLimit(to ,amount) returns(bool) {
        uint64 available = totalSupply - totalAllocation ;
        if (amount > available) {
            InsufficientFunds(to, amount, available) ;
            return ;
        }
        
        // Checks for overflow of uint64 type
        if (balances[to] + amount < balances[to]) {
            OverflowCondition(to, balances[to], amount) ;
            return ;
        }
        
        totalAllocation += amount ;
        balances[to] += amount ;
        Transfer(to, amount, available - amount) ;
        return true ;
    }
    
    function getHolding(address holder) view public withAccessControl(msg.sender) returns(uint64) {
        return balances[holder] ;
    }
    
    function getOutstanding() view public withAccessControl(msg.sender) returns(uint64){
        return totalSupply - totalAllocation;
    }
}