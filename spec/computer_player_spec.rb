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
      Card.new(JOKER_RANK, JOKER_SUIT),
      Card.new(BOWER_RANK, :C),
      Card.new(BOWER_RANK, :S),
      Card.new(:A, :C),
      Card.new(:A, :S)
    ]
    it 'orders up centre_card if it is a club' do
      centre_card = Card.new(:T, :C)
      i_am_dealer = false
      expect(player.bid_centre_card(centre_card, centre_card.suit, i_am_dealer)[0]).to eq 'pick up'
    end

    it 'does not order up centre_card if it is a diamond' do
      centre_card = Card.new(:T, :D)
      i_am_dealer = false
      expect(player.bid_centre_card(centre_card, centre_card.suit, i_am_dealer)[0]).to eq 'pass'
    end

    it 'goes alone when ordering up centre_card if it is a club' do
      centre_card = Card.new(:T, :C)
      i_am_dealer = false
      expect(player.bid_centre_card(centre_card, centre_card.suit, i_am_dealer)).to eq ['pick up', true]
    end

    it 'bids clubs' do
      expect(player.bid_trumps([:C, :D, :H])[0]).to eq :C
    end

    it 'goes alone with clubs' do
      expect(player.bid_trumps([:C, :D, :H])).to eq [:C, true]
    end

    it 'passes if offered the two red suits only' do
      expect(player.bid_trumps([:D, :H])).to eq ['pass', false]
    end

    it 'chooses the lowest card to exchange with the next highest trump' do
      discard = player.exchange_card(Card.new(:K, :C), :C)
      expect(discard).to have_attributes(rank: :A, suit: :S)
    end
  end

  context 'with a fair (should bid) diamonds hand' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(BOWER_RANK, :D),
      Card.new(:A, :D),
      Card.new(:K, :D),
      Card.new(:Q, :D),
      Card.new(:T, :S)
    ]
    it 'orders up centre_card if it is a diamond but does not go alone' do
      centre_card = Card.new(:'9', :D)
      i_am_dealer = false
      expect(player.bid_centre_card(centre_card, centre_card.suit, i_am_dealer)).to eq ['pick up', false]
    end

    it 'passes on centre_card if it is a heart' do
      centre_card = Card.new(:'9', :H)
      i_am_dealer = false
      expect(player.bid_centre_card(centre_card, centre_card.suit, i_am_dealer)).to eq ['pass', false]
    end

    it 'chooses diamonds as trumps and does not go alone' do
      expect(player.bid_trumps([:C, :D, :H])).to eq [:D, false]
    end
  end

  context 'when playing a trick' do
    player = ComputerPlayer.new
    player.hand = [
      Card.new(BOWER_RANK, :D),
      Card.new(:A, :D),
      Card.new(:K, :D),
      Card.new(:Q, :D),
      Card.new(:T, :S)
    ]
    trumps = :D
    tricks = Array.new(5) { Trick.new(trumps, 4) }
    it 'when leading, identifies that all cards are valid' do
      trick_index = 0
      expect(player.find_valid_hand_indices(trumps, tricks, trick_index)).to eq [0, 1, 2, 3, 4]
    end

    it 'chooses the highest held trump card to lead' do
      trick_index = 0
      expect(player.play_card(trumps, tricks, trick_index)).to have_attributes(rank: BOWER_RANK, suit: :D)
    end

    it 'follows suit if a spade is led' do
      trick_index = 0
      tricks[trick_index].add(player, Card.new(:A, :S))
      expect(player.play_card(trumps, tricks, trick_index)).to have_attributes(rank: :T, suit: :S)
    end
  end
end
