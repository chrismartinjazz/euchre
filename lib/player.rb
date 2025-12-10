# frozen_string_literal: true

# Player superclass
class Player
  attr_reader :name
  attr_accessor :hand

  def initialize(name: 'Unknown')
    @hand = []
    @name = name
  end

  def reset_hand
    @hand.clear
  end

  def to_s
    @name
  end

  # Methods that must be implemented by subclasses
  def bid_centre_card(**_keyword_args)
    raise NotImplementedError
  end

  def bid_trumps(**_keyword_args)
    raise NotImplementedError
  end

  def exchange_card(**_keyword_args)
    raise NotImplementedError
  end

  def choose_a_suit(**_keyword_args)
    raise NotImplementedError
  end
end
