module Codebreaker
  class Game

    def initialize(max_attempts = 0)
      @secret_code = ''
      reset(max_attempts)
      @test_environment = false
    end

    def set_test_environment
      @test_environment = true
    end

    def start
      generate_code
    end

    def guess(guess_code)
      matcher = Matcher.new(@secret_code, guess_code)
      ''+('+'*matcher.get_exact_matches)+('-'*matcher.get_number_matches)
    end

    def play(code)
      guess_result = guess(code)
      @used_attempts += 1
      if guess_result == '++++'
        @status = 'won'
      elsif @max_attempts > 0 && @used_attempts >= @max_attempts
        @status = 'lost'
      end
      guess_result
    end

    def won?
      (@status == 'won')
    end

    def lost?
      (@status == 'lost')
    end

    def hint
      if !hint_used?
        @hint = rand(0..3)
      end
      (0..3).collect{|i| (i==@hint ? @secret_code[i] : '*')}.join
    end

    def hint_used?
      !@hint.nil?
    end

    def restart(max_attempts = 0)
      generate_code
      reset(max_attempts)
    end

    def save(name = 'anonymous')
      results = get_saved_results
      results.merge!({game_md5_key(name) => {'time' => Time.new, 'name' => name, 'game' => self}})
      save_results(results)
    end

    private
      def generate_code
        @secret_code = (0..3).collect{rand(1..6)}.join
      end

      def reset(max_attempts)
        @hint = nil
        @is_won = false
        @is_lost = false
        @status = '...'
        @used_attempts = 0
        @max_attempts = max_attempts
      end

      def get_data_file
        data_file = get_data_dir+'/results.yml'
        unless File.exist?(data_file)
          File.open(data_file, 'w') {|f| f.close}
        end
        data_file
      end

      def get_data_dir
        data_dir = File.expand_path('../../../'+(@test_environment ? 'spec/' : '') + 'data', __FILE__)
        Dir.mkdir(data_dir) unless File.directory?(data_dir)
        data_dir
      end

      def game_md5_key(name)
        game_code = @secret_code +
            '_' + self.object_id.to_s +
            '_' + name +
            '_' + (@hint.nil? ? 'nil' : @hint.to_s) +
            '_' + @is_won.to_s +
            '_' + @is_lost.to_s +
            '_' + @used_attempts.to_s +
            '_' + @max_attempts.to_s
        Digest::MD5.hexdigest(game_code)
      end

      def get_saved_results
        begin
          results = YAML::load_file(get_data_file)
          results = {} if !results
          results
        rescue
          false
        end
      end

      def save_results(results)
        begin
          File.open(get_data_file, 'w') do |f|
            f.write(results.to_yaml)
            f.close
          end
          true
        rescue
          false
        end
      end

  end
end