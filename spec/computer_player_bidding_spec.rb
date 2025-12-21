# frozen_string_literal: true

require 'computer_player_bidding'
require 'card'
require 'helpers'

THINKING_TIME = 0

RSpec.describe ComputerPlayerBidding do
  context "with a strong clubs hand" do
    ai = ComputerPlayerBidding.new
    hand = [
      Card.new(rank: JOKER, suit: JOKER_SUIT),
      Card.new(rank: JACK, suit: CLUBS),
      Card.new(rank: JACK, suit: SPADES),
      Card.new(rank: ACE, suit: CLUBS),
      Card.new(rank: ACE, suit: SPADES)
    ]
    it 'orders up centre_card if it is a club, regardless of who is the dealer' do
      ten_of_clubs = Card.new(rank: TEN, suit: CLUBS)
      silence do
        response_no_dealer = ai.decide_bid(hand: hand, options: [CLUBS], card: ten_of_clubs)
        response_self_dealer = ai.decide_bid(hand: hand, options: [CLUBS], card: ten_of_clubs, dealer: :self)
        response_partner_dealer = ai.decide_bid(hand: hand, options: [ten_of_clubs.suit], card: ten_of_clubs, dealer: :partner)
        expect(response_no_dealer[:bid]).to eq ten_of_clubs.suit
        expect(response_self_dealer[:bid]).to eq ten_of_clubs.suit
        expect(response_partner_dealer[:bid]).to eq ten_of_clubs.suit
      end
    end

    it 'does not order up centre_card if it is a diamond' do
      ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
      silence do
        response = ai.decide_bid(hand: hand, options: [ten_of_diamonds.suit], card: ten_of_diamonds)
        expect(response[:bid]).to eq :pass
      end
    end

    it 'goes alone when ordering up centre_card if it is a club' do
      ten_of_clubs = Card.new(rank: TEN, suit: CLUBS)
      silence do
        response = ai.decide_bid(hand: hand, options: [ten_of_clubs.suit], card: ten_of_clubs)
        expect(response[:bid]).to eq ten_of_clubs.suit
        expect(response[:going_alone]).to eq true
      end
    end

    it 'if the centre card (spades) is turned down, still bids clubs and goes alone' do
      silence do
        response = ai.decide_bid(hand: hand, options: [CLUBS, DIAMONDS, HEARTS])
        expect(response[:bid]).to eq CLUBS
        expect(response[:going_alone]).to eq true
      end
    end

    it 'passes if offered the two red suits only' do
      silence do
        response = ai.decide_bid(hand: hand, options: [DIAMONDS, HEARTS])
        expect(response[:bid]).to eq :pass
        expect(response[:going_alone]).to eq false
      end
    end
  end

  context 'with a borderline hearts hand (Jack DIAMONDS, Ten HEARTS, Ace SPACES, Jack CLUBS, Nine SPADES)' do
    ai = ComputerPlayerBidding.new
    hand = [
      Card.new(rank: JACK, suit: DIAMONDS),
      Card.new(rank: TEN, suit: HEARTS),
      Card.new(rank: ACE, suit: SPADES),
      Card.new(rank: JACK, suit: CLUBS),
      Card.new(rank: NINE, suit: SPADES)
    ]
    queen_of_hearts = Card.new(rank: QUEEN, suit: HEARTS)

    it 'does not order up hearts unless can pick up a heart centre card as dealer (this hand is only just good enough to bid)' do
      silence do
        response_self_dealer = ai.decide_bid(hand: hand.dup, options: [HEARTS], card: queen_of_hearts, dealer: :self)
        expect(response_self_dealer[:bid]).to eq HEARTS
        response_not_dealer = ai.decide_bid(hand: hand, options: [HEARTS], card: queen_of_hearts)
        expect(response_not_dealer[:bid]).to eq :pass
      end
    end

    it 'discards an off-trump single Jack CLUBS in preference to the overall lowest card' do
      silence do
        discard = ai.exchange_card!(hand: hand, card: queen_of_hearts, trumps: HEARTS)
        expect(discard.is_a?(Card)).to be true
        expect(discard.rank).to be JACK
      end
    end
  end

  context 'when choosing a card to discard' do
    ai = ComputerPlayerBidding.new
    hand = [
      Card.new(rank: JACK, suit: DIAMONDS),
      Card.new(rank: ACE, suit: HEARTS),
      Card.new(rank: KING, suit: SPADES),
      Card.new(rank: JACK, suit: CLUBS),
      Card.new(rank: NINE, suit: SPADES)
    ]
    ten_of_hearts = Card.new(rank: TEN, suit: HEARTS)
    ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
    it 'chooses the Jack of Clubs (off trump single) to discard if hearts are trumps' do
      silence do
        my_hand = hand.dup
        discard = ai.exchange_card!(hand: my_hand, card: ten_of_hearts, trumps: HEARTS)
        expect(discard.suit).to be CLUBS
      end
    end

    it 'chooses the Jack of Clubs (weakest off trump single) to discard if diamonds are trumps' do
      silence do
        my_hand = hand.dup
        discard = ai.exchange_card!(hand: my_hand, card: ten_of_diamonds, trumps: DIAMONDS)
        expect(discard.suit).to be CLUBS
      end
    end

    hand2 = [
      Card.new(rank: JOKER, suit: JOKER_SUIT),
      Card.new(rank: JACK, suit: SPADES),
      Card.new(rank: JACK, suit: CLUBS),
      Card.new(rank: KING, suit: HEARTS),
      Card.new(rank: TEN, suit: HEARTS)
    ]
    nine_of_clubs = Card.new(rank: NINE, suit: CLUBS)
    it 'chooses the worst card to discard where there are no off-trump singles, correctly handling left bower' do
      silence do
        my_hand = hand2.dup
        discard = ai.exchange_card!(hand: my_hand, card: nine_of_clubs, trumps: CLUBS)
        expect(discard.suit).to be HEARTS
        expect(discard.rank).to be TEN
      end
    end
  end
end

# Bidding
# Three trump cards and an off-suit Ace should be high enough to bid.
# Discarding - discard off-trump singles if can, even if mid-range.

# Hand play
# Lead a low trump if have a borderline trumps hand.
# Offensive vs defensive hands and play
# Offensive
#   Lots of trumps, bowers, more offensive
#   First position (leading first trick) more offensive
#   Trying to draw out high cards from opponents, lead highest cards
# Defensive
#   Strong off-suit cards
#   Try to hold onto Aces to steal tricks from opponents
#   Lead low cards, hold onto Aces
#   If in first position, lead the off-trump Ace where you have the fewest cards in that suit
