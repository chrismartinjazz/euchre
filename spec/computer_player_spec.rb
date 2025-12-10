# frozen_string_literal: true

require 'constants'
require 'computer_player'
require 'card'
require 'trick'

RSpec.describe ComputerPlayer do
  it 'chooses a random suit' do
    player = ComputerPlayer.new
    chosen_suit = player.choose_a_suit
    expect([:C, :D, :H, :S].include?(chosen_suit)).to eq true
  end

  context 'with a near perfect clubs hand' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: JOKER_RANK, suit: JOKER_SUIT),
      Card.new(rank: BOWER_RANK, suit: :C),
      Card.new(rank: BOWER_RANK, suit: :S),
      Card.new(rank: :A, suit: :C),
      Card.new(rank: :A, suit: :S)
    ]
    it 'orders up centre_card if it is a club' do
      card = Card.new(rank: :T, suit: :C)
      response = player.bid_centre_card(card: card, suit: card.suit, dealer: false)
      expect(response[:bid]).to eq card.suit
    end

    it 'does not order up centre_card if it is a diamond' do
      card = Card.new(rank: :T, suit: :D)
      response = player.bid_centre_card(card: card, suit: card.suit, dealer: false)
      expect(response[:bid]).to eq :pass
    end

    it 'goes alone when ordering up centre_card if it is a club' do
      card = Card.new(rank: :T, suit: :C)
      response = player.bid_centre_card(card: card, suit: card.suit, dealer: false)
      expect(response[:bid]).to eq card.suit
      expect(response[:going_alone]).to eq true
    end

    it 'bids clubs and goes alone' do
      response = player.bid_trumps(options: [:C, :D, :H])
      expect(response[:bid]).to eq :C
      expect(response[:going_alone]).to eq true
    end

    it 'passes if offered the two red suits only' do
      response = player.bid_trumps(options: [:D, :H])
      expect(response[:bid]).to eq :pass
      expect(response[:going_alone]).to eq false
    end

    it 'chooses the lowest card to exchange with the next highest trump' do
      discard = player.exchange_card(card: Card.new(rank: :K, suit: :C), trumps: :C)
      expect(discard).to have_attributes(rank: :A, suit: :S)
    end
  end

  context 'with a fair (should bid) diamonds hand' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: BOWER_RANK, suit: :D),
      Card.new(rank: :A, suit: :D),
      Card.new(rank: :K, suit: :D),
      Card.new(rank: :Q, suit: :D),
      Card.new(rank: :T, suit: :S)
    ]
    it 'orders up centre_card if it is a diamond but does not go alone' do
      card = Card.new(rank: :'9', suit: :D)
      response = player.bid_centre_card(card: card, suit: card.suit, dealer: false)
      expect(response[:bid]).to eq card.suit
      expect(response[:going_alone]).to eq false
    end

    it 'passes on centre_card if it is a heart' do
      card = Card.new(rank: :'9', suit: :H)
      response = player.bid_centre_card(card: card, suit: card.suit, dealer: false)
      expect(response[:bid]).to eq :pass
    end

    it 'chooses diamonds as trumps and does not go alone' do
      response = player.bid_trumps(options: [:C, :D, :H])
      expect(response[:bid]).to eq :D
      expect(response[:going_alone]).to eq false
    end
  end

  context 'when playing a trick' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(rank: BOWER_RANK, suit: :D),
      Card.new(rank: :A, suit: :D),
      Card.new(rank: :K, suit: :D),
      Card.new(rank: :Q, suit: :D),
      Card.new(rank: :T, suit: :S)
    ]
    trumps = :D
    tricks = Array.new(5) { Trick.new(trumps: trumps) }

    it 'chooses the highest held trump card to lead' do
      expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: BOWER_RANK, suit: :D)
    end

    it 'follows suit if a spade is led' do
      tricks[0].add(player: player, card: Card.new(rank: :A, suit: :S))
      expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :T, suit: :S)
    end
  end
end
