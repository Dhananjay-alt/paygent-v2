//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ILiquidityExecutor} from "./PaymentManager.sol";
import {IERC20} from "./PaymentManager.sol";

contract MockLiquidityExecutor is ILiquidityExecutor {
    IERC20 public token;
    mapping(address => uint256) public liquidity;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    function deployLiquidity(uint256 amount) external returns (uint256) {
        //Simulate Liquidity mint
        liquidity[msg.sender] += amount;
        return amount;
    }
    function deployLiquidityForUser(
        address user,
        uint256 amount
    ) external returns (uint256) {
        liquidity[user] += amount;
        return amount;
    }

    function depositFromManager(uint256 amount) external {
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Deposit from manager failed");
    }

    function withdrawForPayment(
        address user,
        uint256 amount
    ) external returns (uint256) {
        //Simulate withdrawal
        require(liquidity[user] >= amount, "Not enough liquidity");
        
        require(token.transfer(msg.sender, amount), "Transfer failed");

        liquidity[user] -= amount;
        return amount;
    }
    function depositFor(address user, uint256 amount) external {
    liquidity[user] += amount;
    }

}
