// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin/access/Ownable.sol";
import "lib/openzeppelin/token/ERC20/IERC20.sol";
import "./RewardNFT.sol";

contract DAO is Ownable {
    IERC20 public governanceToken;
    RewardNFT public rewardNFT;
    uint256 public proposalCounter;
    uint256 public totalPool;

    struct Proposal {
        uint256 id;
        string description;
        uint256 amount;
        address payable recipient;
        uint256 voteCount;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public votes;

    event NewProposal(uint256 id, string description, uint256 amount, address recipient);
    event Voted(uint256 proposalId, address voter, uint256 votes);
    event Executed(uint256 proposalId, address recipient, uint256 amount);
    event Contribution(address contributor, uint256 amount);

    constructor(IERC20 _governanceToken, RewardNFT _rewardNFT) {
        governanceToken = _governanceToken;
        rewardNFT = _rewardNFT;
        proposalCounter = 0;
        totalPool = 0;
    }

    function createProposal(string memory _description, uint256 _amount, address payable _recipient) external {
        proposals[proposalCounter] = Proposal(proposalCounter, _description, _amount, _recipient, 0, false);
        emit NewProposal(proposalCounter, _description, _amount, _recipient);
        proposalCounter++;
    }

    function vote(uint256 _proposalId, uint256 _votes) external {
        require(proposals[_proposalId].amount > 0, "Invalid proposal");
        require(governanceToken.balanceOf(msg.sender) >= _votes, "Insufficient tokens");
        require(!proposals[_proposalId].executed, "Proposal already executed");

        governanceToken.transferFrom(msg.sender, address(this), _votes);
        proposals[_proposalId].voteCount += _votes;
        votes[msg.sender] += _votes;
        emit Voted(_proposalId, msg.sender, _votes);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.voteCount > 0, "No votes for proposal");
        require(!proposal.executed, "Proposal already executed");
        require(address(this).balance >= proposal.amount, "Insufficient balance");

        proposal.executed = true;
        totalPool -= proposal.amount;
        proposal.recipient.transfer(proposal.amount);
        emit Executed(_proposalId, proposal.recipient, proposal.amount);
    }

    function contribute() external payable {
        require(msg.value > 0, "Contribution must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalPool += msg.value;
        rewardNFT.mintReward(msg.sender, "Contribution Reward");
        emit Contribution(msg.sender, msg.value);
    }

    function claimRewards() external {
        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions to claim");

        uint256 reward = contribution; // Simple 1:1 reward for contribution
        contributions[msg.sender] = 0;
        totalPool -= contribution;

        // Convert contribution to USDC and transfer (mock logic here)
        // usdcToken.transfer(msg.sender, reward);

        // For simplicity, send ETH instead of USDC in this example
        payable(msg.sender).transfer(reward);
    }
}
