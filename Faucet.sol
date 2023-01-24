// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// interface IERC20{
//     function transfer(address to, uint256 amount) external returns(bool);
//     function balanceOf(address from) external view returns (uint256);
// }
contract Faucet {
    IERC20 public token;
    address payable owner;
    uint256 public lockInterval = 1 minutes;
    uint256 public WithdrawalAmount = 100*(10**18);
    mapping(address=>uint) nextRequestTime;

    event Deposit(address indexed from, uint256 indexed amount);

    constructor (address _token) payable {
        token = IERC20(_token);
        owner = payable(msg.sender);
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    function getFaucet(address requester) public {
        require(requester !=address(0), "invalid address");
        require(token.balanceOf(address(this))> WithdrawalAmount, "insufficient balance");
        require(block.timestamp>nextRequestTime[requester],"you can't get faucets now");

        nextRequestTime[requester] = block.timestamp + lockInterval;
        token.transfer(requester, WithdrawalAmount);
    }

    function faucetBalance() external onlyOwner view returns(uint256 bal){
        bal = token.balanceOf(address(this));
    }

    function setWithdrawAmount(uint256 newAmount) external onlyOwner{
        WithdrawalAmount = newAmount *(10**18);
    }

    function setLockInterval(uint256 _time) external onlyOwner{
        lockInterval = _time * 1 minutes;
    }

    function WithdrawFaucet() external onlyOwner{
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender==owner, "not the owner");
        _;
    }
}