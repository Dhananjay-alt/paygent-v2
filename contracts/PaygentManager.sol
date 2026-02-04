//SPDX-LIcense-Identifier: MIT

pragma solidity ^0.8.19;

import {ENSStrategyReader} from "./ENSStrategyReader.sol";
import {Maths} from "./utils/Maths.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ILiquidityExecutor {
  function deployLiquidityForUser(address user, uint256 amount)
    external
    returns (uint256);
  function withdrawForPayment(address user, uint256 amount) external returns (uint256);
}

contract PaymentManager {
  enum ExecutionMode {
    IDLE,
    ACTIVE
  }

  address private owner;
  ENSStrategyReader private reader;
  IERC20 public token;
  ExecutionMode public currentMode = ExecutionMode.IDLE;
  bytes32 public activeStrategyNode;
  mapping(address => uint256) public nextPaymentTime;

  ILiquidityExecutor public executor;

  using Maths for string;

  event Deposit(address indexed user, uint256 amount);
  event PaymentExecuted(
    address indexed user,
    address indexed merchant,
    uint256 amount
  );
  event LiquidityDeployed(
    address indexed user,
    uint256 amount,
    uint256 liquidityMinted
  );

  constructor(address _tokenAddress, address readerAddress) {
    require(_tokenAddress != address(0), "Invalid token address");
    token = IERC20(_tokenAddress);
    reader = ENSStrategyReader(readerAddress);
    owner = msg.sender;
  }
  modifier onlyAgent() {
    require(msg.sender == owner, "Not authorized");
    _;
  }
  struct Position {
    uint256 liquidity;
    uint256 lastValue;
  }

  mapping(address => Position) public positions;
  mapping(address => uint256) public vaultBalance;
  function setExecutor(address _executor) external {
    require(msg.sender == owner, "Not authorized");
    require(_executor != address(0), "Invalid executor");
    executor = ILiquidityExecutor(_executor);
}


  function deposit(uint256 amount) external {
    require(amount > 0, "Cannot deposit zero amount");

    bool success = token.transferFrom(msg.sender, address(this), amount);
    require(success, "Token transfer failed");

    vaultBalance[msg.sender] += amount;

    emit Deposit(msg.sender, amount);
    if (nextPaymentTime[msg.sender] == 0) {
      nextPaymentTime[msg.sender] = block.timestamp;
    }
  }

  function getBalance(address user) external view returns (uint256) {
    return vaultBalance[user];
  }

  function getTotalDeposits() external view returns (uint256) {
    return token.balanceOf(address(this));
  }

  function startStrategyExecution(bytes32 node) external {
    require(msg.sender == owner, "Not authorized");
    require(
      currentMode == ExecutionMode.IDLE,
      "Strategy already running or settled"
    );

    activeStrategyNode = node;
    currentMode = ExecutionMode.ACTIVE;
  }

  function getStrategyTexts(
    bytes32 strategyNode
  )
    external
    view
    returns (
      string memory pool,
      uint256 paymentAmount,
      uint256 paymentInterval,
      uint256 rebalanceThreshold
    )
  {
    require(strategyNode == activeStrategyNode, "Strategy not active");

    ENSStrategyReader.Strategy memory s = reader.readStrategy(strategyNode);

    return (s.pool, s.paymentAmount, s.paymentInterval, s.rebalanceThreshold);
  }

  function executeScheduledPayment(
    address user,
    address merchantAddress
  ) external onlyAgent {
    require(currentMode == ExecutionMode.ACTIVE, "Not active");
    require(block.timestamp >= nextPaymentTime[user], "Payment not due");

    //( ,uint256 paymentAmount,uint256 paymentInterval, ) = reader.readStrategy(activeStrategyNode);

    //(, uint256 paymentAmount, uint256 paymentInterval, ) = this
    //  .getStrategyTexts(activeStrategyNode);
    uint256 paymentAmount = 100000000; // 100 USDC
    uint256 paymentInterval = 30 days;


    // 1. Pull liquidity back into vault
    uint256 received = executor.withdrawForPayment(user, paymentAmount);
    require(received >= paymentAmount, "Withdraw failed");

    // 2. Update vault
    vaultBalance[user] += paymentAmount;

    // 3. Pay merchant
    require(vaultBalance[user] >= paymentAmount, "Vault insufficient");
    vaultBalance[user] -= paymentAmount;

    token.transfer(merchantAddress, paymentAmount);

    // 4. Update accounting
    if (positions[user].lastValue >= paymentAmount) {
      positions[user].lastValue -= paymentAmount;
    }

    // 5. Schedule next payment
    nextPaymentTime[user] = block.timestamp + paymentInterval;

    emit PaymentExecuted(user, merchantAddress, paymentAmount);
  }
  function deployLiquidityFromVault(
    address user,
    uint256 amount
  ) external onlyAgent {
    require(currentMode == ExecutionMode.ACTIVE, "Strategy not active");
    require(amount > 0, "Zero amount");
    require(vaultBalance[user] >= amount, "Insufficient vault balance");

    token.transfer(address(executor), amount);

    //  Deploy liquidity
    uint256 liquidityMinted = executor.deployLiquidityForUser(user, amount);
    require(liquidityMinted > 0, "Liquidity minty");

    //  Update vault
    vaultBalance[user] -= amount;

    //  Update position
    positions[user].liquidity += liquidityMinted;
    positions[user].lastValue += amount;

    emit LiquidityDeployed(user, amount, liquidityMinted);
  }

}
