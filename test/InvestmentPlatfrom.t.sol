// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol";
import "../src/RewardNFT.sol";
import "../src/DAO.sol";

contract InvestmentPlatformTest is Test {
    GovernanceToken public governanceToken;
    RewardNFT public rewardNFT;
    DAO public dao;
    address public owner;
    
    function setUp() public {
        owner = address(this);
        governanceToken = new GovernanceToken();
        rewardNFT = new RewardNFT();
        dao = new DAO(IERC20(governanceToken), rewardNFT);

        // Transfer ownership of RewardNFT to DAO
        rewardNFT.transferOwnership(address(dao));
    }

    function testCreateProposal() public {
        dao.createProposal("Test Proposal", 100 ether, payable(address(1)));
        (uint256 id, string memory description, uint256 amount, address recipient, uint256 voteCount, bool executed) = dao.proposals(0);
        assertEq(id, 0);
        assertEq(description, "Test Proposal");
        assertEq(amount, 100 ether);
        assertEq(recipient, address(1));
        assertEq(voteCount, 0);
        assertFalse(executed);
    }

    function testVote() public {
        governanceToken.approve(address(dao), 100);
        governanceToken.transfer(address(this), 100);
        dao.createProposal("Test Proposal", 100 ether, payable(address(1)));
        dao.vote(0, 100);
        (,, uint256 amount, address recipient, uint256 voteCount, bool executed) = dao.proposals(0);
        assertEq(voteCount, 100);
    }

    function testContributeAndClaim() public {
        // Contribute to the DAO
        vm.deal(address(this), 1 ether);
        dao.contribute{value: 1 ether}();
        uint256 contribution = dao.contributions(address(this));
        assertEq(contribution, 1 ether);

        // Mint a reward NFT
        uint256 tokenId = rewardNFT.mintReward(address(this), "Contribution Reward");

        // Claim rewards by burning the NFT
        dao.claimRewards(tokenId);
        contribution = dao.contributions(address(this));
        assertEq(contribution, 0);
    }
}
