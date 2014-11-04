module Codebreaker
  class Game

    def initialize
      @secret_code = ""
    end

    def start
      @secret_code = (0..3).collect{rand(1..6)}.join
    end

    def guess(guess_code)
      matcher = Matcher.new(@secret_code, guess_code)
      ''+('+'*matcher.get_exact_matches)+('-'*matcher.get_number_matches)
    end

  end
end