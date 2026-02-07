// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IPoolManager } from "lib/v4-core/src/interfaces/IPoolManager.sol";
import { PoolKey } from "lib/v4-core/src/types/PoolKey.sol";
import { Currency } from "lib/v4-core/src/types/Currency.sol";
import { IHooks } from "lib/v4-core/src/interfaces/IHooks.sol";
import { ILiquidityExecutor } from "./PaymentManager.sol";

contract UniswapV4Executor is ILiquidityExecutor {
    address public immutable paymentManager;
    IERC20 public immutable token;
    IPoolManager public immutable poolManager;

    PoolKey public poolKey;

    mapping(address => uint256) public balances;

    /// @dev sqrt(1) * 2^96 → 1:1 price
    uint160 internal constant SQRT_PRICE_1_1 = uint160(1 << 96);

    modifier onlyPaymentManager() {
        require(msg.sender == paymentManager, "Not PM");
        _;
    }

    constructor(
        address _paymentManager,
        address _token,
        address _poolManager
    ) {
        paymentManager = _paymentManager;
        token = IERC20(_token);
        poolManager = IPoolManager(_poolManager);

        // ---- Enforce correct token ordering (MANDATORY) ----
        address token0 = _token;
        address token1 = address(0); // ETH

        if (token0 > token1) {
            (token0, token1) = (token1, token0);
        }

        poolKey = PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(0))
        });
    }

    /*//////////////////////////////////////////////////////////////
                            POOL INIT ATTEMPT
    //////////////////////////////////////////////////////////////*/

    /// @notice One-time Uniswap v4 pool initialization attempt
    /// @dev May revert on Sepolia — this is expected and acceptable
    function initializePool() external {
        poolManager.initialize(poolKey, SQRT_PRICE_1_1);
    }

    /*//////////////////////////////////////////////////////////////
                        LIQUIDITY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /// @notice Called by PaymentManager via ILiquidityExecutor
    function deployLiquidityForUser(address user, uint256 amount)
        external
        onlyPaymentManager
        returns (uint256)
    {
        require(amount > 0, "Amount must be > 0");
        
        balances[user] += amount;
        token.approve(address(poolManager), amount);

        try poolManager.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams({
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: int256(amount),
                salt: bytes32(0)
            }),
            ""
        ) {
            // Success - return the amount minted (1:1 ratio for now)
            return amount;
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("deployLiquidity failed: ", reason)));
        } catch (bytes memory lowLevelData) {
            // If the low-level revert is Error(string) (0x08c379a0), decode inner string
            if (lowLevelData.length >= 4) {
                bytes4 sig;
                assembly {
                    sig := mload(add(lowLevelData, 32))
                }
                if (sig == 0x08c379a0) {
                    // slice off selector (4 bytes) and decode the string
                    uint256 strLen = lowLevelData.length - 4;
                    bytes memory sliced = new bytes(strLen);
                    for (uint256 i = 0; i < strLen; i++) {
                        sliced[i] = lowLevelData[i + 4];
                    }
                    // decode the inner revert string
                    string memory inner = abi.decode(sliced, (string));
                    revert(string(abi.encodePacked("deployLiquidity underlying: ", inner)));
                }
            }
            revert(string(abi.encodePacked("deployLiquidity low-level hex: ", _toHex(lowLevelData))));
        }
    }

    /// @notice Called before executing payment
    function withdrawForPayment(address user, uint256 amount)
        external
        onlyPaymentManager
        returns (uint256)
    {
        require(balances[user] >= amount, "Not enough liquidity");
        balances[user] -= amount;
        token.approve(address(poolManager), amount);

        try poolManager.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams({
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: -int256(amount), // ✅ CORRECT SIGN
                salt: bytes32(0)
            }),
            ""
        ) {
            // Success - transfer tokens back to PaymentManager
            require(token.transfer(paymentManager, amount), "Transfer failed");
            return amount;
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("withdrawForPayment failed: ", reason)));
        } catch (bytes memory lowLevelData) {
            if (lowLevelData.length >= 4) {
                bytes4 sig;
                assembly {
                    sig := mload(add(lowLevelData, 32))
                }
                if (sig == 0x08c379a0) {
                    uint256 strLen = lowLevelData.length - 4;
                    bytes memory sliced = new bytes(strLen);
                    for (uint256 i = 0; i < strLen; i++) {
                        sliced[i] = lowLevelData[i + 4];
                    }
                    string memory inner = abi.decode(sliced, (string));
                    revert(string(abi.encodePacked("withdrawForPayment underlying: ", inner)));
                }
            }
            revert(string(abi.encodePacked("withdrawForPayment low-level hex: ", _toHex(lowLevelData))));
        }
    }

    // Convert bytes to hex string (lowercase)
    function _toHex(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint8(data[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}
