# WagonAssetIndex (WGNX) Token Contract

## Overview

`WagonAssetIndex` is an upgradeable ERC20 token contract that implements the WGNX (Wagon Asset Index) token. The contract is built using OpenZeppelin's upgradeable contracts and follows the UUPS (Universal Upgradeable Proxy Standard) pattern for upgradeability.

**Token Details:**
- **Name:** Wagon Asset Index
- **Symbol:** WGNX
- **Decimals:** 2
- **Standard:** ERC20 with extensions (Burnable, Pausable, Permit)

## Features

### Core Features
- ✅ **ERC20 Standard** - Full ERC20 token functionality
- ✅ **Burnable** - Token holders can burn their own tokens
- ✅ **Pausable** - Contract can be paused/unpaused for emergency situations
- ✅ **Permit** - Gasless approvals using EIP-2612
- ✅ **Upgradeable** - UUPS proxy pattern for contract upgrades
- ✅ **Access Control** - Role-based permissions for administrative functions

### Token Precision
The token uses **2 decimal places**, meaning:
- `100` = 1.00 WGNX
- `1000` = 10.00 WGNX
- `10000` = 100.00 WGNX

## Roles and Permissions

The contract implements role-based access control with the following roles:

### 1. DEFAULT_ADMIN_ROLE
- **Capabilities:**
  - Grant/revoke any role
  - Full administrative control
- **Initial Assignment:** Set during `initialize()`

### 2. PAUSER_ROLE
- **Capabilities:**
  - Pause the contract (stops all transfers)
  - Unpause the contract (resumes all transfers)
- **Use Case:** Emergency situations, security incidents

### 3. MINTER_ROLE
- **Capabilities:**
  - Mint new tokens to any address
- **Use Case:** Token distribution, rewards, initial supply

### 4. UPGRADER_ROLE
- **Capabilities:**
  - Upgrade the contract implementation
- **Use Case:** Bug fixes, feature additions, contract improvements

## Functions

### Public Functions

#### `initialize(address defaultAdmin, address pauser, address minter, address upgrader)`
Initializes the contract with initial role assignments.

**Parameters:**
- `defaultAdmin` - Address to receive DEFAULT_ADMIN_ROLE
- `pauser` - Address to receive PAUSER_ROLE
- `minter` - Address to receive MINTER_ROLE
- `upgrader` - Address to receive UPGRADER_ROLE

**Note:** Can only be called once during proxy deployment.

#### `decimals() → uint8`
Returns the number of decimals for the token (always returns `2`).

#### `pause()`
Pauses all token transfers. Only callable by `PAUSER_ROLE`.

#### `unpause()`
Resumes all token transfers. Only callable by `PAUSER_ROLE`.

#### `mint(address to, uint256 amount)`
Mints new tokens to the specified address. Only callable by `MINTER_ROLE`.

**Parameters:**
- `to` - Address to receive the minted tokens
- `amount` - Amount to mint (in token's smallest unit, e.g., `100` = 1.00 WGNX)

### Standard ERC20 Functions

The contract inherits all standard ERC20 functions:
- `transfer(address to, uint256 amount)`
- `transferFrom(address from, address to, uint256 amount)`
- `approve(address spender, uint256 amount)`
- `allowance(address owner, address spender)`
- `balanceOf(address account)`
- `totalSupply()`
- `name()`
- `symbol()`

### ERC20Burnable Functions

- `burn(uint256 amount)` - Burn tokens from caller's balance
- `burnFrom(address account, uint256 amount)` - Burn tokens from another account (with approval)

### ERC20Permit Functions

- `permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` - Gasless approvals

## Deployment

### Prerequisites

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables in `.env`:
```env
PRIVATE_KEY=your_private_key
BASESCAN_API_KEY=your_basescan_api_key
```

### Deploy to Base Sepolia

```bash
npx hardhat run scripts/deploy-wagon-asset-index.ts --network baseSepolia
```

### Deployment Script Output

The deployment script will output:
- Proxy address (the address users interact with)
- Implementation address (the actual contract code)
- Admin address (proxy admin)
- Role assignments verification

### Example Deployment Output

```
🚀 Deploying WagonAssetIndex to Base Sepolia...
Deploying contracts with the account: 0x...
Account balance: 1000000000000000000
Deploying WagonAssetIndex...
✅ WagonAssetIndex deployed to: 0x5c239A3e62D61591f8797A372978BcbbB8d20B09
📋 Implementation address: 0xA098a31108737C2982bB7FfE29081f446af0056C
🔐 Admin address: 0x...
```

## Usage Examples

### Minting Tokens

```typescript
import { ethers } from "hardhat";

const WagonAssetIndex = await ethers.getContractFactory("WagonAssetIndex");
const token = WagonAssetIndex.attach("0x..."); // Proxy address

// Mint 1000.00 WGNX (100000 with 2 decimals)
await token.connect(minter).mint(userAddress, 100000);
```

### Transferring Tokens

```typescript
// Transfer 10.00 WGNX (1000 with 2 decimals)
await token.connect(user1).transfer(user2Address, 1000);
```

### Burning Tokens

```typescript
// Burn 5.00 WGNX (500 with 2 decimals) from caller's balance
await token.connect(user1).burn(500);
```

### Pausing/Unpausing

```typescript
// Pause all transfers (emergency only)
await token.connect(pauser).pause();

// Resume transfers
await token.connect(pauser).unpause();
```

### Checking Roles

```typescript
const PAUSER_ROLE = await token.PAUSER_ROLE();
const hasPauserRole = await token.hasRole(PAUSER_ROLE, address);
```

## Security Considerations

### Access Control
- **Role Separation:** Different roles are assigned to different addresses for better security
- **Admin Control:** DEFAULT_ADMIN_ROLE has full control - use a multisig wallet
- **Upgrader Role:** Separate from admin to limit upgrade authority

### Upgradeability
- **UUPS Pattern:** Uses UUPS proxy pattern for upgrades
- **Upgrade Authorization:** Only UPGRADER_ROLE can authorize upgrades
- **Storage Layout:** Future upgrades must maintain storage layout compatibility

### Pausability
- **Emergency Stop:** Contract can be paused to stop all transfers
- **Use Cases:** Security incidents, critical bugs, regulatory requirements
- **Limitation:** Pausing affects all transfers, including minting and burning

### Best Practices
1. **Multisig Wallets:** Use multisig wallets for admin, pauser, and upgrader roles
2. **Key Management:** Store private keys securely, use hardware wallets
3. **Testing:** Thoroughly test upgrades on testnets before mainnet
4. **Monitoring:** Monitor contract events and transactions
5. **Documentation:** Keep track of all role assignments and upgrades

## Testing

Run the test suite:

```bash
npx hardhat test test/WagonAssetIndex.test.ts
```

### Test Coverage

The test suite covers:
- ✅ Deployment and initialization
- ✅ Role assignments
- ✅ Token metadata (name, symbol, decimals)
- ✅ Minting functionality
- ✅ Transfer functionality
- ✅ Burning functionality
- ✅ Pause/unpause functionality
- ✅ Access control (role-based restrictions)

## Contract Verification

### Verify on Basescan

```bash
npx hardhat verify --network baseSepolia <PROXY_ADDRESS> <ADMIN> <PAUSER> <MINTER> <UPGRADER>
```

Or use the verification script:

```bash
npx hardhat run scripts/verify-wagon-asset-index.ts --network baseSepolia
```

## Network Information

### Base Sepolia (Testnet)
- **Network ID:** 84532
- **RPC URL:** https://sepolia.base.org
- **Explorer:** https://sepolia.basescan.org

## Architecture

### Proxy Pattern
The contract uses the UUPS (Universal Upgradeable Proxy Standard) pattern:

```
User → Proxy Contract → Implementation Contract
```

- **Proxy:** Stores state and delegates calls to implementation
- **Implementation:** Contains the actual contract logic
- **Upgrade:** New implementation can be deployed and proxy updated

### Storage Layout
The contract inherits storage from:
- `ERC20Upgradeable` - Token balances, allowances, total supply
- `AccessControlUpgradeable` - Roles and role members
- `PausableUpgradeable` - Pause state

## Upgrade Process

1. Deploy new implementation contract
2. Call `upgradeTo(address newImplementation)` on proxy (requires UPGRADER_ROLE)
3. Verify new implementation on block explorer
4. Test thoroughly on testnet before mainnet

## Support

For issues, questions, or contributions, please refer to the main project repository.

## License

MIT License - See LICENSE file for details.

