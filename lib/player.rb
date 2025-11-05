# frozen_string_literal: true

# Player superclass
class Player
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
end
