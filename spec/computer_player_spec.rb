# frozen_string_literal: true

require 'helpers'
require 'computer_player'
require 'computer_player_bidding'
require 'computer_player_tricks'
require 'trick'

RSpec.describe ComputerPlayer do
  let(:computer_player_bidding) { instance_double(ComputerPlayerBidding) }
  let(:computer_player_tricks) { instance_double(ComputerPlayerTricks) }
  let(:player) { ComputerPlayer.new(name: 'player', bidding: computer_player_bidding, tricks: computer_player_tricks)}

  before do
    allow(computer_player_bidding).to receive(:name=)
    allow(computer_player_tricks).to receive(:name=)
  end

  it 'creates a player with a name and an empty hand' do
    expect(player.name).to be_kind_of(String)
    expect(player.hand).to be_kind_of(Array)
    expect(player.hand.length).to eq 0
  end

  describe "#decide_bid" do
    it 'forwards #decide_bid to computer_player_bidding, centre card defaulting to nil, hand defaulting to players hand, dealer defaulting to nil' do
      expect(computer_player_bidding).to receive(:decide_bid).with(
        options: 'test options',
        hand: player.hand,
        card: nil,
        dealer: nil
      )
      player.decide_bid(options: 'test options')
    end

    it 'forwards #decide_bid to computer_player_bidding, including centre card, hand, dealer if supplied' do
      expect(computer_player_bidding).to receive(:decide_bid).with(
        options: 'test options',
        hand: 'test hand',
        card: 'test card',
        dealer: 'test dealer'
        )
      player.decide_bid(
        options: 'test options',
        hand: 'test hand',
        card: 'test card',
        dealer: 'test dealer'
      )
    end
  end

  describe '#exchange_card!' do
    it 'forwards #exchange_card! to computer_player_bidding defaulting to the current hand if none is supplied' do
      player.hand = 'test player hand'

      expect(computer_player_bidding).to receive(:exchange_card!).with(
        card: 'test card',
        trumps: 'test trumps',
        hand: 'test player hand'
      )
      player.exchange_card!(card: 'test card', trumps: 'test trumps')
    end

    it 'forwards #exchange_card! to computer_player_bidding with a supplied hand' do
      supplied_hand = 'test supplied hand'

      expect(computer_player_bidding).to receive(:exchange_card!).with(
        card: 'test card',
        trumps: 'test trumps',
        hand: supplied_hand
      )
      player.exchange_card!(card: 'test card', trumps: 'test trumps', hand: supplied_hand)
    end
  end

  describe '#play_card' do
    it 'forwards #play_card to computer_player_tricks defaulting to current hand if none is supplied' do
      player.hand = 'test player hand'

      expect(computer_player_tricks).to receive(:play_card).with(
        trumps: 'test trumps',
        tricks: 'test tricks',
        trick_index: 0,
        hand: player.hand
      )
      player.play_card(trumps: 'test trumps', tricks: 'test tricks', trick_index: 0)
    end
  end
end
