# Tomb Finance Smart Contracts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive smart contract implementation for Tomb Finance, an algorithmic stablecoin protocol built on Ethereum-compatible blockchains.

## Overview

Tomb Finance is a decentralized algorithmic stablecoin protocol that aims to maintain TOMB token price stability through a combination of seigniorage expansion and contraction mechanisms. The protocol consists of three main tokens:

- **TOMB**: The main stablecoin that targets $1 USD
- **TSHARE**: The governance and staking token
- **TBOND**: The bond token used during contraction phases

## Architecture

The protocol implements a sophisticated monetary policy system with the following key components:

### Core Contracts

- **`Tomb.sol`** - Main TOMB token contract with dynamic taxation and burn mechanisms
- **`Treasury.sol`** - Central monetary policy controller managing expansion/contraction
- **`Masonry.sol`** - Staking contract for TSHARE holders
- **`Oracle.sol`** - Price oracle for TOMB/USD pricing
- **`TaxOffice.sol`** - Dynamic tax calculation and collection system

### Token Economics

- **Seigniorage Expansion**: When TOMB price > $1, new tokens are minted and distributed
- **Seigniorage Contraction**: When TOMB price < $1, bonds are sold to reduce supply
- **Dynamic Taxation**: Adaptive tax rates based on price performance
- **Staking Rewards**: TSHARE holders earn from protocol revenue

## Features

- **Algorithmic Stability**: Automated price stabilization mechanisms
- **Dynamic Taxation**: Tiered tax system based on price performance
- **Liquidity Mining**: Reward pools for various token pairs
- **Governance**: TSHARE-based governance system
- **Timelock**: Secure multi-signature governance with time delays
- **Oracle Integration**: Reliable price feeds for monetary policy decisions

## Smart Contract Structure

```
contracts/
├── core/
│   ├── Tomb.sol              # Main TOMB token
│   ├── TShare.sol            # Governance token
│   ├── TBond.sol             # Bond token
│   └── Treasury.sol          # Monetary policy controller
├── distribution/
│   ├── TombRewardPool.sol    # TOMB reward distribution
│   ├── TShareRewardPool.sol  # TSHARE reward distribution
│   └── TombGenesisRewardPool.sol # Genesis pool rewards
├── governance/
│   ├── Masonry.sol           # Staking contract
│   ├── Timelock.sol          # Governance timelock
│   └── SimpleERCFund.sol     # Treasury fund management
├── oracle/
│   ├── Oracle.sol            # Price oracle
│   ├── TaxOracle.sol         # Tax calculation oracle
│   └── TaxOffice.sol         # Tax collection
├── interfaces/                # Contract interfaces
├── lib/                      # Utility libraries
├── owner/                    # Access control
└── utils/                    # Helper contracts
```

## Technical Specifications

- **Solidity Version**: 0.6.12
- **OpenZeppelin**: Latest compatible contracts for security
- **License**: MIT
- **Network**: Ethereum-compatible (originally Fantom Opera)

## Key Mechanisms

### 1. Seigniorage Expansion
- Triggers when TOMB price > $1.05
- New TOMB tokens minted and distributed to stakers
- Expansion rate decreases over time

### 2. Seigniorage Contraction
- Triggers when TOMB price < $0.95
- TBOND tokens sold at discount to reduce TOMB supply
- Contraction rate increases with price deviation

### 3. Dynamic Taxation
- Tax rates adjust based on price performance
- Higher taxes during poor performance periods
- Tax revenue used for protocol maintenance

### 4. Staking Rewards
- TSHARE holders stake to earn TOMB rewards
- Rewards proportional to stake amount and time
- Lock periods for enhanced rewards

## Security Features

- **Reentrancy Protection**: Guards against reentrancy attacks
- **Access Control**: Operator-based permissions for critical functions
- **Timelock**: Governance actions require time delays
- **Safe Math**: Overflow protection for all calculations
- **Oracle Validation**: Multiple price feed validation

## Development

### Prerequisites

- Node.js 14+
- Solidity 0.6.12
- Truffle or Hardhat framework

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/tombfinance-program.git
cd tombfinance-program

# Install dependencies
npm install

# Compile contracts
npx hardhat compile
```

### Testing

```bash
# Run tests
npx hardhat test

# Run with coverage
npx hardhat coverage
```

### Deployment

```bash
# Deploy to testnet
npx hardhat run scripts/deploy.js --network testnet

# Deploy to mainnet
npx hardhat run scripts/deploy.js --network mainnet
```

## Configuration

The protocol can be configured through various parameters:

- **Epoch Duration**: 6 hours (configurable)
- **Expansion Thresholds**: Price levels for triggering expansion
- **Contraction Limits**: Maximum supply reduction per epoch
- **Tax Tiers**: Dynamic tax rates based on performance
- **Reward Distribution**: Allocation percentages for different pools

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
