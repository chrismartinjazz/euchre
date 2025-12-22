# frozen_string_literal: true

require 'human_player_tricks'
require 'helpers'
require 'constants'
require 'card'
require 'trick'

RSpec.describe HumanPlayerTricks do
  let(:human_player_tricks) { HumanPlayerTricks.new }
  let(:tricks) { Array.new(5) { Trick.new(trumps: trumps) } }


  context 'when holding JD, AD, KD, QD, TS and Diamonds are trumps' do
    let(:trumps) { DIAMONDS }
    let(:hand) { [
      Card.for(rank: JACK, suit: DIAMONDS),
      Card.for(rank: ACE, suit: DIAMONDS),
      Card.for(rank: KING, suit: DIAMONDS),
      Card.for(rank: QUEEN, suit: DIAMONDS),
      Card.for(rank: TEN, suit: SPADES)
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
      tricks[0].add(player: human_player_tricks, card: Card.for(rank: ACE, suit: SPADES))
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
      Card.for(rank: JOKER, suit: JOKER_SUIT),
      Card.for(rank: JACK, suit: CLUBS),
      Card.for(rank: JACK, suit: SPADES),
      Card.for(rank: NINE, suit: CLUBS),
      Card.for(rank: NINE, suit: SPADES)
    ] }

    it 'accepts the Joker if Ace of Clubs is led' do
      tricks[0].add(player: 'test player', card: Card.for(rank: ACE, suit: CLUBS))
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
      tricks[0].add(player: 'test player', card: Card.for(rank: ACE, suit: CLUBS))
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
      tricks[0].add(player: 'test player', card: Card.for(rank: ACE, suit: CLUBS))
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
