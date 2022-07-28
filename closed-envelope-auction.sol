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

    mapping(address => bytes32) public hashedBids;

    // NOTE - this enum is for demonstration purposes.
    enum AuctionPhase{ COMMITMENT, REVEAL, ENDED, CLAIMED}

    AuctionPhase public phase = AuctionPhase.COMMITMENT;

    /*
     * Start auction and save data
     * NOTE - in an actual implementation we would want to pass in the desired time for commit and reveal phase
     * and set the times accordingly. In the other functions, auction phase would be checked by comparing now to
     * these times. 
     */
    function startAuction(uint256 reserve, uint256 deposit) public
    {
        phase = AuctionPhase.COMMITMENT;

        reservePrice = reserve;
        depositPrice = deposit;
        
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
     * and set auction phase to ended
     */
    function claim() public payable
    {
        require(phase == AuctionPhase.ENDED);

        require(msg.sender == highestBidder);
        require(msg.value == highestBid - depositPrice);
        auctionOwner.transfer(highestBid);
        phase = AuctionPhase.CLAIMED;
    }

    /*
     * Called by unsuccessful participants to recover their deposit
     */
    function recoverDeposit() public
    {
        require(phase == AuctionPhase.ENDED || phase == AuctionPhase.CLAIMED);

        require(hashedBids[msg.sender] != 0);
        require(msg.sender != highestBidder);
        payable(msg.sender).transfer(depositPrice);
        hashedBids[msg.sender] = 0x0;
    }

    // For demonstration purposes only, should be removed for an actual auction
    function startRevealPhase() public
    {
        phase = AuctionPhase.REVEAL;
    }

    // For demonstration purposes only, should be removed for an actual auction
    function endAuction() public
    {
        phase = AuctionPhase.ENDED;
    }
}
