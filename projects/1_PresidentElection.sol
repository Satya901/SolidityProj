// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title President Election
 * @dev Implements President voting process along with vote delegation
 */
contract Ballot {
   
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    //struct Candidate {
    struct Candidate {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    mapping(address => Voter) public voters;

   // Proposal[] public proposals;
    Candidate[] public candidates;
    
    bytes32[3]  candidateNames = [bytes32("Droupadi Murmu"), bytes32("Yashwant Sinha"), bytes32("Kapil Sibbal")];

    //
    // * @dev Create a new ballot to choose one of 'candidateNames'.
    // * @param candidateNames names of candidate
    // */
    //constructor(bytes32[] memory candidateNames) {
    constructor( ) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < candidateNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }
    
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        // to check if "to address " which we are delegating our vote
        // has already delegated his/her vote to next address
        // if so we will directly delegate our vote to the final delegated address
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            candidates[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param candidate index of candidate in the candidates array
     */
    function vote(uint candidate) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = candidate;

        // If 'candidate' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        candidates[candidate].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning candidate taking all previous votes into account.
     * @return winningCandidate_ index of winning candidate in the candidates array
     */
    function winningCandidate() public view
            returns (uint winningCandidate_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winningCandidate_ = p;
            }
        }
    }

    /** 
     * @dev Calls winningCandidate() function to get the index of the winner contained in the candidates array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (string  memory winnerName_)
   //         returns (bytes32 winnerName_)
    {   bytes32  temp = candidates[winningCandidate()].name;
        winnerName_ =  string(abi.encodePacked(temp));

    }
}
