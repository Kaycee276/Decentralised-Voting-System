// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract DecentralizedVoting {
    struct Voter {
        bool hasVoted;      // Whether the voter has cast their vote
        bytes32 voteHash;   // Hash of the proposal voted for
    }

    struct Proposal {
        string name;        // Name of the proposal
        uint256 voteCount;  // Number of votes received
    }

    Proposal[] public proposals;                // List of proposals
    mapping(address => Voter) public voters;    // Mapping of voter addresses to their voting status
    address public chairperson;                  // Address of the person who deployed the contract

    event Voted(address indexed voter, bytes32 voteHash); // Event for logging votes

    // Initialize the contract with proposals and set the chairperson
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender; // Set the chairperson to the deployer's address
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Cast a vote for a proposal by hashing it
    function vote(uint256 proposalIndex) external {
        require(msg.sender != chairperson, "Chairperson cannot vote."); // Prevent chairperson from voting
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        require(proposalIndex < proposals.length, "Invalid proposal index.");

        // Generate a unique hash for the vote
        bytes32 voteHash = keccak256(abi.encodePacked(msg.sender, proposalIndex, block.timestamp));
        voters[msg.sender].voteHash = voteHash; // Store the hash
        voters[msg.sender].hasVoted = true; // Mark the voter as having voted
        proposals[proposalIndex].voteCount++; // Increment the vote count for the selected proposal

        emit Voted(msg.sender, voteHash); // Emit event for logging
    }

    // Get the winning proposal based on the votes received
    function winningProposal() public view returns (uint256 winningProposalIndex) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i; // Update winning proposal index
            }
        }
    }

    // Get the name of the winning proposal
    function winnerName() external view returns (string memory) {
        return proposals[winningProposal()].name; // Retrieve the winning proposal name
    }
}
