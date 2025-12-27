# frozen_string_literal: true

require 'computer_player_bidding'
require 'card'
require 'helpers'

RSpec.describe ComputerPlayerBidding do
  before do
    allow_any_instance_of(ComputerPlayerBidding).to receive(:think)
    allow_any_instance_of(ComputerPlayerBidding).to receive(:wait_for_user_to_press_enter)
  end

  let(:computer_player_bidding) { ComputerPlayerBidding.new }
  let(:ten_of_clubs) { Card.for(rank: TEN, suit: CLUBS) }
  let(:ten_of_diamonds) { Card.for(rank: TEN, suit: DIAMONDS) }
  let(:queen_of_hearts) { Card.for(rank: QUEEN, suit: HEARTS) }

  describe '#choose_a_suit' do
    it 'chooses a valid suit' do
      silence do
        result = computer_player_bidding.choose_a_suit
        expect([CLUBS, DIAMONDS, HEARTS, SPADES].include?(result)).to eq true
      end
    end
  end

  context "with a strong clubs hand" do
    let(:hand) { [
      Card.for(rank: JOKER, suit: JOKER_SUIT),
      Card.for(rank: JACK, suit: CLUBS),
      Card.for(rank: JACK, suit: SPADES),
      Card.for(rank: ACE, suit: CLUBS),
      Card.for(rank: ACE, suit: SPADES)
    ] }

    it 'orders up center_card if it is a club, regardless of who is the dealer' do
      silence do
        response_no_dealer = computer_player_bidding.decide_bid(
          hand: hand,
          options: [CLUBS],
          card: ten_of_clubs
        )
        expect(response_no_dealer[:bid]).to eq ten_of_clubs.suit

        response_self_dealer = computer_player_bidding.decide_bid(
          hand: hand,
          options: [CLUBS],
          card: ten_of_clubs,
          dealer: :self
        )
        expect(response_self_dealer[:bid]).to eq ten_of_clubs.suit

        response_partner_dealer = computer_player_bidding.decide_bid(
          hand: hand,
          options: [CLUBS],
          card: ten_of_clubs,
          dealer: :partner
        )
        expect(response_partner_dealer[:bid]).to eq ten_of_clubs.suit
      end
    end

    it 'does not order up center_card if it is a diamond' do
      silence do
        response = computer_player_bidding.decide_bid(
          hand: hand,
          options: [DIAMONDS],
          card: ten_of_diamonds
        )
        expect(response[:bid]).to eq :pass
      end
    end

    it 'goes alone when ordering up center_card if it is a club' do
      silence do
        response = computer_player_bidding.decide_bid(hand: hand, options: [CLUBS], card: ten_of_clubs)
        expect(response[:bid]).to eq CLUBS
        expect(response[:going_alone]).to eq true
      end
    end

    it 'if the center card (spades) is turned down, still bids clubs and goes alone' do
      silence do
        response = computer_player_bidding.decide_bid(hand: hand, options: [CLUBS, DIAMONDS, HEARTS])
        expect(response[:bid]).to eq CLUBS
        expect(response[:going_alone]).to eq true
      end
    end

    it 'passes if offered the two red suits only' do
      silence do
        response = computer_player_bidding.decide_bid(hand: hand, options: [DIAMONDS, HEARTS])
        expect(response[:bid]).to eq :pass
        expect(response[:going_alone]).to eq false
      end
    end
  end

  context 'with a borderline hearts hand (Jack DIAMONDS, Ten HEARTS, Ace SPACES, Jack CLUBS, Nine SPADES)' do
    let(:hand) { [
      Card.for(rank: JACK, suit: DIAMONDS),
      Card.for(rank: TEN, suit: HEARTS),
      Card.for(rank: ACE, suit: SPADES),
      Card.for(rank: JACK, suit: CLUBS),
      Card.for(rank: NINE, suit: SPADES)
    ] }

    it 'does not order up hearts unless can pick up a heart center card as dealer (this hand is only just good enough to bid)' do
      silence do
        response_self_dealer = computer_player_bidding.decide_bid(
          hand: hand.dup,
          options: [HEARTS],
          card: queen_of_hearts,
          dealer: :self
        )
        expect(response_self_dealer[:bid]).to eq HEARTS

        response_not_dealer = computer_player_bidding.decide_bid(
          hand: hand,
          options: [HEARTS],
          card: queen_of_hearts
        )
        expect(response_not_dealer[:bid]).to eq :pass
      end
    end

    it 'discards an off-trump single Jack CLUBS in preference to the overall lowest card' do
      silence do
        discard = computer_player_bidding.exchange_card!(hand: hand, card: queen_of_hearts, trumps: HEARTS)
        expect(discard.rank).to be JACK
        expect(discard.suit).to be CLUBS
      end
    end
  end

  context 'with a hand with no off-trump singles' do
    let(:hand) { [
      Card.for(rank: JOKER, suit: JOKER_SUIT),
      Card.for(rank: JACK, suit: SPADES),
      Card.for(rank: JACK, suit: CLUBS),
      Card.for(rank: KING, suit: HEARTS),
      Card.for(rank: TEN, suit: HEARTS)
    ] }
    it 'chooses the worst card to discard, correctly handling left bower' do
      silence do
        discard = computer_player_bidding.exchange_card!(hand: hand, card: ten_of_clubs, trumps: CLUBS)
        expect(discard.suit).to be HEARTS
        expect(discard.rank).to be TEN
      end
    end
  end
end
