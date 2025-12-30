# frozen_string_literal: true

require 'bidding_manager'
require 'ostruct'
require 'constants'
require 'display'
require 'computer_player'
require 'human_player'

RSpec.describe BiddingManager do
  let(:bidding_manager) { BiddingManager.new }
  let(:display) { instance_double('Display') }
  let(:south) { instance_double('HumanPlayer')}
  let(:west) { instance_double('ComputerPlayer')}
  let(:north) { instance_double('ComputerPlayer')}
  let(:east) { instance_double('ComputerPlayer')}

  let(:players) do
    double(
      team1: [south, north],
      team2: [west, east]
    )
  end

  let(:context) do
    OpenStruct.new(
      players: players,
      dealer: east,
      player_order: [south, west, north, east],
      center_card: :some_card,
      center_card_suit: HEARTS
    )
  end

  before do
    allow(display).to receive(:clear_screen)
    allow(display).to receive(:score)
    allow(display).to receive(:players)
    allow(display).to receive(:message)
  end

  describe '#handle_bidding' do
    context 'when bidding succeeds in round one' do
      before do
        allow(south).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(west).to receive(:decide_bid).and_return({ bid: HEARTS, going_alone: false })
        allow(context.dealer).to receive(:exchange_card!)
      end
      it 'updates the context object' do
        result = bidding_manager.handle_bidding(context: context, display: display)
        bid = result.bid
        expect(bid.pass).to eq false
        expect(bid.trumps).to eq HEARTS
        expect(bid.bidder).to eq west
        expect(bid.bidders).to eq context.players.team2
        expect(bid.defenders).to eq context.players.team1
      end

      it 'messages collaborators correctly' do
        expect(display).to receive(:clear_screen)
        expect(south).to receive(:decide_bid).with(options: [HEARTS], card: context.center_card, dealer: :opposition)
        expect(context.dealer).to receive(:exchange_card!).with(card: context.center_card, trumps: HEARTS)

        bidding_manager.handle_bidding(context: context, display: display)
      end
    end

    context 'when bidding succeeds in round two' do
      before do
        allow(south).to receive(:decide_bid).and_return(
          { bid: :pass, going_alone: false },
          { bid: DIAMONDS, going_alone: false }
        )
        allow(west).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(north).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(east).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
      end
      it 'updates the context object showing that the bid was not passed, bidder is south, bidders and defenders correct' do
        result = bidding_manager.handle_bidding(context: context, display: display)
        bid = result.bid
        expect(bid.pass).to eq false
        expect(bid.trumps).to eq DIAMONDS
        expect(bid.bidder).to eq south
        expect(bid.bidders).to eq context.players.team1
        expect(bid.defenders).to eq context.players.team2
      end
      it 'messages collaborators correctly' do
        expect(display).to receive(:clear_screen)
        expect(south).to receive(:decide_bid).with(options: [CLUBS, DIAMONDS, SPADES])
        expect(context.dealer).not_to receive(:exchange_card!)

        bidding_manager.handle_bidding(context: context, display: display)
      end

    end

    context 'when all players pass twice' do
      before do
        allow(south).to receive(:decide_bid).and_return(
          { bid: :pass, going_alone: false },
          { bid: :pass, going_alone: false }
        )
        allow(west).to receive(:decide_bid).and_return(
          { bid: :pass, going_alone: false },
          { bid: :pass, going_alone: false }
        )
        allow(north).to receive(:decide_bid).and_return(
          { bid: :pass, going_alone: false },
          { bid: :pass, going_alone: false }
        )
        allow(east).to receive(:decide_bid).and_return(
          { bid: :pass, going_alone: false },
          { bid: :pass, going_alone: false }
        )
      end

      it 'updates the context object showing that the bid was passed' do
        result = bidding_manager.handle_bidding(context: context, display: display)
        bid = result.bid
        expect(bid.pass).to eq true
        expect(bid.trumps).to eq nil
      end

      it 'messages collaborators' do
        expect(display).to receive(:clear_screen)
        expect(south).to receive(:decide_bid).with(options: [HEARTS], card: context.center_card, dealer: :opposition)
        expect(south).to receive(:decide_bid).with(options: [CLUBS, DIAMONDS, SPADES])
        expect(context.dealer).not_to receive(:exchange_card!)

        bidding_manager.handle_bidding(context: context, display: display)
      end
    end

    context 'when the dealer picks up and goes alone' do
      before do
        allow(south).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(west).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(north).to receive(:decide_bid).and_return({ bid: :pass, going_alone: false })
        allow(east).to receive(:decide_bid).and_return({ bid: HEARTS, going_alone: true })
        allow(context.dealer).to receive(:exchange_card!)
      end

      it 'updates the context object including the player order indicating that west is not playing this hand' do
        result = bidding_manager.handle_bidding(context: context, display: display)
        bid = result.bid
        expect(bid.pass).to eq false
        expect(bid.trumps).to eq HEARTS
        expect(bid.going_alone).to eq true
        expect(bid.bidder).to eq east
        expect(result.player_order).to eq [south, north, east]
      end
    end
  end
end
