//SPDX-LIcense-Identifier: MIT

pragma solidity ^0.8.19;

import { ENSStrategyReader } from "./ENSStrategyReader.sol";
import { Maths } from "./utils/Maths.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract PaymentManager {

    /*enum ExecutionMode {
        IDLE,
        STRATEGY_RUNNING,
        SETTLED
    }*/
    struct ExecuteSession {
        bytes32 strategyNode;
        uint256 totalAmount;
        uint256 executionCount;
        address executor;
        bool active;
    }

    address private owner;
    ENSStrategyReader private reader;
    //ENSStrategyReader reader = new ENSStrategyReader(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    //address private immutable i_ensRegistryAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e; // Mainnet ENS Registry Address
    IERC20 public immutable token;
    //ExecutionMode public currentMode = ExecutionMode.IDLE;
    //bytes32 public activeStrategyNode;
    ExecuteSession public session;
    uint256 public sessionId;

    using Maths for string;

    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    //event PaymentExecuted(address indexed user, address indexed merchant, uint256 amount);
    event PaymentExecuted(
    uint256 sessionId,
    address user,
    uint256 amount,
    bytes32 strategyNode
    );
    event SessionSettled(
    uint256 sessionId,
    address merchant,
    uint256 totalAmount,
    uint256 executions
    );
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _tokenAddress, address readerAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
        reader = ENSStrategyReader(readerAddress);
        owner = msg.sender;
    }
    function startSession(bytes32 node) external onlyOwner {
        require(!session.active, "Session already active");

        session = ExecuteSession({
            strategyNode: node,
            totalAmount: 0,
            executionCount: 0,
            executor: msg.sender,
            active: true
        });

        sessionId++;

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

    /*function startStrategyExecution(bytes32 node) external {
        require(msg.sender == owner, "Not authorized");
        require(currentMode == ExecutionMode.IDLE, "Strategy already running or settled");
        
        activeStrategyNode = node;
        currentMode = ExecutionMode.STRATEGY_RUNNING;
    }*/

    function getStrategyTexts(bytes32 strategyNode) external view returns (
        string memory pool,
        string memory paymentAmount,
        string memory risk,
        string memory rebalanceThreshold
    ) {
        //require(strategyNode == activeStrategyNode, "Strategy not active");
        return reader.readStrategyTexts(strategyNode);
    }

    /*function executePayment(address merchantAddress) external {
        (string memory pool, string memory paymentAmountStr, , ) = this.getStrategy(keccak256(abi.encodePacked(merchantAddress)));
        uint256 paymentAmount = parseUint(paymentAmountStr);
        require(balances[msg.sender] >= paymentAmount, "Insufficient balance");
        balances[msg.sender] -= paymentAmount;

        bool success = token.transferFrom(address(this), merchantAddress, paymentAmount);
        require(success, "Payment transfer failed");
    }*/

    /*function executePayment(address user, bytes32 strategyNode, address merchantAddress) external {
        //require(currentMode == ExecutionMode.STRATEGY_RUNNING, "STRATEGY is not running");
        //require(msg.sender == owner, "Not authorized");

        //require(merchantAddress != address(0), "Invalid merchant");

        //ENSStrategyReader reader = new ENSStrategyReader(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

        //(, string memory paymentAmountStr, , ) = reader.readStrategyTexts(strategyNode);

        //uint256 paymentAmount =paymentAmountStr.parseInt();

        //require(paymentAmount > 0,"Invalid payment amount");

        //require(balances[user] >= paymentAmount, "Insufficient balance");

        //balances[user] -= paymentAmount;

        //bool success = token.transfer(merchantAddress, paymentAmount);
        //require(success, "Payment transfer failed");

        //emit PaymentExecuted(user, merchantAddress, paymentAmount);
        //currentMode = ExecutionMode.SETTLED;
    }*/

    function executePayment(address user, bytes32 strategyNode, address merchantAddress) external onlyOwner {
        require(session.active, "No active session");
        require(msg.sender == session.executor, "Not executor");
        require(strategyNode == session.strategyNode, "Wrong Strategy");

        ( , string memory paymentAmountStr, , ) = reader.readStrategyTexts(session.strategyNode);

        uint256 paymentAmount =paymentAmountStr.parseInt();

        require(paymentAmount > 0,"Invalid payment amount");

        require(balances[user] >= paymentAmount, "Insufficient balance");

        balances[user] -= paymentAmount;
        session.totalAmount += paymentAmount;
        session.executionCount += 1;

        emit PaymentExecuted(sessionId, user, paymentAmount, strategyNode);
    }
    function settleSession(address merchantAddress) external {
        require(session.active, "No active session");
        require(msg.sender == session.executor, "Not executor");

        uint256 amountToSettle = session.totalAmount;
        session.active = false;
        bool success = token.transfer(merchantAddress, amountToSettle);
        require(success, "Settlement transfer failed");
        emit SessionSettled(
            sessionId,
            merchantAddress,
            amountToSettle,
            session.executionCount
        );
    }
    function abortSession() external onlyOwner {
        require(session.active, "No active session");

        session.active = false;
    }
    /*function resetExecution() external {
        require(msg.sender == owner, "Not authorized");
        require(currentMode == ExecutionMode.SETTLED, "Strategy not settled");

        currentMode = ExecutionMode.IDLE;
        activeStrategyNode = bytes32(0);
    }*/
}