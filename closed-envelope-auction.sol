pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";

contract ClosedEnvelopeAuction
{
    address public auctionRunner = address(0);
    address public highestBidder = address(0);
    uint256 public highestBid = 0;

    uint256 reservePrice = 0;
    uint256 depositPrice = 0;

    uint256 public commitmentStart;
    uint256 public revealStart;
    uint256 public auctionEnd;

    mapping(address => bytes32) public hashedBids;

    enum AuctionPhase{ COMMITMENT, REVEAL }
    AuctionPhase public phase = AuctionPhase.COMMITMENT;

    /*
     * Start auction and save data
     */
    function startAuction(uint256 reserve, uint256 deposit, uint256 commitmentPhaseLength, uint256 revealPhaseLength) public
    {
        // TODO - set phase

        reservePrice = reserve;
        depositPrice = deposit;

        commitmentStart = block.timestamp;
        revealStart = block.timestamp + commitmentPhaseLength;
        auctionEnd = revealStart + revealPhaseLength;
        
        auctionRunner = msg.sender;
    }

    /*
     * BY BIDDING, YOU ARE COMMITING TO CALLING REVEAL() DURING THE REVEAL PHASE.
     * OTHERWISE, YOUR DEPOSIT WILL NOT BE RETURNED.
     * This function called in the COMMITMENT PHASE. Called with value equal to deposit.
     *      int hash - sha256 hash of bid amount and nounce concatenated
     */
    function bid(bytes32 hash) public payable
    {
        // TODO - check that auction phase is COMMITMENT

        // ensure one bid per account
        require(hashedBids[msg.sender] == 0);

        // ensure deposit payed
        require(msg.value == depositPrice);

        //require(phase == AuctionPhase.COMMITMENT);

        hashedBids[msg.sender] = hash;
    }


    /*
     * this function represents the REVEAL PHASE
     *      uint256 amount - the amount bid
     *      uint256 nounce - the nounce chosen by the user
     * The bidder reveals both the bid and the nounce.
     * The user calling the function is identified
     * The hash of both is checked, if it does not match the hash it is ignored.
     * If it does match, the amount is compared to other amounts
     */
    function reveal(uint256 amount, uint256 nounce) public
    {
        // TOOD - check that auction phase is REVEAL
        // TODO - establish nounce limit

        string memory bid = string.concat(Strings.toString(amount), Strings.toString(nounce));

        require(hashedBids[msg.sender] == sha256(bytes(bid)));

        if(amount > highestBid)
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
        require(msg.sender == highestBidder);
        require(msg.value == highestBid - depositPrice);
    }

    /*
     * Called by unsuccessful participants to recover their deposit
     */
    function recoverDeposit() public
    {
        // TODO - check the auction is over
        require(hashedBids[msg.sender] != 0);
        require(msg.sender != highestBidder);
        payable(msg.sender).transfer(depositPrice);
    }

}
