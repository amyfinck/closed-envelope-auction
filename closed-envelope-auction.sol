pragma solidity ^0.8.12;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/utils/Strings.sol";

contract ClosedEnvelopeAuction
{
    address payable public auctionOwner = payable(address(0));
    address public highestBidder = address(0);
    uint256 public highestBid = 0;

    uint256 reservePrice = 0;
    uint256 depositPrice = 0;

    uint256 public commitmentStart;
    uint256 public revealStart;
    uint256 public auctionEnd;

    bool claimed;

    mapping(address => bytes32) public hashedBids;

    enum AuctionPhase{ COMMITMENT, REVEAL, ENDED, CLAIMED}
    AuctionPhase public phase = AuctionPhase.COMMITMENT;

    /*
     * Start auction and save data
     */
    function startAuction(uint256 reserve, uint256 deposit, uint256 commitmentPhaseLength, uint256 revealPhaseLength) public
    {
        phase = AuctionPhase.COMMITMENT;

        reservePrice = reserve;
        depositPrice = deposit;

        commitmentStart = block.timestamp;
        revealStart = block.timestamp + commitmentPhaseLength;
        auctionEnd = revealStart + revealPhaseLength;
        
        auctionOwner = payable(msg.sender);
        highestBidder = msg.sender;
    }

    /*
     * BY BIDDING, YOU ARE COMMITING TO CALLING Reveal() DURING THE REVEAL PHASE.
     * AND RecoverDeposit() IN THE ENDED PHASE, OTHERWISE YOUR DEPOSIT WILL NOT BE RECOVERED.
     * This function called in the COMMITMENT PHASE. Called with value equal to deposit.
     *      int hash - sha256 hash of bid amount and nonce concatenated
     */
    function bid(bytes32 hash) public payable
    {
        require(phase == AuctionPhase.COMMITMENT);

        // ensure one bid per account
        require(hashedBids[msg.sender] == 0);

        // ensure deposit payed
        require(msg.value == depositPrice);

        hashedBids[msg.sender] = hash;
    }

    /*
     * this function represents the REVEAL PHASE
     *      uint256 amount - the amount bid
     *      uint256 nonce - the nonce chosen by the user
     * The bidder reveals both the bid and the nonce.
     * The user calling the function is identified
     * The hash of both is checked, if it does not match the hash it is ignored.
     * If it does match, the amount is compared to other amounts
     */
    function reveal(uint256 amount, uint256 nonce) public
    {
        require(phase == AuctionPhase.REVEAL);
        // TODO - establish nonce limit

        string memory bidString = string.concat(Strings.toString(amount), Strings.toString(nonce));

        require(hashedBids[msg.sender] == sha256(bytes(bidString)));

        if(amount > highestBid && amount >= reservePrice)
        {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    /*
     * check that winner is calling it, and ensure they sent the balance, 
     * and set a flag to paid (TODO)
     */
    function claim() public payable
    {
        require(!claimed);
        require(phase == AuctionPhase.ENDED);

        require(msg.sender == highestBidder);
        require(msg.value == highestBid - depositPrice);
        auctionOwner.transfer(highestBid);
    }

    /*
     * Called by unsuccessful participants to recover their deposit
     */
    function recoverDeposit() public
    {
        require(phase == AuctionPhase.ENDED);

        require(hashedBids[msg.sender] != 0);
        require(msg.sender != highestBidder);
        payable(msg.sender).transfer(depositPrice);
    }

    function startRevealPhase() public
    {
        phase = AuctionPhase.REVEAL;
    }

    function endAuction() public
    {
        phase = AuctionPhase.ENDED;
    }
}
