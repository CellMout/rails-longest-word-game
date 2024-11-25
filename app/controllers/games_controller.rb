require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = Array.new(10) { ("A".."Z").to_a.sample }
    @start_time = Time.now
  end

  def score
    start_time = Time.parse(params[:start_time])
    attempt = params[:word]
    end_time = Time.now
    grid = JSON.parse(params[:grid])
    word = JSON.parse(URI.parse("https://dictionary.lewagon.com/#{attempt}").read)
    time = end_time - start_time
    word_valid = (grid.sort & attempt.upcase.chars.sort).flat_map do |letter|
      [letter] * [grid.sort.count(letter), attempt.upcase.chars.sort.count(letter)].min
    end  == attempt.upcase.chars.sort
    score = word["found"] & word_valid ? (word["length"].fdiv(grid.size) * 100).fdiv(time.fdiv(10)).round(1) : 0
    message = (word_valid ? "Well done!" : "Your word cannot be found in the grid") if word["found"]
    message = "Your word is not an english word" unless word["found"]
    @score = { score: score, message: message, time: time.round(1) }
  end
end
