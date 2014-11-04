require 'spec_helper'

module Codebreaker
  describe Game do

    context "#start" do

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

      it "secret code consists of 4 numbers from 1 to 6" do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]{4}/)
      end

      it "secret code is random" do
        one_more_game = Game.new
        one_more_game.start
        expect(game.instance_variable_get(:@secret_code)).not_to eq(one_more_game.instance_variable_get(:@secret_code))
      end
    end

    context "#guess" do

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
          #'1554'=>'+++-', # impossible situation
      }.each do |guess_code, expected_result|
        it "gets result match '#{expected_result}'" do
          secret_code = game.instance_variable_get(:@secret_code)
          game.instance_variable_set(:@secret_code, test_code)
          expect(game.guess(guess_code)).to eq(expected_result)
          game.instance_variable_set(:@secret_code, secret_code)
        end
      end
    end
  end
end
