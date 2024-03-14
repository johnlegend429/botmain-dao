// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract BotmainGovernor is
    Governor,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(
        IVotes _token,
        TimelockController _timelock
    )
        Governor("BotmainGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(10) //10% quorum
        GovernorTimelockControl(_timelock)
    {}

    function votingDelay() public view override returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public view override returns (uint256) {
        return 45818; // ~1 week
    }

    function quorum(
        uint256 blockNumber
    ) public view override returns (uint256) {
        return
            (quorumNumerator() * totalSupply(blockNumber)) /
            quorumDenominator();
    }

    function proposalThreshold() public view override returns (uint256) {
        return 10000e18; // 10,000 tokens
    }

    // Override the state function to include custom logic or just use the default
    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return GovernorTimelockControl.state(proposalId);
    }

    // Custom `propose` function integrating with Tally's requirements
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    // Custom `execute` function integrating with Tally's requirements
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        public
        payable
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super.execute(targets, values, calldatas, descriptionHash);
    }

    // The following voting functions simply use the inherited behavior but are required for Tally compatibility
    function castVote(
        uint256 proposalId,
        uint8 support
    ) public override returns (uint256) {
        return super.castVote(proposalId, support);
    }

    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public override returns (uint256) {
        return super.castVoteWithReason(proposalId, support, reason);
    }

    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override returns (uint256) {
        return super.castVoteBySig(proposalId, support, v, r, s);
    }

    // Optional: Override quorumNumerator and quorumDenominator if your quorum is a function of token supply
    function quorumNumerator() public view override returns (uint256) {
        return 25; // Example quorum numerator
    }

    function quorumDenominator() public pure returns (uint256) {
        return 1000; // Example quorum denominator
    }
}
