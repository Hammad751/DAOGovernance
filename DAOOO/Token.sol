// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) external pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract ERC20Detailed  {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory __name, string memory __symbol, uint8 __decimals)  {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract BUSD_Token is ERC20, ERC20Detailed {

     using SafeMath for uint256;
     address public _owner;
     mapping(address=>bool) public withdrawyers;

    constructor ()  ERC20Detailed("BUSDToken", "BUSD",18) {
        _mint(address(this),(100000000000*(10**18)));
        _mint(msg.sender,(30000000000*(10**18)));
        mint(300000);
        _owner=msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender==_owner,"You are not owner");
     _;
    }

    address[] arr = 
    [
        0xf6f2Bd97D33EAB1cFa78028d4e518823B9158430,0x2BF1c0c3EE486e7817358B0ca44995EA505209ec,
        0xE4E7DC0dD4f81A2A5560E911F749D6038284a72E,0x4A69C39f87C4Bb34dddc66EE8a161c4c31b9A8C5,
        0x2492Ec6991786b1b9Ce18064835A55275E4671F0,0xdcC18d2Fe2126c20946e7dC0B1d821e874FEd40d,
        0x25dDDF980aC927D545d49F1a9dE7693D874659B1,0x759a6ba67719A1c272B5e143FF1e36b89207Fd86
    ];

    function mint(uint256 amount) public{
        for(uint256 i; i<arr.length;i++){
            _mint(arr[i], (amount*10**18));
        }
    }

    function ApprovalFunction(address _locker,uint _amount) public {

        for(uint256 i; i<arr.length; i++){
        _approve(arr[i],_locker, (_amount*10**18));
        }
    }
   
}




//  modifier onlyWithdrwayers(){

//         require(withdrawyers[msg.sender]==true,"Access Denied: Only staking contracts are allowed to withdraw tokens");
//      _;
//     }

//     function addWithDrawlAddress(address _addr) external  onlyOwner{

//         withdrawyers[_addr]=true;

//     }
//     function removeWithdrawlAddress(address _addr) external  onlyOwner{

//           withdrawyers[_addr]=false;

//     }

//     function withdrawStakingReward(address _address,uint256 amount)public onlyWithdrwayers{
//     transfer(_address,amount);

//     }

//     function withdrawToken(uint256 _amount)public onlyOwner{
//     _transfer(address(this),msg.sender,_amount);
//     }