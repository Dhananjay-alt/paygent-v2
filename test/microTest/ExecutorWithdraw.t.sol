//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { Test } from "lib/forge-std/src/Test.sol";
import { MockLiquidityExecutor } from "../../contracts/MockLiquidityExecutor.sol";
import { MockUSDC } from "../../contracts/MockUSDC.sol";
import { PaymentManager } from "../../contracts/PaymentManager.sol";

contract ExecutorWithdrawTest is Test {
    MockUSDC token;
    PaymentManager manager;
    MockLiquidityExecutor executor;

    address user = address(0x123);
    address merchant = address(0x456);

    function setUp() public {
        token = new MockUSDC();
        executor = new MockLiquidityExecutor(address(token));
        manager = new PaymentManager(address(token), address(0)); // Pass dummy reader
        manager.setExecutor(address(executor));

        // Fund the executor with tokens to simulate liquidity
        token.mint(user, 1000 * 1e6); // Mint 1000 USDC to user

        // User deposits
        vm.startPrank(user);
        token.approve(address(manager), 500 * 1e6); // Approve executor to spend user's tokens
        manager.deposit(300 * 1e6); // User deposits 200 USDC
        vm.stopPrank();

        //Deploy liquidity (this must call esxecutor.depositFor internally)
        manager.setExecutionMode(PaymentManager.ExecutionMode.ACTIVE); // Manually set to active for testing
        manager.deployLiquidityFromVault(user, 200 * 1e6);
    }
    

    // To uncomment when we want to test the full flow of executeScheduledPayment which calls withdrawForPayment internally
    // Note: This requires the full flow to be implemented and may need adjustments based on how the strategy reading and scheduling is set up.
    // like uncommenting the ownerAddress function in PaymentManager and ensuring the strategy is properly set for the test.
    /*function testExecuteScheduledPayment() public{
        // Move time forward past interval
        vm.warp(block.timestamp + 31);
        
        uint256 nextTime = manager.nextPaymentTime(user);
        emit log_uint(nextTime);

        address owner = manager.ownerAddress();
        // Call as owner / agent
        vm.prank(owner);
        manager.executeScheduledPayment(user,merchant);

        // Minimal assertion: function did not revert
        assertTrue(true);
    }*/


    /*function testWithdrawForPayment() public {
    uint256 initialLiquidity = 200 * 1e6;
    uint256 withdrawAmount = 100 * 1e6;

    executor.depositFor(user, initialLiquidity);

    uint256 withdrawn = executor.withdrawForPayment(user, withdrawAmount);

    assertEq(withdrawn, withdrawAmount);
    assertEq(executor.liquidity(user), initialLiquidity - withdrawAmount);
}*/
}
