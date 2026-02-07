// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import { PaymentManager } from "./PaymentManager.sol";

contract PaymentAutomation is AutomationCompatibleInterface {
    PaymentManager public immutable paygent;
    address public immutable user;

    constructor(address _paygent, address _user) {
        require(_paygent != address(0), "invalid paygent");
        require(_user != address(0), "invalid user");

        paygent = PaymentManager(_paygent);
        user = _user;
    }

    /**
     * @notice Called off-chain by Chainlink Automation nodes
     */
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        if (
            paygent.isExecutionModeActive(user) &&
            block.timestamp >= paygent.nextPaymentTime(user)
        ) {
            return (true, abi.encode(user));
        }

        return (false, "");
    }

    /**
     * @notice Called on-chain by Chainlink Automation
     */
    function performUpkeep(
        bytes calldata performData
    ) external override {
        address u = abi.decode(performData, (address));
        paygent.executeScheduledPayment(u);
    }
}
