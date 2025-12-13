# frozen_string_literal: true

# Computer AI
DISPLAY_THINKING = false
THINKING_TIME = 1

# Display
DISPLAY_WIDTH = 80

# Ranks
NINE = :'9'
TEN = :T
JACK = :J
QUEEN = :Q
KING = :K
ACE = :A
LEFT_BOWER = :j
JOKER = :'?'

RANKS = {
  non_trumps: [NINE, TEN, JACK, QUEEN, KING, ACE].freeze,
  trumps: [NINE, TEN, QUEEN, KING, ACE, LEFT_BOWER, JACK, JOKER].freeze
}.freeze

# Suits
CLUBS = :C
DIAMONDS = :D
HEARTS = :H
SPADES = :S
JOKER_SUIT = :J

SUITS = {
  CLUBS => {
    text: 'Clubs',
    glyph: '♣',
    color: 'black'
  },
  DIAMONDS => {
    text: 'Diamonds',
    glyph: "\e[31m♦\e[0m",
    color: 'red'
  },
  HEARTS => {
    text: 'Hearts',
    glyph: "\e[31m♥\e[0m",
    color: 'red'
  },
  SPADES => {
    text: 'Spades',
    glyph: '♠',
    color: 'black'
  },
  JOKER_SUIT => {
    text: 'Joker',
    glyph: 'J',
    color: 'joker'
  }
}.freeze

# Utility
ANSI_ESCAPE = /\e\[[0-9;]*m/
