# Notes

## Classes

Game -> @players(HumanPlayer x 1, ComputerPlayer x 3), @deck(Deck), @score, @dealer, @centre_card

## Game

### Game Setup

- Player positions are North, South, East, West - human player is South
- Set score to 0-0
- Initialize the deck
- Set a player to be dealer
- Start the game loop(dealer)

### Game Loop

Game loop(dealer):
  Check for a winner: if either team has 6 or more points
    announce the winners
    exit the game loop
  Clear the table
    Reset all players hands to be empty

  Deal the cards
    Shuffle the deck
    5 cards to each of 4 players
    1 centre card (face up)
    (Remaining cards are unused)
  Bidding:
    Set the bidding player to the player after the dealer
    Each player starting with the bidding player can either:
      Direct dealer to pick up card
        Dealer picks up centre card and removes a card of his choice (including centre card) from his hand
        Set trump suit based on centre card and bidding player
        TODO: Bidder chooses and announces if "going alone": set go alone
      Pass
    If no suit has been set as trumps:
      Set available suits to be all that are not bidding card suit
      Each player in turn starting with the player after dealer can either:
        Nominate a suit to be trumps
          Set trump suit and bidding player
          TODO: Bidder chooses and announces if "going alone": set go alone
        Pass
  If a trump suit has been set:
    Play the hand (trumps, bidding player, go alone), update hand result
    Increment score based on hand result
  Next player after dealer becomes dealer

  Play the hand (trump suit, bidding player, go alone):
    Initialize the hand result to 0
    TODO: If the bidder is going alone:
      TODO: Remove their partner from the hand
    Start player is player after the dealer
    Set bidding team hand score to 0
    5 times:
      Start player chooses and plays a card
      Set the ranking of cards based on the trump suit and the lead suit
      Set of current suit cards determined based on that card's suit and the trump suit
      Each other player in turn plays a card
        Must play a card from current suit set if have one in hand, otherwise can play any card
      Result of hand evaluated based on ranking of cards
      If the bidding team won the hand, increment their hand score by 1
      Start player is set to winner of hand
    Return result and winners based on the bidding team's hand score:
      5 and "go alone":     4, bidders
      5 and not "go alone": 2, bidders
      3, 4:                 1, bidders
      1, 2:                 2, defenders
      0:                    4 defenders