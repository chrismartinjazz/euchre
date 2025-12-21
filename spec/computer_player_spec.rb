# frozen_string_literal: true

require 'constants'
require 'helpers'
require 'computer_player'
require 'card'
require 'trick'

# TODO: This would be better as a parameter to the ComputerPlayer object on initialization
THINKING_TIME = 0

RSpec.describe ComputerPlayer do
  it 'chooses a random suit' do
    player = ComputerPlayer.new
    silence do
      chosen_suit = player.choose_a_suit
      expect([CLUBS, DIAMONDS, HEARTS, SPADES].include?(chosen_suit)).to eq true
    end
  end

  context 'with a near perfect clubs hand' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: JOKER, suit: JOKER_SUIT),
      Card.new(rank: JACK, suit: CLUBS),
      Card.new(rank: JACK, suit: SPADES),
      Card.new(rank: ACE, suit: CLUBS),
      Card.new(rank: ACE, suit: SPADES)
    ]
    it 'orders up centre_card if it is a club' do
      card = Card.new(rank: TEN, suit: CLUBS)
      silence do
        response = player.decide_bid(options: [CLUBS], card: card)
        expect(response[:bid]).to eq card.suit
      end
    end

    it 'does not order up centre_card if it is a diamond' do
      card = Card.new(rank: TEN, suit: DIAMONDS)
      silence do
        response = player.decide_bid(options: [DIAMONDS], card: card)
        expect(response[:bid]).to eq :pass
      end
    end

    it 'goes alone when ordering up centre_card if it is a club' do
      card = Card.new(rank: TEN, suit: CLUBS)
      silence do
        response = player.decide_bid(options: [CLUBS], card: card)
        expect(response[:bid]).to eq card.suit
        expect(response[:going_alone]).to eq true
      end
    end

    it 'bids clubs and goes alone' do
      silence do
        response = player.decide_bid(options: [CLUBS, DIAMONDS, HEARTS])
        expect(response[:bid]).to eq CLUBS
        expect(response[:going_alone]).to eq true
      end
    end

    it 'passes if offered the two red suits only' do
      silence do
        response = player.decide_bid(options: [DIAMONDS, HEARTS])
        expect(response[:bid]).to eq :pass
        expect(response[:going_alone]).to eq false
      end
    end

    it 'chooses the lowest card to exchange with the next highest trump' do
      # silence do
        discard = player.exchange_card!(card: Card.new(rank: KING, suit: CLUBS), trumps: CLUBS)
        expect(discard).to have_attributes(rank: ACE, suit: SPADES)
      # end
    end
  end

  context 'with a fair (should bid) diamonds hand' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: JACK, suit: DIAMONDS),
      Card.new(rank: ACE, suit: DIAMONDS),
      Card.new(rank: KING, suit: DIAMONDS),
      Card.new(rank: QUEEN, suit: DIAMONDS),
      Card.new(rank: TEN, suit: SPADES)
    ]
    it 'orders up centre_card if it is a diamond but does not go alone' do
      card = Card.new(rank: NINE, suit: DIAMONDS)
      silence do
        response = player.decide_bid(options: [DIAMONDS], card: card)
        expect(response[:bid]).to eq card.suit
        expect(response[:going_alone]).to eq false
      end
    end

    it 'passes on centre_card if it is a heart' do
      card = Card.new(rank: NINE, suit: HEARTS)
      silence do
        response = player.decide_bid(options: [HEARTS], card: card)
        expect(response[:bid]).to eq :pass
      end
    end

    it 'chooses diamonds as trumps and does not go alone' do
      silence do
        response = player.decide_bid(options: [CLUBS, DIAMONDS, HEARTS])
        expect(response[:bid]).to eq DIAMONDS
        expect(response[:going_alone]).to eq false
      end
    end
  end

  context 'when playing a trick' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: JACK, suit: DIAMONDS),
      Card.new(rank: ACE, suit: DIAMONDS),
      Card.new(rank: KING, suit: DIAMONDS),
      Card.new(rank: QUEEN, suit: DIAMONDS),
      Card.new(rank: TEN, suit: SPADES)
    ]
    trumps = DIAMONDS
    tricks = Array.new(5) { Trick.new(trumps: trumps) }

    it 'chooses the highest held trump card to lead' do
      silence do
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: JACK, suit: DIAMONDS)
      end
    end

    it 'follows suit if a spade is led' do
      tricks[0].add(player: player, card: Card.new(rank: ACE, suit: SPADES))
      silence do
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: TEN, suit: SPADES)
      end
    end

    it 'plays the weakest valid card, if it cannot win the trick' do
      tricks[1].add(player: player, card: Card.new(rank: JOKER, suit: JOKER_SUIT))
      silence do
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 1)).to have_attributes(rank: QUEEN, suit: DIAMONDS)
      end
    end
  end
end
