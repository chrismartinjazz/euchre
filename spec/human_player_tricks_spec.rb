# frozen_string_literal: true

require 'euchre'
require 'helpers'

module Euchre
  include Euchre::Constants
  RSpec.describe Players::HumanPlayerTricks do
    let(:human_player_tricks) { Players::HumanPlayerTricks.new }
    let(:tricks) { Array.new(5) { Props::Trick.new(trumps: trumps) } }


    context 'when holding JD, AD, KD, QD, TS and Diamonds are trumps' do
      let(:trumps) { DIAMONDS }
      let(:hand) { [
        Props::Card.for(rank: JACK, suit: DIAMONDS),
        Props::Card.for(rank: ACE, suit: DIAMONDS),
        Props::Card.for(rank: KING, suit: DIAMONDS),
        Props::Card.for(rank: QUEEN, suit: DIAMONDS),
        Props::Card.for(rank: TEN, suit: SPADES)
      ] }

      it 'can choose the first card in hand to lead (JD), when no other card has been played' do
        silence do
          allow(human_player_tricks).to receive(:gets).and_return('1')
          expect(human_player_tricks.play_card(
            trumps: trumps,
            tricks: tricks,
            trick_index: 0,
            hand: hand
          )).to have_attributes(rank: JACK, suit: DIAMONDS)
        end
      end

      it 're-prompts on a card that does not follow suit (AS played, re-prompts on JD, allows TS)' do
        tricks[0].add(player: human_player_tricks, card: Props::Card.for(rank: ACE, suit: SPADES))
        silence do
          allow(human_player_tricks).to receive(:gets).and_return('1', '5')
          expect(human_player_tricks.play_card(
            trumps: trumps,
            tricks: tricks,
            trick_index: 0,
            hand: hand
          )).to have_attributes(rank: TEN, suit: SPADES)
        end
      end
    end

    context 'when holding ?J, JC, JS, 9C, 9S and clubs are trumps' do
      let(:trumps) { CLUBS }
      let(:hand) { [
        Props::Card.for(rank: JOKER, suit: JOKER_SUIT),
        Props::Card.for(rank: JACK, suit: CLUBS),
        Props::Card.for(rank: JACK, suit: SPADES),
        Props::Card.for(rank: NINE, suit: CLUBS),
        Props::Card.for(rank: NINE, suit: SPADES)
      ] }

      it 'accepts the Joker if Ace of Clubs is led' do
        tricks[0].add(player: 'test player', card: Props::Card.for(rank: ACE, suit: CLUBS))
        silence do
          allow(human_player_tricks).to receive(:gets).and_return("1")
          expect(human_player_tricks.play_card(
            trumps: trumps,
            tricks: tricks,
            trick_index: 0,
            hand: hand
          )).to have_attributes(rank: JOKER, suit: JOKER_SUIT)
        end
      end

      it 'accepts the Jack of Clubs if Ace of Clubs is led' do
        tricks[0].add(player: 'test player', card: Props::Card.for(rank: ACE, suit: CLUBS))
        silence do
          allow(human_player_tricks).to receive(:gets).and_return("2")
          expect(human_player_tricks.play_card(
            trumps: trumps,
            tricks: tricks,
            trick_index: 0,
            hand: hand
          )).to have_attributes(rank: JACK, suit: CLUBS)
        end
      end

      it 'accepts the Jack of Spades if Ace of Clubs is led' do
        tricks[0].add(player: 'test player', card: Props::Card.for(rank: ACE, suit: CLUBS))
        silence do
          allow(human_player_tricks).to receive(:gets).and_return("3")
          expect(human_player_tricks.play_card(
            trumps: trumps,
            tricks: tricks,
            trick_index: 0,
            hand: hand
          )).to have_attributes(rank: JACK, suit: SPADES)
        end
      end
    end
  end
end
