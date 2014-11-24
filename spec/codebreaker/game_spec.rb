require 'spec_helper'

module Codebreaker
  describe Game do

    context '#start' do

      let(:game) { Game.new }
      before do
        game.start
      end

      it 'generates secret code which consists of 4 numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]{4}/)
      end

      it 'generates unique secret code for each game' do
        one_more_game = Game.new
        one_more_game.start
        expect(game.instance_variable_get(:@secret_code)).not_to eq(one_more_game.instance_variable_get(:@secret_code))
      end
    end

    context '#guess' do

      let(:game) { Game.new }
      subject(:test_code) { '1234' }

      {
          '5556'=>'',
          '5545'=>'-',
          '5554'=>'+',
          '5345'=>'--',
          '2345'=>'---',
          '2341'=>'----',
          '2554'=>'+-',
          '2354'=>'+--',
          '2314'=>'+---',
          '1554'=>'++',
          '1524'=>'++-',
          '1324'=>'++--',
          '1254'=>'+++',
          '1234'=>'++++',
          '1224'=>'+++-',
      }.each do |guess_code, expected_result|
        it "gets result match '#{expected_result}'" do
          secret_code = game.instance_variable_get(:@secret_code)
          game.instance_variable_set(:@secret_code, test_code)
          expect(game.guess(guess_code)).to eq(expected_result)
          game.instance_variable_set(:@secret_code, secret_code)
        end
      end
    end

    context '#hint' do

      let(:game) { Game.new }
      before do
        game.start
      end

      (0..3).each do |hinted_char_index|
        it "shows char #'#{hinted_char_index}' hinted" do
          game.instance_variable_set(:@hint, hinted_char_index)
          expected_result = (0..3).collect{|i| (i==hinted_char_index ? game.instance_variable_get(:@secret_code)[i]:'*')}.join
          expect(game.hint).to eq(expected_result)
        end
      end
    end

    context '#play' do

      subject(:max_attempts) { 5 }
      let(:game) { Game.new(max_attempts) }
      before do
        game.start
      end

      it 'wins' do
        secret_code = game.instance_variable_get(:@secret_code)
        game.play(secret_code)
        expect(game).to be_won
      end

      it 'loses' do
        loop do
          game.play('7777')
          break if (game.lost?)
        end
        expect(game).to be_lost
      end
    end

    context '#restart' do

      let(:game) { Game.new }
      before do
        game.start
      end

      it 'generates new secret code' do
        secret_code = game.instance_variable_get(:@secret_code)
        game.restart
        expect(game.instance_variable_get(:@secret_code)).not_to eq(secret_code)
      end

      it 'can set different value for max attempts if passed' do
        max_attempts = game.instance_variable_get(:@max_attempts)
        game.restart(max_attempts+1)
        expect(game.instance_variable_get(:@max_attempts)).not_to eq(max_attempts)
      end

      it 'causes new unique md5 key for the game' do
        test_user = 'restart test user'
        md5_key = game.send(:game_md5_key, test_user)
        game.restart
        expect(md5_key).not_to eq(game.send(:game_md5_key, test_user))
      end
    end

    context '#save' do

      let(:game) { Game.new }
      before do
        game.start
        game.set_test_environment
      end

      it 'creates folder if not exists' do
        data_dir = game.send(:get_data_dir)
        bak_dir = data_dir + '.bak'
        File.rename(data_dir, bak_dir) if File.directory?(data_dir)

        game.save('folder creating test')
        expect(File.directory?(data_dir)).to eq(true)

        File.unlink(game.send(:get_data_file))
        Dir.rmdir(data_dir)
        File.rename(bak_dir, data_dir) if File.directory?(bak_dir)
      end

      it 'creates file if not exists' do
        data_file = game.send(:get_data_file)
        bak_file = data_file + '.bak'
        File.rename(data_file, bak_file) if File.exists?(data_file)

        game.save('file creating test')
        expect(File.exists?(data_file)).to eq(true)

        File.unlink(data_file)
        File.rename(bak_file, data_file) if File.exists?(bak_file)
      end

      it 'gets previously saved results' do
        #saved_results = game.send(:get_saved_results)
        test_user = 'save 1 test user'
        game.save(test_user)
        md5_key = game.send(:game_md5_key, test_user)
        results = game.send(:get_saved_results)
        expect((results.is_a?(Hash) && results.include?(md5_key) && results[md5_key].is_a?(Hash))).to eq(true)
        #game.send(:save_results, saved_results)
      end

      it 'saves current game' do
        expect(game.save).to eq(true)
      end
    end

  end
end
