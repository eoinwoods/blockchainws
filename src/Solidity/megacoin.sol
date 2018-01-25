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
    event TransferLimitExceeded(address to, uint64 value, uint64 transferLimit);
    
    function TransferLimited() public {
        
    }
    
    modifier withTransferLimit(address to, uint64 amount) {
        if (amount > transferLimit) {
            //TransferLimitExceeded(to, amount, transferLimit);
            return ;
        }
        _ ;
    }
    
    function setTransferLimit(uint64 limit) public {
        transferLimit = limit ;
    }
}

contract AccessControlled {
    event AccessDenied(address addr) ;
    
    mapping(address=>uint64) whiteList ;
    function AccessControlled() public {
        addAddress(msg.sender) ;
    }
    function addAddress(address _addr) public {
        whiteList[_addr] = 1 ;
    }
    modifier withAccessControl(address _addr) {
        if (whiteList[_addr] != 1) {
           // AccessDenied(_addr) ;
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

    function MegaCoin(string _name, string _symbol, uint64 _totalSupply) public {
        owner = msg.sender ;  
        name = _name ;
        symbol = _symbol ;
        totalSupply = _totalSupply ;
        setTransferLimit(100) ;
    }
    
    function allocate(address to, uint64 amount) public onlyOwner withTransferLimit(to ,amount) {
        uint64 available = totalSupply - totalAllocation ;
        if (amount > available) {
            InsufficientFunds(to, amount, available) ;
            return ;
        }
        
        totalAllocation += amount ;
        balances[to] += amount ;
        Transfer(to, amount, available - amount) ;
    }
    
    function getHolding(address holder) view public withAccessControl(msg.sender) returns(uint64) {
        return balances[holder] ;
    }
    
    function getOutstanding() view public withAccessControl(msg.sender) returns(uint64){
        return totalSupply - totalAllocation;
    }
}

