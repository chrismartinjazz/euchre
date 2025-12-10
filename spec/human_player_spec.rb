# frozen_string_literal: true

require 'constants'
require 'human_player'
require 'deck'
require 'trick'
require 'helpers'

RSpec.describe HumanPlayer do
  context 'with a player and an empty hand' do
    player = HumanPlayer.new(name: 'player')
    it 'creates a player with the given name and an empty hand' do
      expect(player.name).to eq 'player'
      expect(player.hand).to eq []
    end
  end

  context 'with a standard deck, 5 cards dealt to player hand' do
    player = HumanPlayer.new(name: 'player')
    deck = Deck.new
    player.hand = deck.deal(count: 5)
    card = deck.draw_one
    it 'successfully exchanges a card' do
      silence do
        allow(player).to receive(:gets).and_return('1')
        discarded_card = player.exchange_card(card: card)
        expect(discarded_card.suit).to eq :C
        expect(discarded_card.rank).to eq :'2'
      end
    end

    it 'can pass on the centre card' do
      silence do
        allow(player).to receive(:gets).and_return('2', 'N')
        response = player.bid_centre_card(card: card, suit: card.suit)
        expect(response[:bid]).to eq :pass
        expect(response[:going_alone]).to eq false
      end
    end

    it 'can pick up the centre card' do
      silence do
        allow(player).to receive(:gets).and_return('1', 'N')
        response = player.bid_centre_card(card: card, suit: card.suit)
        expect(response[:bid]).to eq card.suit
      end
    end

    it 'can pass when bidding trumps' do
      silence do
        allow(player).to receive(:gets).and_return('P', 'N')
        response = player.bid_trumps(options: [:C, :D, :H, :S])
        expect(response[:bid]).to eq :pass
      end
    end

    it 'can bid for a valid suit (clubs)' do
      silence do
        allow(player).to receive(:gets).and_return('C', 'N')
        response = player.bid_trumps(options: [:C, :D, :H, :S])
        expect(response[:bid]).to eq :C
      end
    end

    it 're-prompts if player inputs an invalid suit' do
      silence do
        allow(player).to receive(:gets).and_return('C', 'D', 'N')
        response = player.bid_trumps(options: [:D, :H, :S])
        expect(response[:bid]).to eq :D
      end
    end
  end

  context 'when playing a trick' do
    player = HumanPlayer.new(name: 'player')
    deck = Deck.new(ranks: %i[2 3], suits: %i[C D H S], joker_count: 0)
    # Player is holding 2C 2D 2H 2S 3C
    player.hand = deck.deal(count: 5)
    trumps = :C
    tricks = Array.new(5) { Trick.new(trumps: trumps) }

    it 'can choose the first card in hand to lead, when no other card has been played' do
      silence do
        allow(player).to receive(:gets).and_return('1')
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :'2', suit: :C)
      end
    end

    it 're-prompts on a card that does not follow suit' do
      card = Card.new(rank: :A, suit: :D)
      tricks[0].add(player: player, card: card)
      silence do
        allow(player).to receive(:gets).and_return('1', '2')
        expect(player.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :'2', suit: :D)
      end
    end
  end

  context 'when clubs are trumps, and holding Joker, Jack Clubs, Jack Spades, Nine Clubs, Nine Spades' do
    trumps = :C
    player1 = HumanPlayer.new(name: 'player1')
    player2 = HumanPlayer.new(name: 'player2')

    joker = Card.new(rank: JOKER_RANK, suit: JOKER_SUIT)
    jack_of_clubs = Card.new(rank: BOWER_RANK, suit: :C)
    jack_of_spades = Card.new(rank: BOWER_RANK, suit: :S)
    nine_of_clubs = Card.new(rank: :'9', suit: :C)
    nine_of_spades = Card.new(rank: :'9', suit: :S)

    player2.hand = [joker, jack_of_clubs, jack_of_spades, nine_of_clubs, nine_of_spades]
    tricks = Array.new(5) { Trick.new(trumps: trumps) }
    it 'only accepts Nine Spades if Ace of Spades is led' do
      # Trumps are clubs. Ace of spades is led. Player holds jack of spades, and may not play the joker or the jack of clubs.
      ace_of_spaces = Card.new(rank: :A, suit: :S)
      tricks[0].add(player: player1, card: ace_of_spaces)
      silence do
        allow(player2).to receive(:gets).and_return("1", "2", "3", "4", "5")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :'9', suit: :S)
      end
    end

    it 'accepts the Joker, Jack of Clubs and Jack of Spades if Ace of Clubs is led' do
      ace_of_clubs = Card.new(rank: :A, suit: :C)
      tricks[0].add(player: player1, card: ace_of_clubs)
      silence do
        allow(player2).to receive(:gets).and_return("3")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :J, suit: :S)
        allow(player2).to receive(:gets).and_return("2")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :J, suit: :C)
        allow(player2).to receive(:gets).and_return("1")
        expect(player2.play_card(trumps: trumps, tricks: tricks, trick_index: 0)).to have_attributes(rank: :'?', suit: :J)
      end
    end
  end
end
