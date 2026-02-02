// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

//what are our invariants
// 1. The total supply of DSC should be less than the total value of collateral
// 2. Getter view functions should never revert <- evergreen invariant
import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DeployDsc} from "script/DeployDsc.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "../fuzz/Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDsc deployer;
    DSCEngine engine;
    HelperConfig config;
    DecentralizedStableCoin dsc;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDsc();
        (dsc, engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(engine));
        handler = new Handler(engine, dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(engine));
        uint256 wEthValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 wBtcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);
        console.log("weth value:", wEthValue);
        console.log("wbtc value:", wBtcValue);
        console.log("totalSupply:", totalSupply);
        // console.log("totalSupply:", handler.timesMintIsCalled);
        console.log("Times mint called", handler.timesMintIsCalled());
        assert(wEthValue + wBtcValue >= totalSupply);
    }

    function invariant_gettersShouldNotRevert() public view {
        engine.getCollateralTokens();
        engine.getCollateralDeposited(msg.sender, weth);
        engine.getDscMinted(msg.sender);
        engine.getCollateralBalanceOfUser(msg.sender, weth);
        engine.getAccountInformation(msg.sender);
        engine.getLiquidationThreshold();
        engine.getMinHealthFactor();
        engine.getCollateralTokenPriceFeed(weth);
        engine.getHealthFactor(msg.sender);
        engine.getLiquidationBonus();
    }
}
