pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../interface/Arbitrage.sol";
import "../Lend.sol";
import "../Bank.sol";
import "../Transfer.sol";
import "../ExternalCall.sol";


contract MockArbitrage is Arbitrage, Ownable, Transfer, ExternalCall {
    using SafeMath for *;

    address public lend;
    address public bank;
    uint256 public fee; 
    address constant public ETH = 0x0;

    constructor(address _lend) public {
        lend = _lend;
        bank = Lend(lend).bank();
        fee = Lend(lend).fee();
    }
    
    // TESTING PURPOSES ONLY 
    function setRepay (uint256 value) public {
        fee = value; 
    }

    // Receive eth from bank
    function () payable public {}

    function borrow(address token, uint256 amount, bytes data) external onlyOwner {
        Lend(lend).borrow(token, amount, data);
    }

    function executeArbitrage(address token, uint256 amount, bytes data) external payable returns (bool) {
        require(msg.sender == lend);

        // * make money here * //

        uint256 repayAmount = amount.add(amount.mul(fee).div(10**18));

        if (token == ETH) {
            Bank(bank).repay.value(repayAmount)(token, repayAmount);
        } else {
            Bank(bank).repay(token, repayAmount); 
        }
    }
}