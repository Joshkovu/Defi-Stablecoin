// SPDX-License-Identifier:MIT

// Layout of Contract:
// license
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity ^0.8.19;

/**
 * @title DSCEngine contract
 * @author Kuteesa Joash
 * The system is designed to be as minimal as possible , and have the tokens maintain a 1 token = $1 peg.
 * This stablecoin has the properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees and was only backed by wETH or wBTC
 *
 * Our Dsc system should always be "over collateralized". At no point should the value of the collateral be equal to the DSc available
 * @notice This contract has the core of the DSC System. It handles all the logic for mining and redeeming  DSC as well as depositing and withdrawing collateral.
 *
 * @notice This contract is very loosely based on the MakerDAO DSS(DAI) system.
 */
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DSCEngine is ReentrancyGuard {
    ///////////////
    // Errors //
    ////////////
    error DSCEngine__MustBeMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    /////////////////////
    // State Variables //
    /////////////////////
    mapping(address token => address priceFeed) private sPriceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        private sCollateralDeposited;
    mapping(address user => uint256 amountDscMinted) private sDscMinted;

    uint256 private constant ADDITIONAL_FEE_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    address[] private sCollateralTokens;
    DecentralizedStableCoin private immutable I_DSC;

    ///////////////
    // Events //
    ////////////
    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );

    ///////////////
    // Modifiers //
    ////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__MustBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (sPriceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    ///////////////
    // Functions //
    ////////////
    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        //example ETH/USD,BTC
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            sPriceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            sCollateralTokens.push(tokenAddresses[i]);
        }
        I_DSC = DecentralizedStableCoin(dscAddress);
    }

    ///////////////////////
    // External Functions //
    ////////////////////////

    function depositCollateralAndMintDsc() external {}

    /**
     * @notice follows CEI
     * @param tokenCollateralAddress-The address of the token to deposit as collateral
     * @param amountCollateral - The amount of collateral to deposit
     */

    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        sCollateralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        emit CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function burnDsc() external {}

    // check if the collateral value > DSC value
    /**
     *
     * @param amountDscToMint The amount of decentralized stablecoin to mint
     * @notice they must have more collateral
     */

    function mintDsc(
        uint256 amountDscToMint
    ) external moreThanZero(amountDscToMint) nonReentrant {
        sDscMinted[msg.sender] += amountDscToMint;
        // if they minted too much (150 DSC, 100 ETH)
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function Liquidate() external {}

    function getHealthFactor() external view {}

    /////////////////////////////////
    // Private & Internal View Functions //
    /////////////////////////////////
    function _getAccountInformation(
        address user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = sDscMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /**
     *
     * @param user - Returns how close to liquidation a user is
     * If a user gets below 1 , then they can get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        //Total DSC minted
        //Total collateral value
        (
            uint256 totalDscMinted,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(user);
        return totalDscMinted / collateralValueInUsd;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        //check health factor , else revert if its broken
    }

    /////////////////////////////////
    // Public & External View Functions //
    /////////////////////////////////
    function getAccountCollateralValue(
        address user
    ) public view returns (uint256 totalCollateralValueInUsd) {
        //loops through each collateral token, gets the amount they have deposited and maps it to the
        //price , to get the USD value
        for (uint256 i = 0; i < sCollateralTokens.length; i++) {
            address token = sCollateralTokens[i];
            uint256 amount = sCollateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            sPriceFeeds[token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // 1 ETH = $1000
        // The returned value from CL will be 1000 * 1e8
        return
            (amount * (uint256(price) * ADDITIONAL_FEE_PRECISION)) / PRECISION;
    }
}
