// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NoncesUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol";
import {ERC20VotesUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20BurnableUpgradeable} "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {AccessControlUpgradeable} "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract BotmainToken is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable
{
    // Create new role identifiers for the role we want
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    bool public burningEnabled;

    modifier canBurn() {
        require(burningEnabled == true, "cannot burn tokens; burning disabled");
        _;
    }

    function initialize(address gnosisSafe) public initializer {
        __ERC20_init_unchained("Botmain", "BOT");
        __ERC20Permit_init_unchained("Botmain");
        __ERC20Burnable_init_unchained();
        __ERC20Pausable_init_unchained();
        __ERC20Votes_init_unchained();
        __AccessControl_init_unchained();

        // Grant the contract deployer the default admin role:
        // it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Grant other, non-admin roles to contract deployer as well
        _setupRole(SNAPSHOT_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);

        // Mint 20% of supply to contract deployer for team distribution
        _mint(msg.sender, 2000000 * 10 ** decimals());

        // Mint 80% of supply to contract gnsosis safe for crowdsale
        _mint(gnosisSafe, 8000000 * 10 ** decimals());

        burningEnabled = false;
    }

    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function enableBurn() public onlyRole(BURNER_ROLE) {
        burningEnabled = true;
    }

    function disableBurn() public onlyRole(BURNER_ROLE) {
        burningEnabled = false;
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable) canBurn {
        super._burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(
            ERC20Upgradeable,
            ERC20SnapshotUpgradeable,
            ERC20PausableUpgradeable
        )
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
