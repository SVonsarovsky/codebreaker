module Codebreaker
  class Game

    def initialize(max_attempts = 0)
      @secret_code = ''
      reset(max_attempts)
    end

    def start # tested
      generate_code
    end

    def guess(guess_code) # tested
      matcher = Matcher.new(@secret_code, guess_code)
      ''+('+'*matcher.get_exact_matches)+('-'*matcher.get_number_matches)
    end

    def play(code) # tested
      guess_result = guess(code)
      @used_attempts += 1
      if guess_result == '++++'
        @is_won = true #'You have won!'
      elsif @max_attempts > 0 && @used_attempts >= @max_attempts
        @is_lost = true #'You have lost...'
      end
      return guess_result
    end

    def won? # tested
      @is_won
    end

    def lost? # tested
      @is_lost
    end

    def hint # tested
      if !hint_is_used
        @hint = rand(0..3)
      end
      (0..3).collect{|i| (i==@hint ? @secret_code[i] : '*')}.join
    end

    def hint_is_used
      !@hint.nil?
    end

    def restart(max_attempts = 0) # tested
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
        @used_attempts = 0
        @max_attempts = max_attempts
      end

      def get_data_file
        data_file = get_data_dir+'/results.yml'
        unless File.exist?(data_file)
          File.open(data_file, 'w') {|f| f.close}
        end
        return data_file
      end

      def get_data_dir
        #data_dir = Gem::Specification.find_by_name(self.class.to_s.split('::').first.downcase).gem_dir + '/data'
        data_dir = File.expand_path('../../../data', __FILE__)
        Dir.mkdir(data_dir) unless File.directory?(data_dir)
        return data_dir
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
        results = YAML::load_file(get_data_file)
        results = {} if !results
        return results
      end

      def save_results(results)
        File.open(get_data_file, 'w') do |f|
          f.write(results.to_yaml)
          f.close
        end
      end

  end
end