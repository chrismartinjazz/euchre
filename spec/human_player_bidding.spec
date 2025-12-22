# frozen_string_literal: true

require 'constants'
require 'card'
require 'human_player_bidding'
require 'helpers'

RSpec.describe HumanPlayerBidding do
  let(:human_player_bidding) { HumanPlayerBidding.new }
  context 'with a strong clubs hand (9C, TC, QC, KC, JS) and a Jack of Clubs as centre card' do
    let(:hand) { [
      Card.new(rank: NINE, suit: CLUBS),
      Card.new(rank: TEN, suit: CLUBS),
      Card.new(rank: QUEEN, suit: CLUBS),
      Card.new(rank: KING, suit: CLUBS),
      Card.new(rank: JACK, suit: SPADES)
    ] }
    let(:centre_card) { Card.new(rank: JACK, suit: CLUBS) }

    let(:nine_of_diamonds) { Card.new(rank: NINE, suit: DIAMONDS) }

    it 'successfully exchanges a card' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('1')
        discarded_card = human_player_bidding.exchange_card!(hand: hand, card: centre_card, trumps: CLUBS)

        expect(discarded_card).to have_attributes(rank: NINE, suit: CLUBS)
        expect(hand.last).to have_attributes(rank: JACK, suit: CLUBS)
        expect(hand.length).to eq 5
      end
    end

    it 'successfully chooses a suit, re-prompting if given invalid input' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('1', 'C')
        suit = human_player_bidding.choose_suit

        expect(suit).to eq CLUBS
      end
    end

    it 'can pass on the centre card' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('2')
        bid = human_player_bidding.decide_bid(options: [DIAMONDS], card: nine_of_diamonds)

        expect(bid[:bid]).to eq :pass
        expect(bid[:going_alone]).to eq false
      end
    end

    it 'can order up the centre card, not going alone' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('1', 'N')
        bid = human_player_bidding.decide_bid(options: [DIAMONDS], card: nine_of_diamonds)

        expect(bid[:bid]).to eq DIAMONDS
        expect(bid[:going_alone]).to eq false
      end
    end

    it 'can order up the centre card, and go alone' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('1', 'Y')
        bid = human_player_bidding.decide_bid(options: [DIAMONDS], card: nine_of_diamonds)

        expect(bid[:bid]).to eq DIAMONDS
        expect(bid[:going_alone]).to eq true
      end
    end

    it 'can pass in the second human_player_bidding round' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('P')
        bid = human_player_bidding.decide_bid(options: [CLUBS, HEARTS, SPADES])

        expect(bid[:bid]).to eq :pass
        expect(bid[:going_alone]).to eq false
      end
    end

    it 'can bid clubs and not go alone' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('C', 'N')
        bid = human_player_bidding.decide_bid(options: [CLUBS, HEARTS, SPADES])

        expect(bid[:bid]).to eq CLUBS
        expect(bid[:going_alone]).to eq false
      end
    end

    it 'can bid clubs and go alone' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('C', 'Y')
        bid = human_player_bidding.decide_bid(options: [CLUBS, HEARTS, SPADES])

        expect(bid[:bid]).to eq CLUBS
        expect(bid[:going_alone]).to eq true
      end
    end

    it 'takes the capitalized first letter of input only as the response and strips whitespace' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return('can I choose diamonds instead?', '    yep') # "C", "Y"
        bid = human_player_bidding.decide_bid(options: [CLUBS, HEARTS, SPADES])

        expect(bid[:bid]).to eq CLUBS
        expect(bid[:going_alone]).to eq true
      end
    end

    it 're-prompts given invalid input' do
      silence do
        allow(human_player_bidding).to receive(:gets).and_return(
          'D', # C, H, S only
          'Diamonds', # C, H, S only
          '%#$?!', # C, H, S only
          '', # C, H, S only
          '?', # C, H, S only
          'Y', # C, H, S only
          'Exit', # C, H, S only
          'clubs', # accepts "C" as valid input for suit options
          'clubs', # Y, N only
          'help', # Y, N only
          'yes' # accepts "Y" as valid input for going alone
        )
        bid = human_player_bidding.decide_bid(options: [CLUBS, HEARTS, SPADES])

        expect(bid[:bid]).to eq CLUBS
        expect(bid[:going_alone]).to eq true
      end
    end
  end
end
