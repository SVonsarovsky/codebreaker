require 'spec_helper'

module Codebreaker
  describe Game do

    context '#start' do

      let(:game) { Game.new }
      before do
        game.start
      end

      #it "generates secret code" do
      #  expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      #end

      #it "saves 4 numbers secret code" do
      #  expect(game.instance_variable_get(:@secret_code)).to have(4).items
      #end

      it 'secret code consists of 4 numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]{4}/)
      end

      it 'secret code is random' do
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
        it "char '#{hinted_char_index}' is hinted" do
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

      it 'code breaker successfully wins' do
        secret_code = game.instance_variable_get(:@secret_code)
        game.play(secret_code)
        expect(game.won?).to eq(true)
      end

      it 'code breaker unfortunately loses' do
        while true
          game.play('7777')
          break if (game.won? || game.lost?)
        end
        expect(game.lost?).to eq(true)
      end
    end

    context '#restart' do

      let(:game) { Game.new }
      before do
        game.start
      end

      it 'secret code after restart is different' do
        secret_code = game.instance_variable_get(:@secret_code)
        game.restart
        expect(game.instance_variable_get(:@secret_code)).not_to eq(secret_code)
      end

      it 'max attempts value is different if set' do
        max_attempts = game.instance_variable_get(:@max_attempts)
        game.restart(max_attempts+1)
        expect(game.instance_variable_get(:@max_attempts)).not_to eq(max_attempts)
      end
    end

    context '#save' do

      let(:game) { Game.new }
      before do
        game.start
      end

      it 'creates folder if not exists' do
        # prepare environment
        data_dir = game.send(:get_data_dir)
        bak_dir = data_dir + '.bak'
        File.rename(data_dir, bak_dir) if File.directory?(data_dir)

        # test
        game.save('folder creating test')
        expect(File.directory?(data_dir)).to eq(true)

        File.unlink(game.send(:get_data_file))
        Dir.rmdir(data_dir)
        File.rename(bak_dir, data_dir) if File.directory?(bak_dir)
      end

      it 'creates file if not exists' do
        # prepare environment
        data_file = game.send(:get_data_file)
        bak_file = data_file + '.bak'
        File.rename(data_file, bak_file) if File.exists?(data_file)

        # test
        game.save('file creating test')
        expect(File.exists?(data_file)).to eq(true)

        # return back everything
        File.unlink(data_file)
        File.rename(bak_file, data_file) if File.exists?(bak_file)
      end

      it 'each game has its unique md5 key' do
        test_user = 'anonymous'
        md5_key = game.send(:game_md5_key, test_user)
        game.restart
        expect(md5_key).not_to eq(game.send(:game_md5_key, test_user))
      end

      it 'gets previously saved results' do
        results = game.send(:get_saved_results)
        expect(results.is_a?(Hash)).to eq(true)
      end

      it 'saves currently finished game' do
        # prepare environment
        saved_results = game.send(:get_saved_results)

        test_user = 'anonymous'
        game.save(test_user)
        results = game.send(:get_saved_results)
        md5_key = game.send(:game_md5_key, test_user)
        expect((results.include?(md5_key) && results[md5_key].is_a?(Hash))).to eq(true)

        # return back everything
        game.send(:save_results, saved_results)
      end
    end

  end
end
