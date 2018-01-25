a solidity ^0.4.2 ;

contract MegaCoin {
    
    string public name ;
    string public symbol ;
    uint64 totalSupply ;
    uint64 totalAllocation ;
    mapping(address => uint64) balances ;
    address owner ;
    
    event Transfer(address to, uint64 amount, uint64 outstanding) ;
    event InsufficientFunds(address to, uint64 value, uint64 totalOutstanding);
    
    modifier ownerOperation() {
        require(owner == msg.sender) ;
        _ ;
    }
    
    function MegaCoin(string _name, string _symbol, uint64 _totalSupply) public {
        owner = msg.sender ;  
        name = _name ;
        symbol = _symbol ;
        totalSupply = _totalSupply ;
    }
    
    function allocate(address to, uint64 amount) ownerOperation public {
        uint64 available = totalSupply - totalAllocation ;
        if (amount <= available) {
            totalAllocation += amount ;
            balances[to] += amount ;
            Transfer(to, amount, available - amount) ;
        } else {
            InsufficientFunds(to, amount, available) ;
        } 
    }
    
    function getHolding(address holder) view public returns(uint64) {
        return balances[holder] ;
    }
    
    function getOutstanding() view public returns(uint64) {
        return totalSupply - totalAllocation;
    }
}

