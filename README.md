## 🪙 Defi-Stablecoin (DSC)
# 📖 Description

The Defi-Stablecoin (DSC) project is an implementation of a decentralized, exogenous, overcollateralized stablecoin system.
The stablecoin is pegged to a target value (e.g. 1 USD) and is backed by external crypto collateral (such as ETH), rather than an algorithmic or endogenous token.

The stablecoin is named Decentralized Stable Coin with the symbol DSC.

The goal of this project is to explore how decentralized stablecoins work at a protocol level, including:

- Collateral management

- Minting and burning mechanics

- Liquidation logic

- Security testing using fuzzing

This project was built as a learning-focused smart contract system with an emphasis on correctness, security, and testing.

# 📑 Table of Contents

- Getting Started

- Project Structure

- What I Have Learned

- Future Improvements

- Appreciation

# 🚀 Getting Started

# Prerequisites

Make sure you have the following installed:

Git

Foundry

Node.js (optional, depending on tooling)

# Installation & Setup
# Clone the repository
```solidity
git clone https://github.com/Joshkovu/Defi-StableCoin.git
cd Defi-StableCoin

# Install dependencies
forge install

# Compile contracts
forge build

# Run tests
forge test -vvv
```
# 🗂 Project Structure

This is a sample structure — you can adjust it to match your actual repository.

```
├── src/
│   ├── DecentralizedStableCoin.sol          # ERC20 stablecoin contract
│   ├── DSCEngine.sol                        # Core logic: minting, burning, liquidation
│   └── libraries/
│       └── OracleLib.sol                    # Price feed helpers
│
├── script/
│   ├── DeployDSC.s.sol                      # Deployment script
│   └── HelperConfig.s.sol                   # Network & configuration helpers
│
├── test/
│   ├── unit/
│   │   ├── DSCEngineTest.t.sol 
│   │   └── DecentralisedStableCoinTest.t.sol   
│   └── mocks/
│   |    └── MockV3Aggregator.sol
│   ├── fuzz/
│   │   ├── Handler.t.sol 
│   │   └── InvariantsTest.t.sol 

├── lib/
│   └── chainlink-brownie-contracts/
|   └── forge-std/
|   └── openzeppelin-contracts/
│
├── foundry.toml
└── README.md
```
# 🧠 What I Have Learned

Through this project, I gained a much deeper understanding of secure smart contract development, especially around testing and protocol design.

# 🔍 Fuzz Testing

I learned how to use fuzz testing as a stress-testing technique to break the system and uncover hidden vulnerabilities by supplying random and edge-case inputs.

- Stateless Fuzzing
Each test starts from the same initial state. This is useful for validating individual function invariants in isolation.

- Stateful Fuzzing
The state of the contract persists between tests. Each test builds on the previous one, making it ideal for detecting bugs that only appear after a sequence of interactions.

I also learned how OpenZeppelin’s ERC20Burnable can be leveraged during fuzz testing to simulate real-world token flows and edge cases.

# 🔥 Minting vs Burning

- Minting -
Minting is the process of converting collateral (e.g. ETH) into DSC.
A user can only mint DSC if they have deposited enough collateral above the minimum collateralization threshold.

Example:

If the system requires 150% collateralization

A user depositing 150 USD worth of ETH can only mint 100 DSC

- Burning -
Burning DSC destroys the token and reduces the user’s debt, allowing them to reclaim their collateral.

# ⚠️ Liquidation Mechanics

If a user’s collateral value falls below the required threshold:

Their position becomes undercollateralized

The user can be liquidated

Liquidators repay the user’s DSC debt and receive the collateral at a discount (incentive)

This mechanism ensures the system remains solvent and the stablecoin peg is protected.

# 🏦 Overcollateralization

I learned that overcollateralization is a core safety mechanism for decentralized stablecoins.

The value of deposited collateral must always exceed the value of minted DSC

This protects the protocol against:

Market volatility

Oracle delays

Sudden price crashes

Overcollateralization trades capital efficiency for system safety and decentralization.

# 🛠 Deployment & Helper Scripts

I gained a clearer understanding of:

Deploy scripts — automate contract deployment and reduce manual errors

Helper scripts — manage network-specific configuration (price feeds, addresses, chain IDs)

These scripts significantly improve developer experience and reproducibility.

# 🔮 Future Improvements

- Increase unit test coverage

- Add full integration tests

- Perform more extensive fuzz testing

- Improve invariant testing to better reflect real-world attack scenarios

- Optimize gas usage where possible

# 🙌 Appreciation

If you appreciate this project and my work, feel free to connect with me on my socials:

LinkedIn: https://linkedin.com/in/Joshkovu

Instagram: https://instagram.com/joa_shk

X (Twitter): https://x.com/joashkutee
