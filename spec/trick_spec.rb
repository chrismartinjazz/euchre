# frozen_string_literal: true

require 'constants'
require 'trick'
require 'card'
require 'player'

RSpec.describe Trick do
  let(:south) { 'test south' }
  let(:west) { 'test west' }
  let(:north) { 'test north' }
  let(:east) { 'test east' }

  let(:nine_of_diamonds) { Card.for(rank: NINE, suit: DIAMONDS) }
  let(:ten_of_diamonds) { Card.for(rank: TEN, suit: DIAMONDS) }
  let(:king_of_diamonds) { Card.for(rank: KING, suit: DIAMONDS) }

  let(:ten_of_spades) { Card.for(rank: TEN, suit: SPADES) }
  let(:jack_of_spades) { Card.for(rank: JACK, suit: SPADES) }
  let(:ace_of_spades) { Card.for(rank: ACE, suit: SPADES) }

  let(:nine_of_clubs) { Card.for(rank: NINE, suit: CLUBS) }
  let(:jack_of_clubs) { Card.for(rank: JACK, suit: CLUBS) }
  let(:ace_of_clubs) { Card.for(rank: ACE, suit: CLUBS) }

  let(:joker) { Card.for(rank: JOKER, suit: JOKER_SUIT) }

  context 'when clubs are trumps and all four players are playing' do
    let(:trumps) { CLUBS }
    let(:trick) { Trick.new(trumps: trumps) }

    it 'successfully instantiates a trick with an empty array of plays and a lead-suit of nil' do
      expect(trick.plays).to be_kind_of(Array)
      expect(trick.plays.length).to eq 0
      expect(trick.lead_suit).to eq nil
    end

    describe '#add' do
      it 'adds a card (TD) to the trick recording the newly lead suit (Diamonds), player, card, and the cards rating' do
        trick.add(player: south, card: ten_of_diamonds)

        expect(trick.lead_suit).to eq DIAMONDS
        expect(trick.plays[0][:player]).to eq south
        expect(trick.plays[0][:card]).to have_attributes(rank: TEN, suit: DIAMONDS)
        expect(trick.plays[0][:rating]).to be_kind_of(Numeric)
      end

      it 'adds two cards (TD, TS), still records the lead suit as (Diamonds)' do
        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)

        expect(trick.lead_suit).to eq DIAMONDS
      end

      it 'returns a hash with the player, card, and card rating when a card is added' do
        return_value = trick.add(player: south, card: ten_of_diamonds)

        expect(return_value.keys).to contain_exactly(:player, :card, :rating)
      end

      it 'returns nil and does not add the card, if the trick is already complete' do
        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)
        trick.add(player: north, card: king_of_diamonds)
        trick.add(player: east, card: nine_of_diamonds)

        return_value = trick.add(player: 'other player', card: nine_of_clubs)
        expect(return_value).to eq nil
        expect(trick.plays.length).to eq 4

      end

      it 'returns nil and does not add the card, if the player has already played in that trick' do
        trick.add(player: south, card: ten_of_diamonds)
        return_value = trick.add(player: south, card: king_of_diamonds)

        expect(return_value).to eq nil
        expect(trick.plays.length).to eq 1
      end
    end

    describe '#winner' do
      it 'identifies the winning player of the trick correctly, or "nil" if the trick is not complete' do
        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)
        trick.add(player: north, card: king_of_diamonds)
        expect(trick.winner).to eq nil

        trick.add(player: east, card: nine_of_diamonds)
        expect(trick.winner).to eq north
      end
    end

    describe '#complete?' do
      it 'correctly reports if a trick is complete' do
        expect(trick.complete?).to eq false

        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)
        expect(trick.complete?).to eq false

        trick.add(player: north, card: king_of_diamonds)
        trick.add(player: east, card: nine_of_diamonds)
        expect(trick.complete?).to eq true
      end
    end

    describe '#winning_play' do

      it 'returns a hash with nil values if no cards have been played' do
        expect(trick.winning_play.values.all?(nil)).to eq true
      end

      it 'identifies the current winning play respecting the lead suit, with other non-trump cards (TD, KD*, 9D, AS)' do
        trick.add(player: south, card: ten_of_diamonds)
        expect(trick.winning_play[:card]).to eq ten_of_diamonds

        trick.add(player: west, card: king_of_diamonds)
        expect(trick.winning_play[:card]).to eq king_of_diamonds

        trick.add(player: north, card: nine_of_diamonds)
        expect(trick.winning_play[:card]).to eq king_of_diamonds

        trick.add(player: east, card: ace_of_spades)
        expect(trick.winning_play[:card]).to eq king_of_diamonds
      end
      it 'identifies winning plays considering the suit that is lead, and trumping the leader (TD, AS, 9D, 9C*)' do
        trick.add(player: south, card: ten_of_diamonds)
        expect(trick.winning_play[:card]).to eq ten_of_diamonds

        trick.add(player: west, card: ace_of_spades)
        expect(trick.winning_play[:card]).to eq ten_of_diamonds

        trick.add(player: north, card: nine_of_diamonds)
        expect(trick.winning_play[:card]).to eq ten_of_diamonds

        trick.add(player: east, card: nine_of_clubs)
        expect(trick.winning_play[:card]).to eq nine_of_clubs
      end

      it 'identifies winning plays in tricks including the joker and bowers (AC, JS, JC, ?J*)' do
        trick.add(player: east, card: ace_of_clubs)
        expect(trick.winning_play[:card]).to eq ace_of_clubs

        trick.add(player: south, card: jack_of_spades)
        expect(trick.winning_play[:card]).to eq jack_of_spades

        trick.add(player: west, card: jack_of_clubs)
        expect(trick.winning_play[:card]).to eq jack_of_clubs

        trick.add(player: north, card: joker)
        expect(trick.winning_play[:card]).to eq joker
      end
    end

    describe '#card' do
      it 'reports the card played by a given player in a trick, or nil if no card by that player' do
        expect(trick.card(player: east)).to eq nil

        trick.add(player: east, card: ace_of_clubs)
        trick.add(player: south, card: jack_of_spades)
        trick.add(player: west, card: jack_of_clubs)
        trick.add(player: north, card: joker)

        expect(trick.card(player: east)).to eq ace_of_clubs
        expect(trick.card(player: south)).to eq jack_of_spades
      end
    end
  end

  context 'when diamonds are trumps and three players are playing' do
    let(:trumps) { DIAMONDS }
    let(:trick) { Trick.new(trumps: trumps, player_count: 3) }

    it 'successfully instantiates a trick with an empty array of plays and a lead-suit of nil' do
      expect(trick.plays).to be_kind_of(Array)
      expect(trick.plays.length).to eq 0
      expect(trick.lead_suit).to eq nil
    end

    describe "#add" do
      it 'adds cards until three cards have been added, and then returns nil' do
        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)
        trick.add(player: north, card: king_of_diamonds)

        return_value = trick.add(player: east, card: ace_of_clubs)
        expect(return_value).to eq nil
        expect(trick.plays.length).to eq 3
      end
    end

    describe "#complete?" do
      it 'identifies that the trick is complete after three cards played' do
        trick.add(player: south, card: ten_of_diamonds)
        trick.add(player: west, card: ten_of_spades)
        expect(trick.complete?).to eq false

        trick.add(player: north, card: king_of_diamonds)
        expect(trick.complete?).to eq true
      end
    end
  end
end
