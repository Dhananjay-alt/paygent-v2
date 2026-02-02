//SPDX-LIcense-Identifier: MIT

pragma solidity ^0.8.19;

import { ENSStrategyReader } from "./ENSStrategyReader.sol";
import { Maths } from "./utils/Maths.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
contract PaymentManager {
    address private owner;
    ENSStrategyReader reader = new ENSStrategyReader(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    
    address private immutable i_ensRegistryAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e; // Mainnet ENS Registry Address
    IERC20 public immutable token;

    using Maths for string;

    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event PaymentExecuted(address indexed user, address indexed merchant, uint256 amount);

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Cannot deposit zero amount");

        //address resolvedRecipient = resolveRecipient(recipient);

        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        balances[msg.sender] += amount;

        emit Deposit(msg.sender, amount);

    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function getTotalDeposits() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getStrategyTexts(bytes32 node) external view returns (
        string memory pool,
        string memory paymentAmount,
        string memory risk,
        string memory rebalanceThreshold
    ) {
       //ENSStrategyReader reader = new ENSStrategyReader(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e); // Mainnet ENS Registry Address
        return reader.readStrategyTexts(node);
    }

    /*function executePayment(address merchantAddress) external {
        (string memory pool, string memory paymentAmountStr, , ) = this.getStrategy(keccak256(abi.encodePacked(merchantAddress)));
        uint256 paymentAmount = parseUint(paymentAmountStr);
        require(balances[msg.sender] >= paymentAmount, "Insufficient balance");
        balances[msg.sender] -= paymentAmount;

        bool success = token.transferFrom(address(this), merchantAddress, paymentAmount);
        require(success, "Payment transfer failed");
    }*/

    function executePayment(address user, bytes32 strategyNode, address merchantAddress) external {
        
        require(msg.sender == owner, "Not authorized");

        require(merchantAddress != address(0), "Invalid merchant");

        //ENSStrategyReader reader = new ENSStrategyReader(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

        (, string memory paymentAmountStr, , ) = reader.readStrategyTexts(strategyNode);

        uint256 paymentAmount =paymentAmountStr.parseInt();

        require(paymentAmount > 0,"Invalid payment amount");

        require(balances[user] >= paymentAmount, "Insufficient balance");

        balances[user] -= paymentAmount;

        bool success = token.transferFrom(address(this), merchantAddress, paymentAmount);
        require(success, "Payment transfer failed");

        emit PaymentExecuted(user, merchantAddress, paymentAmount);
    }
    
}