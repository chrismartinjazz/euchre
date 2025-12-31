# frozen_string_literal: true

require 'euchre'
require 'ostruct'

module Euchre
  RSpec.describe Managers::ScoreManager do
    let(:score_manager) { Managers::ScoreManager.new }
    let(:display) { instance_double('Display') }
    let(:team1) { [:south, :north] }
    let(:team2) { [:west, :east] }
    let(:context) { OpenStruct.new }

    before do
      context.players = OpenStruct.new(team1: team1, team2: team2)
      allow(display).to receive(:message)
    end

    describe '#prepare' do
      it 'adds a score hash to context' do
        context.score = nil
        score_manager.prepare(context: context)

        expect(context.score[context.players.team1]).to eq 0
        expect(context.score[context.players.team2]).to eq 0
      end
    end

    describe '#update_score' do
      it 'processes result and adds the correct score to team 2' do
        context.score = { team1 => 2, team2 => 3 }
        context.result = OpenStruct.new(winners: team2, points: 1)

        score_manager.update_score(context: context, display: display)

        expect(context.score[team1]).to eq 2
        expect(context.score[team2]).to eq 4
      end

      it 'processes result and adds the correct score to team 2' do
        context.score = { team1 => 2, team2 => 4 }
        context.result = OpenStruct.new(winners: team1, points: 4)

        score_manager.update_score(context: context, display: display)

        expect(context.score[team1]).to eq 6
        expect(context.score[team2]).to eq 4
      end
    end

    describe '#game_over' do
      it 'correctly identifies when the game is not over' do
        context.score = { team1 => 2, team2 => 1 }

        result = score_manager.game_over?(context: context)
        expect(result).to eq false
      end

      it 'correctly identifies when the game is over' do
        context.score = { team1 => Managers::ScoreManager::POINTS_TO_WIN_GAME, team2 => 2 }

        result = score_manager.game_over?(context: context)
        expect(result).to eq true
      end
    end
  end
end
