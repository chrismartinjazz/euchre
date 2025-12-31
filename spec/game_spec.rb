# frozen_string_literal: true

require 'euchre'

module Euchre
  RSpec.describe Game do
    let(:game) { Game.new }

    before do
      allow(game).to receive(:update_display)
      allow(game).to receive(:display_end_game_messages)

      [player_manager, deal_manager, score_manager, display].each { |preparer| allow(preparer).to receive(:prepare) }
      allow(deal_manager).to receive(:deal)
      allow(trick_manager).to receive(:play_hand)
      allow(score_manager).to receive(:update_score)
      allow(deal_manager).to receive(:rotate_player_order)
    end

    it 'runs the game loop at least once' do
      prepare_game(pass: true, game_over: [false, true])

      game.start_game_loop

      expect(score_manager).to have_received(:game_over?).twice
    end

    it 'does not play a hand or update the score if the bid is passed' do
      prepare_game(pass: true, game_over: [false, true])

      game.start_game_loop

      expect(trick_manager).not_to have_received(:play_hand)
      expect(score_manager).not_to have_received(:update_score)
    end

    it 'does play the hand and update the score if the bid is not passed' do
      prepare_game(pass: false, game_over: [false, true])

      game.start_game_loop

      expect(trick_manager).to have_received(:play_hand)
      expect(score_manager).to have_received(:update_score)
    end

    def prepare_game(pass:, game_over:)
      allow(bidding_manager).to receive(:handle_bidding) do |context:, **|
        context.bid = instance_double('Bid', pass: pass)
      end
      allow(score_manager).to receive(:game_over?).and_return(*game_over)
    end

    %i[
      player_manager
      deal_manager
      bidding_manager
      trick_manager
      score_manager
      display
    ].each do |name|
      define_method(name) do
        game.instance_variable_get(:"@#{name}")
      end
    end
  end
end
