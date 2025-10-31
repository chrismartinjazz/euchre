# frozen_string_literal: true

# Game -> @players(HumanPlayer x 1, ComputerPlayer x 3), @deck(Deck), @score, @dealer, @centre_card, @reserve_card
# Setup the game:
#   Player positions are North, South, East, West - human player is South
#   Set score to 0-0
#   Initialize the deck
#   Set a player to be dealer
#   Start the game loop(dealer)

# Game loop(dealer):
#   Check for a winner: if either team has 6 or more points
#     announce the winners
#     exit the game loop
#   Clear the table
#     Reset all players hands to be empty
#
#   Shuffle the deck
#   Initialize the hand result to 0
#   Deal the cards
#     5 cards to each of 4 players
#     1 centre card (face up)
#     (Remaining cards are unused)
#   Bidding:
#     Set the bidding player to the player after the dealer
#     Each player starting with the bidding player can either:
#       Direct dealer to pick up card
#         Dealer picks up centre card and removes a card of his choice (including centre card) from his hand
#         Set trump suit based on centre card and bidding player
#         Bidder chooses and announces if "going alone": set go alone
#       Pass
#     If no suit has been set as trumps:
#       Set available suits to be all that are not bidding card suit
#       Each player in turn starting with the player after dealer can either:
#         Nominate a suit to be trumps
#           Set trump suit and bidding player
#           Bidder chooses and announces if "going alone": set go alone
#         Pass
#   If a trump suit has been set:
#     Play the hand (trumps, bidding player, go alone), update hand result
#     Increment score based on hand result
#   Next player after dealer becomes dealer

#   Play the hand (trump suit, bidding player, go alone):
#     Set the ranking of cards based on the trump suit
#     If the bidder is going alone:
#       Remove their partner from the hand
#     Start player is player after the dealer
#     Set bidding team hand score to 0
#     5 times:
#       Start player chooses and plays a card
#       Set of current suit cards determined based on that card's suit and the trump suit
#       Each other player in turn plays a card
#         Must play a card from current suit set if have one in hand
#       Result of hand evaluated based on ranking of cards
#       If the bidding team won the hand, increment their hand score by 1
#       Start player is set to winner of hand
#     Return result and winners based on the bidding team's hand score:
#       5 and "go alone":     4, bidders
#       5 and not "go alone": 2, bidders
#       3, 4:                 1, bidders
#       1, 2:                 2, defenders
#       0:                    4 defenders

RANKS = {
  '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, 'T': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14, '?': 15
}.freeze
SUITS = { C: '♣', D: '♦', H: '♥', S: '♠', J: 'J' }.freeze

# A playing card. Expects a suit in format "C/D/H/S/J" where J is Joker.
class Card
  def initialize(rank, suit)
    @rank = rank
    @suit = suit.to_sym
  end

  def to_s
    "#{@rank}#{SUITS[@suit]}"
  end
end

# A deck of cards.
class Deck
  attr_reader :cards

  def initialize(ranks: %w[2 3 4 5 6 7 8 9 T J Q K], suits: %w[C D H S], joker_count: 2)
    @ranks = ranks
    @suits = suits
    @joker_count = joker_count
    @joker_rank = '?'
    @joker_suit = 'J'
    @cards = create_cards
  end

  def shuffle
    @cards.shuffle!
  end

  private

  def create_cards
    cards = []
    @ranks.each do |rank|
      @suits.each do |suit|
        cards.push(Card.new(rank, suit))
      end
    end
    @joker_count.times do
      cards.push(Card.new(@joker_rank, @joker_suit))
    end
    cards
  end
end

deck = Deck.new(ranks: %w[9 T J Q K A], joker_count: 1)
deck.shuffle
puts deck.cards
