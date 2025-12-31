# frozen_string_literal: true

require 'euchre'
require 'ostruct'

module Euchre
  include Euchre::Constants
  RSpec.describe Managers::DealManager do
    let(:deal_manager) { Managers::DealManager.new }
    let(:display) { instance_double('Display') }
    let(:deck) { instance_double('Deck') }
    let(:center_card) { instance_double('Card')}
    let(:south) { instance_double('HumanPlayer')}
    let(:west) { instance_double('ComputerPlayer')}
    let(:north) { instance_double('ComputerPlayer')}
    let(:east) { instance_double('ComputerPlayer')}

    let(:context) do
      OpenStruct.new(
        dealer: east,
        display_order: [south, west, north, east].freeze,
        player_order: [south, west, north, east],
        center_card: nil,
        center_card_suit: nil
      )
    end

    describe '#prepare' do
      it 'modifies context, choosing a random dealer if none provided' do
        context.dealer = nil

        deal_manager.prepare(context: context)

        expect(context.player_order).to eq(context.display_order)
        expect(context.display_order.include?(context.dealer)). to be true
      end

      it 'maintains the given dealer in context if one is provided' do
        context.dealer = :some_player

        deal_manager.prepare(context: context)

        expect(context.dealer).to eq :some_player
      end
    end
    describe '#deal' do
      before do
        deal_manager.prepare(context: context)
        allow(deck).to receive(:shuffle)
        allow(deck).to receive(:deal)
        [south, west, north, east].each do |player|
          allow(player).to receive(:reset_hand)
          allow(player).to receive(:add_to_hand)
        end
        allow(deck).to receive(:draw_one).and_return(center_card)
      end

      context 'with a deal that turns up a non-joker center card' do
        before do
          allow(center_card).to receive(:suit).and_return(:some_suit, :some_suit)
        end

        it 'modifies context to reflect the new center card' do
          deal_manager.deal(context: context, display: display, deck: deck)
          expect(context.center_card).to eq center_card
          expect(context.center_card_suit).to eq :some_suit
        end
      end
      context 'with a deal that turns up a joker center card' do
        before do
          allow(center_card).to receive(:suit).and_return(JOKER_SUIT)
          allow(context.dealer).to receive(:choose_a_suit).and_return(:chosen_suit)
          allow(display).to receive(:message)
        end

        it 'asks the dealer for a suit, then modifies context to reflect the joker center card and the chosen suit' do
          deal_manager.deal(context: context, display: display, deck: deck)
          expect(context.center_card).to eq center_card
          expect(context.center_card_suit).to eq :chosen_suit
        end
      end
    end

    describe '#rotate_player_order' do
      before do
        deal_manager.prepare(context: context)
        allow(display).to receive(:message)
      end

      context 'when the player order is south, west, north, east, and the dealer is east' do
        it 'rotates the player order clockwise to west, north, east, south, and the dealer is south' do
          deal_manager.rotate_player_order(context: context, display: display)
          expect(context.player_order).to eq [west, north, east, south]
          expect(context.dealer).to eq south
        end
      end
    end
  end
end
