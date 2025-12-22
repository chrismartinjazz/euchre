# frozen_string_literal: true

require 'constants'
require 'human_player'
require 'human_player_bidding'
require 'human_player_tricks'
require 'deck'
require 'trick'
require 'card'
require 'helpers'

RSpec.describe HumanPlayer do
  let(:human_player_bidding) { instance_double(HumanPlayerBidding) }
  let(:human_player_tricks) { instance_double(HumanPlayerTricks) }
  let(:player) { HumanPlayer.new(name: 'player', bidding: human_player_bidding, tricks: human_player_tricks) }
  let(:centre_card) { 'test card' }
  let(:trumps) { 'test trumps' }

  before do
    allow(human_player_bidding).to receive(:name=)
    allow(human_player_tricks).to receive(:name=)
  end

  it 'creates a player with a name and an empty hand' do
    expect(player.name).to be_kind_of(String)
    expect(player.hand).to be_kind_of(Array)
    expect(player.hand.length).to eq 0
  end

  describe "#exchange_card!" do
    it 'forwards #exchange_card! to human_player_bidding defaulting to the current hand if none is supplied' do
      player.hand = ['test hand']

      expect(human_player_bidding).to receive(:exchange_card!).with(card: centre_card, trumps: trumps, hand: player.hand)
      player.exchange_card!(card: centre_card, trumps: trumps)
    end

    it 'forwards #exchange_card! to human_player_bidding with a supplied hand' do
      supplied_hand = ['test supplied hand']

      expect(human_player_bidding).to receive(:exchange_card!).with(card: centre_card, trumps: trumps, hand: supplied_hand)
      player.exchange_card!(card: centre_card, trumps: trumps, hand: supplied_hand)
    end
  end

  describe "#decide_bid" do
    let(:options) { 'test_options' }

    it 'forwards #decide_bid to human_player_bidding, with the centre card defaulting to nil if none is supplied' do
      expect(human_player_bidding).to receive(:decide_bid).with(options: options, card: nil)
      player.decide_bid(options: options)
    end

    it 'forwards #decide_bid to human_player_bidding, including a centre card if one is supplied' do
      expect(human_player_bidding).to receive(:decide_bid).with(options: options, card: centre_card)
      player.decide_bid(options: options, card: centre_card)
    end

    it 'ignores other keyword arguments and forwards only options: and card:' do
      expect(human_player_bidding).to receive(:decide_bid).with(options: options, card: centre_card)
      player.decide_bid(options: options, card: centre_card, other_kw_argument: nil)
    end
  end

  describe '#choose_a_suit' do
    it 'forwards the #choose_a_suit message to human_player_bidding' do
      expect(human_player_bidding).to receive(:choose_a_suit)
      player.choose_a_suit
    end
  end

  describe "#play_card" do
    it 'forwards #play_card to human_player_tricks, defaulting to current player hand if none supplied' do
      player.hand = 'test player hand'

      expect(human_player_tricks).to receive(:play_card).with(
        trumps: 'test trumps',
        tricks: 'test tricks',
        trick_index: 0,
        hand: player.hand
      )
      player.play_card(trumps: 'test trumps', tricks: 'test tricks', trick_index: 0)
    end
  end
end
