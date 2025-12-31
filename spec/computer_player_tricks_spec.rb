# frozen_string_literal: true

require 'euchre'
require 'helpers'

module Euchre
  include Euchre::Constants
  RSpec.describe Players::ComputerPlayerTricks do
    before do
      allow_any_instance_of(Players::ComputerPlayerTricks).to receive(:think)
      allow_any_instance_of(Players::ComputerPlayerTricks).to receive(:wait_for_user_to_press_enter)
    end

    let(:computer_player_tricks) { Players::ComputerPlayerTricks.new }
    let(:hand) { [
      Props::Card.for(rank: JACK, suit: DIAMONDS),
      Props::Card.for(rank: ACE, suit: DIAMONDS),
      Props::Card.for(rank: KING, suit: DIAMONDS),
      Props::Card.for(rank: QUEEN, suit: DIAMONDS),
      Props::Card.for(rank: TEN, suit: SPADES)
    ] }
    let(:trumps) { DIAMONDS }
    let(:tricks) { Array.new(5) { Props::Trick.new(trumps: trumps) } }

    context 'when playing a trick holding JD, AD, KD, QD, TS, Diamonds are trumps' do
      describe "#play_card" do
        it 'chooses the highest held trump card to lead' do
          silence do
            expect(computer_player_tricks.play_card(
              trumps: trumps,
              tricks: tricks,
              trick_index: 0,
              hand: hand
            )).to have_attributes(rank: JACK, suit: DIAMONDS)
          end
        end

        it 'follows suit if a spade is led' do
          tricks[0].add(player: computer_player_tricks, card: Props::Card.for(rank: ACE, suit: SPADES))
          silence do
            expect(computer_player_tricks.play_card(
              trumps: trumps,
              tricks: tricks,
              trick_index: 0,
              hand: hand
            )).to have_attributes(rank: TEN, suit: SPADES)
          end
        end

        it 'plays the weakest valid card, if it cannot win the trick' do
          tricks[1].add(player: computer_player_tricks, card: Props::Card.for(rank: JOKER, suit: JOKER_SUIT))
          silence do
            expect(computer_player_tricks.play_card(
              trumps: trumps,
              tricks: tricks,
              trick_index: 1,
              hand: hand
            )).to have_attributes(rank: QUEEN, suit: DIAMONDS)
          end
        end
      end
    end
  end
end
