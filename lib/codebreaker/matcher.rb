module Codebreaker
  class Matcher

    def initialize(game_code, guess_code)
      @game_code, @guess_code = game_code, guess_code
    end

    def get_exact_matches
      (0..3).inject(0) {|exact_matches, index| exact_matches + (exact_match?(index) ? 1 : 0) }
    end

    def get_number_matches
      (0..3).inject(0) {|exact_matches, index| exact_matches + (number_match?(index) ? 1 : 0) }
    end

    private
      def exact_match?(index)
        @game_code[index] == @guess_code[index]
      end

      def number_match?(index)
        !exact_match?(index) && @game_code.include?(@guess_code[index])
      end
  end
end
