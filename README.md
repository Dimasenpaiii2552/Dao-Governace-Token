# DAO Governance Token

A compact, production-ready **DAO governance stack** built with **OpenZeppelin Governor** and **ERC20Votes**. Token holders can **propose**, **vote**, and **execute** on-chain actions via a **Timelock**.

> Works great as a starter kit for DAOs, protocol parameters, treasury actions, or upgrade governance.

---

## ✨ Features

- **GovToken (ERC20Votes)** — vote power = delegated token balance  
- **MyGovernor (OpenZeppelin Governor)** — proposal lifecycle with quorum, voting delay & period  
- **TimelockController** — queued execution with a minimum delay (time-based)  
- **Example Target (`Box`)** — simple contract the DAO can update to demo end-to-end flow  
- **Foundry** test suite — fast local dev, forking, and fuzzing ready

---

## 🧱 Architecture


**Key flow**
1. Propose (Governor)  
2. Wait for `votingDelay` (blocks)  
3. Vote during `votingPeriod` (blocks)  
4. Proposal **succeeds** -> queue in **Timelock**  
5. After `minDelay` (seconds), **execute**

---

## 📦 Contracts (typical names)

- `src/GovToken.sol` — ERC20, ERC20Permit, ERC20Votes
- `src/MyGovernor.sol` — OZ Governor + settings (quorum, voting delay/period)
- `src/TimelockController.sol` — OZ Timelock
- `src/Box.sol` — example target contract (has `storeNumber(uint256)`)

> If your repo uses different names, update here and in the snippets below.

---

## 🛠️ Requirements

- **Foundry** (Forge/Cast): <https://book.getfoundry.sh/getting-started/installation>
- Node ≥ 18 (optional, if you integrate scripts/tools)
- A network RPC for testnet/mainnet deploys (optional)

---

## ⚙️ Setup

```bash
# Clone
git clone https://github.com/Dimasenpaiii2552/Dao-Governace-Token
cd Dao-Governace-Token

# Foundry
foundryup

# Install deps (if using submodules or remappings)
forge install

# Compile
forge build

# Run all tests
forge test -vv

# Single test file (example)
forge test -vvv --match-path test/MyGovernorTest.t.sol

