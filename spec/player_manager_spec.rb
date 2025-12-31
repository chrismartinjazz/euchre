# frozen_string_literal: true

require 'euchre'
require 'ostruct'

module Euchre
  RSpec.describe Managers::PlayerManager do
    let(:player_manager) { Managers::PlayerManager.new }
    let(:context) do
      OpenStruct.new(
        players: nil,
        dealer: nil,
        display_order: nil
      )
    end
    describe '#prepare' do

      it 'modifies context adding players, teams, and display order' do
        player_manager.prepare(context: context)

        expect(context.players).to be_a(GameState::Players)
        expect(context.players.south).to be_a(Players::Player)
        expect(context.players.west).to be_a(Players::Player)
        expect(context.players.north).to be_a(Players::Player)
        expect(context.players.east).to be_a(Players::Player)
        expect(context.players.team1).to be_a(Array)
        expect(context.players.team2).to be_a(Array)
        expect(context.dealer).to be_a(Players::Player)
        expect(context.display_order).to be_a(Array)

        expect(context.display_order.last).to eq(context.dealer)
      end
    end
  end
end
