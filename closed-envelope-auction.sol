pragma solidity ^0.4.23;

contract ClosedEnvelopeAuction
{
    address auctionRunner = 0;
    address highestBidder = 0;
    uint256 highestBid = 0;
    uint256 reservePrice = 0;
    uint256 commitmentPhaseLength = 0;
    uint256 revealPhaseLength = 0;

    enum AuctionPhase{ COMMITMENT, REVEAL }
    AuctionPhase phase = AuctionPhase.COMMITMENT;

    function startAuction(uint256 reserve, uint256 commitment, uint256 reveal) public
    {
        reservePrice = reserve;
        commitmentPhaseLength = commitment;
        revealPhaseLength = reveal;
        // save the user who runs the auction, they can toggle the phases
        // set phase to bidding phase - maybe use enum?
        // call method that prints out announcement of auction?

    }

    function Bid(uint256 hash) public
    {
        /*
         * This function represents the COMMITMENT PHASE
         *      int hash - hash of bid amount, nounce
         * the bidder picks their own nounce
         * We can access who called this with msg.sender
         */

         // check that auction phase is COMMITMENT
         // save the user and their hash

    }

    function reveal(uint256 amount, uint256 nounce) public
    {
        /*
         * this function represents the REVEAL PHASE
         *      uint256 amount - the amount bid
         *      uint256 nounce - the nounce chosen by the user
         * The bidder reveals both the bid and the nounce.
         * The user calling the function is identified
         * The hash of both is checked, if it does not match the hash it is ignored.
         * If it does match, the amount is compared to other amounts
         */

         // check that auction phase is REVEAL
         // check that the given user's amount matches the hash
         // if their amount is highest, then update hightestBid and highestBidder
    }

    function endAuction() public
    {
        /*
         * called by the auction runner after the reveal phase is over 
         * validates that the caller is the owner of the auction
         * validates the auction is over
         * prints out an announcement of winner
         * if reserve price is not met, announce no winner
         * should this be called automatically?
         */
    }

    function claim() public
    {
        /*
         * check that winner is calling it, and prompt them to send etherium
         * 
         */
    }

    // in our paying, add functionallity to go to next highest bidder
    // if nobody is above reserve, cancel auction

    function announceAuctionStart() public
    {
        // print info about auction start
    }


}