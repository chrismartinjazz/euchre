# frozen_string_literal: true

require 'constants'
require 'human_player'
require 'human_player_bidding'
require 'deck'
require 'trick'
require 'card'
require 'helpers'

RSpec.describe HumanPlayer do
  let(:bidding) { instance_double(HumanPlayerBidding) }
  let(:player) { HumanPlayer.new(name: 'player', bidding: bidding) }
  let(:centre_card) { 'test card' }
  let(:trumps) { 'test trumps' }

  before do
    allow(bidding).to receive(:name=)
  end

  it 'creates a player with a name and an empty hand' do
    expect(player.name).to be_kind_of(String)
    expect(player.hand).to be_kind_of(Array)
    expect(player.hand.length).to eq 0
  end

  describe "#exchange_card!" do
    it 'forwards #exchange_card! to bidding defaulting to the current hand if none is supplied' do
      player.hand = ['test hand']

      expect(bidding).to receive(:exchange_card!).with(card: centre_card, trumps: trumps, hand: player.hand)
      player.exchange_card!(card: centre_card, trumps: trumps)
    end

    it 'forwards #exchange_card! to bidding with a supplied hand' do
      supplied_hand = ['test supplied hand']

      expect(bidding).to receive(:exchange_card!).with(card: centre_card, trumps: trumps, hand: supplied_hand)
      player.exchange_card!(card: centre_card, trumps: trumps, hand: supplied_hand)
    end
  end

  describe "#decide_bid" do
    let(:options) { 'test_options' }

    it 'forwards #decide_bid to bidding, with the centre card defaulting to nil if none is supplied' do
      expect(bidding).to receive(:decide_bid).with(options: options, card: nil)
      player.decide_bid(options: options)
    end

    it 'forwards #decide_bid to bidding, including a centre card if one is supplied' do
      expect(bidding).to receive(:decide_bid).with(options: options, card: centre_card)
      player.decide_bid(options: options, card: centre_card)
    end

    it 'ignores other keyword arguments and forwards only options: and card:' do
      expect(bidding).to receive(:decide_bid).with(options: options, card: centre_card)
      player.decide_bid(options: options, card: centre_card, other_kw_argument: nil)
    end
  end

  context 'when playing a trick' do
    before do
      deck = Deck.new(ranks: [NINE, TEN], suits: [CLUBS, DIAMONDS, HEARTS, SPADES], joker_count: 0)
      player.hand = deck.deal(count: 5)
      # Player is holding 9C 9D 9H 9S TC
    end

    let(:trumps) { CLUBS }
    let(:tricks) { Array.new(5) { Trick.new(trumps: trumps) } }

    it 'can choose the first card in hand to lead, when no other card has been played' do
      silence do
        allow(player).to receive(:gets).and_return('1')
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: NINE, suit: CLUBS)
      end
    end

    it 're-prompts on a card that does not follow suit' do
      tricks[0].add(player: player, card: Card.new(rank: ACE, suit: DIAMONDS))
      silence do
        allow(player).to receive(:gets).and_return('1', '2')
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: NINE, suit: DIAMONDS)
      end
    end
  end

  context 'when clubs are trumps, and holding Joker, Jack Clubs, Jack Spades, Nine Clubs, Nine Spades' do
    let(:trumps) { CLUBS }
    let(:player1) { HumanPlayer.new(name: 'player1') }
    let(:player2) { HumanPlayer.new(name: 'player2') }

    let(:joker) { Card.new(rank: JOKER, suit: JOKER_SUIT) }
    let(:jack_of_clubs) { Card.new(rank: JACK, suit: CLUBS) }
    let(:jack_of_spades) { Card.new(rank: JACK, suit: SPADES) }
    let(:nine_of_clubs) { Card.new(rank: NINE, suit: CLUBS) }
    let(:nine_of_spades) { Card.new(rank: NINE, suit: SPADES) }

    let(:tricks) { Array.new(5) { Trick.new(trumps: trumps) } }

    let(:ace_of_spaces) { Card.new(rank: ACE, suit: SPADES) }
    let(:ace_of_clubs) { Card.new(rank: ACE, suit: CLUBS) }

    before do
      player2.hand = [joker, jack_of_clubs, jack_of_spades, nine_of_clubs, nine_of_spades]
    end

    it 'only accepts Nine Spades if Ace of Spades is led' do
      # Trumps are clubs. Ace of spades is led. Player holds jack of spades, and may not play the joker or the jack of clubs.
      tricks[0].add(player: player1, card: ace_of_spaces)
      silence do
        allow(player2).to receive(:gets).and_return("1", "2", "3", "4", "5")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: NINE, suit: SPADES)
      end
    end

    it 'accepts the Joker, Jack of Clubs and Jack of Spades if Ace of Clubs is led' do
      tricks[0].add(player: player1, card: ace_of_clubs)
      silence do
        allow(player2).to receive(:gets).and_return("3")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: JACK, suit: SPADES)
        allow(player2).to receive(:gets).and_return("2")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: JACK, suit: CLUBS)
        allow(player2).to receive(:gets).and_return("1")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: JOKER, suit: JOKER_SUIT)
      end
    end
  end
end
