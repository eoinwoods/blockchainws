 // Add owner functionality, try inheriting from Ownable
    // Try adding more detailed events to your contract
    // Add a modifier to limit the amount of tokens that can be transfered, then add a function to set the limit .
    // Can you add modifiers to the functions SimpleCoin to restrict access to the contracts to a whitelist of addresses ?


pragma solidity ^0.4.0;
contract Owned {
    address public owner;

    modifier only_owner() {
        if (msg.sender == owner) {
            _;
        }
    }
    event OwnerChanged(address oldOwner,address newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external only_owner {
        address oldOwner = owner;
        owner = _newOwner;
        OwnerChanged(oldOwner,_newOwner);
    }
}

contract SimpleCoin {
function totalSupply() constant returns (uint256 totalSupply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);

event Transfer(address indexed _from, address indexed _to, uint256 _value);

}

contract WorkshopCoin is SimpleCoin, Owned {
    // Useful contants: Name, symbol, total supply
    string public constant name = "Workshop Coin";
    string public constant symbol = "WSC";
    uint256 constant totSupply = 1000000;
    uint256 limit = 0;
    // Attributes to hold the necessary information

    // Balances for each account
    mapping(address => uint256) balances;

    address [] public whitelist;

    modifier withinLimit(uint256 _value){
        if ((limit==0) || (_value < limit)){
            _;
        }
    }
    event TransferDetails(address indexed _from, address indexed _to, uint256 _value,bool _success,uint256 _gas);

    // Constructor
    function WorkshopCoin() public {
        owner = msg.sender;
        balances[msg.sender] = totSupply;
    }

    // Functions that implement the SimpleCoin interface

    function totalSupply() public constant returns (uint256) {
        return totSupply;
    }

    // set the transfer limit
    function setLimit(uint256 _limit) public {
       limit = _limit;
    }

    function addToWhiteList(address _newAddress) public only_owner {
        if(checkWhiteList(_newAddress)==false){
             whitelist.push(_newAddress);
        }
    }

    function checkWhiteList(address _newAddress) public view returns (bool){
        bool found = false;
        for(uint256 ii=0;ii < whitelist.length;ii++){
            if(_newAddress==whitelist[ii]){
                found = true;
                break;
            }
        }
        return found;
    }


    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public only_owner withinLimit(_value) returns (bool success) {
        if(checkWhiteList(_to)==true){
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        TransferDetails(msg.sender, _to, _value,true,msg.gas);
        return true;
        }
        else{
            TransferDetails(msg.sender, _to, _value,false,msg.gas);
            return false;
        }
    }
}
     // To create an ERC20 compliant token base your token on ERC20 Coin
// Add the extra functions to your simple token contract

pragma solidity ^0.4.0;


contract ERC20Coin {
    function totalSupply() constant returns (uint256 totalSupply);

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract WorkshopCoin is ERC20Coin {
    // Useful contants: Name, symbol, total supply
    string public constant name = "Workshop Coin";

    string public constant symbol = "WSC";

    uint256 constant _totalSupply = 1000000;

    // Attributes to hold the necessary information

    // Owner of this contract
    address public owner;

    // Balances for each account
    mapping (address => uint256) balances;
    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    // Constructor
    function WorkshopCoin() public {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }

    // Functions that implement the SimpleCoin interface

    function totalSupply() public constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

