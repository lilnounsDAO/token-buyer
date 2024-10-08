// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import 'forge-std/Script.sol';
import { Payer } from '../src/Payer.sol';
import { TokenBuyer } from '../src/TokenBuyer.sol';
import { PriceFeed } from '../src/PriceFeed.sol';
import { AggregatorV3Interface } from '../src/AggregatorV3Interface.sol';
import { TestERC20 } from '../test/helpers/TestERC20.sol';
import { MAINNET_USDC, MAINNET_USDC_DECIMALS, TECHPOD_MULTISIG, VERBS_OPERATOR } from './Constants.s.sol';
import { TestChainlinkAggregator } from '../test/helpers/TestChainlinkAggregator.sol';

contract DeployUSDCScript is Script {
    // PriceFeed config
    uint256 constant ETH_USD_CHAINLINK_HEARTBEAT = 1 hours;
    uint256 constant PRICE_UPPER_BOUND = 8_000e18; // max $8K / ETH
    uint256 constant PRICE_LOWER_BOUND = 100e18; // min $100 / ETH
}

contract DeployUSDCMainnet is DeployUSDCScript {
    uint256 constant USD_POSITION_IN_USD = 500_000;
    address constant MAINNET_ETH_USD_CHAINLINK = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // Lil Nouns
    address constant MAINNET_NOUNS_EXECUTOR = 0xd5f279ff9EB21c6D40C8f345a66f2751C4eeA1fB;

    function run() public {
        vm.startBroadcast();

        uint8 decimals = MAINNET_USDC_DECIMALS;

        Payer payer = new Payer(MAINNET_NOUNS_EXECUTOR, MAINNET_USDC);

        PriceFeed priceFeed = new PriceFeed(
            AggregatorV3Interface(MAINNET_ETH_USD_CHAINLINK),
            ETH_USD_CHAINLINK_HEARTBEAT,
            PRICE_LOWER_BOUND,
            PRICE_UPPER_BOUND
        );

        new TokenBuyer(
            priceFeed,
            USD_POSITION_IN_USD * 10**decimals, // baselinePaymentTokenAmount
            0, // minAdminBaselinePaymentTokenAmount
            2 * USD_POSITION_IN_USD * 10**decimals, // maxAdminBaselinePaymentTokenAmount
            10, // botDiscountBPs
            0, // minAdminBotDiscountBPs
            150, // maxAdminBotDiscountBPs
            MAINNET_NOUNS_EXECUTOR, // owner
            TECHPOD_MULTISIG, // admin
            address(payer)
        );

        vm.stopBroadcast();
    }
}

contract DeployUSDCGoerli is DeployUSDCScript {
    address constant GOERLI_USDC_CONTRACT = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
    address constant GOERLI_USD_ETH_CHAINLINK = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
    uint8 constant GOERLI_USDC_DECIMALS = 6;

    function run() public {
        vm.startBroadcast();

        Payer payer = new Payer(msg.sender, GOERLI_USDC_CONTRACT);

        PriceFeed priceFeed = new PriceFeed(
            AggregatorV3Interface(GOERLI_USD_ETH_CHAINLINK),
            ETH_USD_CHAINLINK_HEARTBEAT,
            PRICE_LOWER_BOUND,
            PRICE_UPPER_BOUND
        );

        new TokenBuyer(
            priceFeed,
            10_000 * 10**GOERLI_USDC_DECIMALS, // baselinePaymentTokenAmount
            0, // minAdminBaselinePaymentTokenAmount
            20_000 * 10**GOERLI_USDC_DECIMALS, // maxAdminBaselinePaymentTokenAmount
            0, // botDiscountBPs
            0, // minAdminBotDiscountBPs
            150, // maxAdminBotDiscountBPs
            msg.sender, // owner
            msg.sender, // admin
            address(payer)
        );

        vm.stopBroadcast();
    }
}

contract DeployUSDCSepolia is DeployUSDCScript {
    address constant SEPOLIA_USDC_CONTRACT = 0xEbCC972B6B3eB15C0592BE1871838963d0B94278;
    address constant SEPOLIA_USD_ETH_CHAINLINK = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint8 constant SEPOLIA_USDC_DECIMALS = 6;

    function run() public {
        vm.startBroadcast();

        Payer payer = new Payer(msg.sender, SEPOLIA_USDC_CONTRACT);

        PriceFeed priceFeed = new PriceFeed(
            AggregatorV3Interface(SEPOLIA_USD_ETH_CHAINLINK),
            ETH_USD_CHAINLINK_HEARTBEAT,
            PRICE_LOWER_BOUND,
            PRICE_UPPER_BOUND
        );

        new TokenBuyer(
            priceFeed,
            10_000 * 10**SEPOLIA_USDC_DECIMALS, // baselinePaymentTokenAmount
            0, // minAdminBaselinePaymentTokenAmount
            20_000 * 10**SEPOLIA_USDC_DECIMALS, // maxAdminBaselinePaymentTokenAmount
            0, // botDiscountBPs
            0, // minAdminBotDiscountBPs
            150, // maxAdminBotDiscountBPs
            msg.sender, // owner
            msg.sender, // admin
            address(payer)
        );

        vm.stopBroadcast();
    }
}

contract DeployUSDCLocal is DeployUSDCScript {
    uint8 constant USDC_DECIMALS = 6;

    function run() public {
        vm.startBroadcast();

        TestChainlinkAggregator chainlink = new TestChainlinkAggregator(18);
        TestERC20 usdc = new TestERC20('USDC', 'USDC', USDC_DECIMALS);

        Payer payer = new Payer(msg.sender, address(usdc));

        PriceFeed priceFeed = new PriceFeed(
            AggregatorV3Interface(chainlink),
            ETH_USD_CHAINLINK_HEARTBEAT,
            PRICE_LOWER_BOUND,
            PRICE_UPPER_BOUND
        );

        new TokenBuyer(
            priceFeed,
            500_000 * 10**USDC_DECIMALS, // baselinePaymentTokenAmount
            0, // minAdminBaselinePaymentTokenAmount
            1_000_000 * 10**USDC_DECIMALS, // maxAdminBaselinePaymentTokenAmount
            10, // botDiscountBPs
            0, // minAdminBotDiscountBPs
            150, // maxAdminBotDiscountBPs
            msg.sender, // owner
            msg.sender, // admin
            address(payer)
        );

        vm.stopBroadcast();
    }
}
