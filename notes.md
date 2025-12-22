# Notes

## Conventions and learnings for next time

- Use constants for things like card ranks and suits from the start.
- Use keyword arguments for the public interface of a class (always), positional arguments for private methods in a class.
- Immediately document expected child class methods in parent class using NotImplementedError

## Overall refactoring and adjustments needed

- [x] Change throughout to use keyword arguments for interfaces, make interfaces clearer
- [x] Adjust computer_player_spec.rb so there is option for no 'pause' from ComputerPlayer during its tests.
- [x] Change so left bower 'knows' if it is the left bower, similar to how it knows it is a diamond with a heart glyph if diamonds are trumps and it is the Jack of Hearts.
- [x] Fix bug where pressing enter on blank input crashes the game
- [x] Left bower displayed as 'j' in tricks table
- [x] Left bower displayed as 'j' in player hand (when playing a card, not when bidding)
- [x] Refactoring of Game and TrickManager to extract Display
- [x] Adjust display to refresh each time a trick is played, and for bidding to show cards held by other players (so they gradually decrease in number throughout the hand.) Rename so instead of "bidding" call it "player" display or something.
- [x] Change first display to make clearer who is the dealer (a symbol next to their name) and have their name next to their hand.
- [x] Extract BiddingManager from Game, overall refactoring of Game main method.
- [x] Fix bug where going alone means play only against own team mate! (Opposite of intended behaviour)
- [x] Adjust display initialization to make it clearer
- [x] Update ComputerPlayer AI and fine tune, add more card playing logic.
- [x] Refactor ComputerPlayer (and then HumanPlayer) so it is all at the same level of abstraction - add a ComputerPlayerTricks class
- [x] ComputerPlayer move THINKING_TIME out of tests.
- [x] Update all the tests to make them consistent in formatting, use of instance doubles
  - [x] trick_spec.rb
  - [x] computer_player_bidding_spec.rb
  - [x] human_player_bidding_spec.rb
  - [x] display_spec.rb
- [ ] Adjust Card to be an object factory rather than handling jokers and bowers internally

## Classes

### Game

- Runs the main game loop
  - updates display
  - manages the players and teams
  - deal cards
  - manage bid for trumps
- Holds onto HumanPlayer and ComputerPlayer, Deck, TrickManager
- Adjustments needed:
  - [x] Extract display related tasks into DisplayManager
  - [x] Make it so ComputerPlayers hands are shown with |## |## |## |## |## as their hand instead of the actual cards.
  - [x] Extract bidding into BiddingManager
  - [x] Refactor #start_game_loop to reduce method length

### Player

- Holds cards in its hands and knows its name

### HumanPlayer

- Inherits from Player class
- Responds to messages to bid, exchange a card, play a card, choose a suit
- Uses terminal to get input from player

### ComputerPlayer

- Inherits from Player class
- Responds to messages to bid, exchange a card, play a card, choose a suit
- Evaluates cards based on 0-5 numerical value for non-trumps, 6-13 for trumps (Joker is 13, 9 of non-trumps is 0)
- Evaluates hands based on average of card numerical value, considering trump suit
- Plays the strongest valid card in every trick context
- Adjustments needed:
  - [x] Add awareness of context influencing playing of cards and bidding
    - [x] If the strongest card in hand can't win the trick, play the weakest valid card instead
    - [x] If partner is already winning the trick with a strong card, play weakest card rather than strongest.
    - [x] When exchanging a card as dealer, prefer to 'short' a suit if holding a single card of one suit that is not an Ace.
    - [x] When bidding on centre card, consider the strength of the card in the prospective trump suit and adjust minimum hand score up if adding card to own team.
  - [x] Change the evaluation of a hand, so it is on more of an exponential scale. Put this into a constant so it can be experimented with.

### TrickManager

- Manages a set of 5 tricks and reports the result
- Knows the trump suit, if the dealer is going alone, the bidding team, the current order of players (based on who won the previous trick), the initial order of players (and displays in that order), the progress of tricks, and the trick score.
- Plays a hand, which is a series of five tricks.
- Displays tricks in a table, updated for each card played.
- Adjustments needed:
  - [x] Extract display related tasks into same DisplayManager held by Game
  - [x] Clarify private methods

### Trick

- Manages state and messages to do with an individual trick
- Knows the trump suit and how many players
- Keeps track of the lead suit and the plays as an array of objects, [{ player:, card:, rating: }, ...]
- Responds to messages to add a card, report the winner (nil if trick is not complete, or the player of the highest card), tell if the trick is complete, find the winning play (nil if no plays, otherwise the current lead play), and find the card played by a specific player.
- Evaluates cards with a simple ranking system (deliberately separate to ComputerPlayer evaluation of cards)

### Deck

- Generates card objects, shuffles and draws.
- Designed to be 'thrown out' and regenerated at the end of each hand.
- Can either deal (returning an array of cards) or draw one (returning a single card)

### Card

- Knows its rank and suit
- Reports its suit either exactly as stored (if no trumps argument supplied) or considering trump suit and Euchre rules
- Includes a two digit string representation of glyph and rank.
- [x] Add handling of blank cards (for face down cards)

## Game Planning

### [x] Game Setup

- Player positions are North, South, East, West - human player is South
- Set score to 0-0
- Initialize the deck
- Set a player to be dealer
- Start the game loop(dealer)

### [x] Game Loop

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
Bidder chooses and announces if "going alone": set go alone
Pass
If no suit has been set as trumps:
Set available suits to be all that are not bidding card suit
Each player in turn starting with the player after dealer can either:
Nominate a suit to be trumps
Set trump suit and bidding player
Bidder chooses and announces if "going alone": set go alone
Pass
If a trump suit has been set:
If the bidder is going alone:
Remove their partner from the hand
Play the hand (trumps, bidding player, go alone), update hand result
Increment score based on hand result
Next player after dealer becomes dealer

Play the hand (trump suit, bidding player, go alone):
Initialize the hand result to 0
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
5 and "go alone": 4, bidders
5 and not "go alone": 2, bidders
3, 4: 1, bidders
0, 1, 2: 2, defenders

Game loop(dealer):
Check for an overall winner: if either team has 11 or more points
announce the winners
exit the game loop
Clear the table
Reset all players hands to be empty