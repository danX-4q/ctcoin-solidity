pragma solidity ^0.4.24;

contract ctcoin{

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint            _value,
        string          _remark
    );

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    //caller -> CT; need amount for msg.value
    function deposit() public payable {
        require(msg.value > 0, "must provide amount to set msg.value");
        
        //do not need it; msg.value transfer to address(this) by program 
        //address(this).transfer(msg.value);
        
        address _from = msg.sender;
        address _to = address(this);
        uint _value = msg.value;
        emit Transfer(_from, _to, _value, "@deposit, caller -> CT");
    }
    
    //CT -> X
    function transport(address _to, uint _value) public payable {
        address _this = address(this);
        require(_this.balance >= _value, "@_value must <= _this.balance");
        
        _to.transfer(_value);
        emit Transfer(_this, _to, _value, "@transport, CT -> X");
    }

    //CT -> caller
    function refund(uint _refund_value) public payable {
        address _this = address(this);
        address _to = msg.sender;
        require(_this.balance >= _refund_value, "@_refund_value must <= _this.balance");
        _to.transfer(_refund_value);
        emit Transfer(_this, _to, _refund_value, "@refund, CT -> caller");
    }

    //any address, include the contract owner
    //return balance with unit wei
    function getbalance(address _addr) public view returns (uint) {
        return _addr.balance;
    }

/*  incorrect example, x->y must trunover by CT
    //X -> Y; need amount for msg.value
    function transferXY(address _from, address _to, uint _value) public payable {
        require(msg.value > _value);
        uint _refund_value = msg.value - _value;
        address _this = address(this);
        
        _to.transfer(_value);
        _from.transfer(_refund_value);
        
        emit Transfer(_from, _to, _value);
        emit Transfer(_this, _from, _refund_value);
    }
*/

    //caller -> CT -> Y; need amount for msg.value
    function transferCCY(address _to, uint _value) public payable {
        address _this = address(this);
        address _from = msg.sender;
        require(msg.value > 0, "must provide amount to set msg.value");
        require(msg.value >= _value, "@_value must <= msg.value");
        uint _refund_value = msg.value - _value;
        
        //step1
        //  do not need it; msg.value transfer to address(this) by program 
        //  address(this).transfer(msg.value);
        //--
        //step2
        if (_refund_value > 0) {
            _from.transfer(_refund_value);
        }
        //--
        //step3
        _to.transfer(_value);
        //--
        //when this.balance == 0, step1->step2->step3 also execute correctly
        //  this mean: do not need the contract store `value` for trunover
        
        emit Transfer(_from, _this, msg.value, "@transferCCY, caller -> CT");
        if (_refund_value > 0) {
            emit Transfer(_this, _from, _refund_value, "@transferCCY, CT -> caller for refund");
        }
        emit Transfer(_this, _to, _value, "@transferCCY, CT -> Y");
    }

}