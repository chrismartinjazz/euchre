# frozen_string_literal: true

require 'euchre'
require 'ostruct'

module Euchre
  include Euchre::Constants
  RSpec.describe Managers::TrickManager do
    let(:trick_manager) { Managers::TrickManager.new }
    let(:display) { instance_double('Display') }

    let(:south) { instance_double('HumanPlayer')}
    let(:west) { instance_double('ComputerPlayer')}
    let(:north) { instance_double('ComputerPlayer')}
    let(:east) { instance_double('ComputerPlayer')}
    let(:team1) { [south, north] }
    let(:team2) { [west, east] }
    let(:players) do
      OpenStruct.new(
        team1: team1,
        team2: team2
      )
    end

    let(:bid) do
      OpenStruct.new(
        trumps: :some_suit,
        going_alone: false,
        bidders: team1,
        defenders: team2
      )
    end

    let(:context) do
      OpenStruct.new(
        players: players,
        bid: bid,
        player_order: [south, west, north, east]
      )
    end

    let(:trick1) { instance_double('Trick') }
    let(:trick2) { instance_double('Trick') }
    let(:trick3) { instance_double('Trick') }
    let(:trick4) { instance_double('Trick') }
    let(:trick5) { instance_double('Trick') }

    before do
      allow(display).to receive(:clear_screen)
      allow(display).to receive(:score)
      allow(display).to receive(:players)
      allow(display).to receive(:tricks)
      allow(display).to receive(:message)

      allow(south).to receive(:play_card).and_return(:some_card, :some_card, :some_card, :some_card, :some_card)
      allow(west).to receive(:play_card).and_return(:some_card, :some_card, :some_card, :some_card, :some_card)
      allow(north).to receive(:play_card).and_return(:some_card, :some_card, :some_card, :some_card, :some_card)
      allow(east).to receive(:play_card).and_return(:some_card, :some_card, :some_card, :some_card, :some_card)

      [trick1, trick2, trick3, trick4, trick5].each do |trick|
        allow(trick).to receive(:add)
      end
    end

    describe '#play_hand' do
      context 'with a single trick where team1 bid and south, a member of team1, wins the trick' do
        it 'reports team1 as the winner of the hand scoring 2 points (bidders won all tricks)' do
          prepare_tricks({ trick1 => south })

          trick_manager.play_hand(context: context, display: display, tricks: [trick1])

          expect(context.result.winners).to eq team1
          expect(context.result.points).to eq 2
        end
      end

      context 'bidders win 3 tricks, winners are N, S, N, E, E' do
        it 'reports team1 as the winner of the hand scoring 1 point' do
          prepare_tricks({ trick1 => north, trick2 => south, trick3 => north, trick4 => east, trick5 => east })
          tricks = [trick1, trick2, trick3, trick4, trick5]

          trick_manager.play_hand(context: context, display: display, tricks: tricks)

          expect(context.result.winners).to eq team1
          expect(context.result.points).to eq 1
        end
      end

      context 'bidders win only 1 trick, winners are N E W E E' do
        it 'reports team2 as the winner of the hand scoring 2 points' do
          prepare_tricks({ trick1 => north, trick2 => east, trick3 => west, trick4 => east, trick5 => east })
          tricks = [trick1, trick2, trick3, trick4, trick5]

          trick_manager.play_hand(context: context, display: display, tricks: tricks)

          expect(context.result.winners).to eq team2
          expect(context.result.points).to eq 2
        end
      end

      context 'bidders win all 5 tricks' do
        it 'reports team1 as the winner of the hand scoring 2 points' do
          prepare_tricks({ trick1 => north, trick2 => south, trick3 => north, trick4 => north, trick5 => south })
          tricks = [trick1, trick2, trick3, trick4, trick5]

          trick_manager.play_hand(context: context, display: display, tricks: tricks)

          expect(context.result.winners).to eq team1
          expect(context.result.points).to eq 2
        end
      end

      context 'bidders go alone and win 3 tricks' do
        it 'reports team1 as the winner of the hand scoring 1 point' do
          context.bid.going_alone = true
          prepare_tricks({ trick1 => west, trick2 => east, trick3 => north, trick4 => north, trick5 => north })
          tricks = [trick1, trick2, trick3, trick4, trick5]

          trick_manager.play_hand(context: context, display: display, tricks: tricks)

          expect(context.result.winners).to eq team1
          expect(context.result.points).to eq 1
        end
      end

      context 'bidders go alone and win 5 tricks' do
        it 'reports team1 as the winner of the hand scoring 4 points' do
          context.bid.going_alone = true
          prepare_tricks({ trick1 => north, trick2 => north, trick3 => north, trick4 => north, trick5 => north })
          tricks = [trick1, trick2, trick3, trick4, trick5]

          trick_manager.play_hand(context: context, display: display, tricks: tricks)

          expect(context.result.winners).to eq team1
          expect(context.result.points).to eq 4
        end
      end
    end

    def prepare_tricks(results)
      results.each { |trick, winner| allow(trick).to receive(:winner).and_return(winner) }
    end
  end
end
