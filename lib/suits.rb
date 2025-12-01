# frozen_string_literal: true

SUITS = {
  C: {
    text: 'Clubs',
    glyph: '♣'
  },
  D: {
    text: 'Diamonds',
    glyph: "\e[31m♦\e[0m"
  },
  H: {
    text: 'Hearts',
    glyph: "\e[31m♥\e[0m"
  },
  S: {
    text: 'Spades',
    glyph: '♠'
  },
  J: {
    text: 'Joker',
    glyph: 'J'
  }
}.freeze
