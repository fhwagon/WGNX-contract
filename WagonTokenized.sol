// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract WagonTokenized is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // Blacklist mapping
    mapping(address => bool) private _blacklisted;
    
    // Events
    event AddressBlacklisted(address indexed account);
    event AddressRemovedFromBlacklist(address indexed account);
    event DestroyedBlackFunds(address indexed account, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address pauser, address minter, address upgrader, address blacklister)
        public
        initializer
    {
        __ERC20_init("Wagon Tokenized", "WAGT");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("Wagon Tokenized");

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
        _grantRole(BLACKLISTER_ROLE, blacklister);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // Blacklist functions
    function addToBlacklist(address account) public onlyRole(BLACKLISTER_ROLE) {
        require(account != address(0), 'zero address cannot be blacklisted');
        require(!_blacklisted[account], "Address is already blacklisted");
        _blacklisted[account] = true;
        emit AddressBlacklisted(account);
    }

    function removeFromBlacklist(address account) public onlyRole(BLACKLISTER_ROLE) {
        require(_blacklisted[account], "Address is not blacklisted");
        _blacklisted[account] = false;
        emit AddressRemovedFromBlacklist(account);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }

    function destroyBlackFunds(address account) public onlyRole(BLACKLISTER_ROLE) {
        require(_blacklisted[account], "Address is not blacklisted");
        uint256 balance = balanceOf(account);
        require(balance > 0, "Account has no tokens to destroy");
        
        // Use _burn which will call _update, but we override _update to allow burning
        _burn(account, balance);
        
        emit DestroyedBlackFunds(account, balance);
    }

    // UUPS Authorization
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        if (to == address(0)) {
            // No blacklist checks for burning
        } else {
            // Normal transfers - check sender
            require(!_blacklisted[from], "Sender is blacklisted");
        }
        
        super._update(from, to, value);
    }
}
