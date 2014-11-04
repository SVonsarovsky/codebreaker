require 'spec_helper'
module Codebreaker
  describe Matcher do
    subject(:test_code) { '1234' }
    context "#get_exact_match(es)" do
      ['5555', '1555', '1255', '1235', '1234'].each_with_index do |v, k|
        it "gets #{k} exact matches" do
          expect(Matcher.new(test_code, v).get_exact_matches).to eq(k)
        end
      end
    end
    context "#get_number_matches" do
      ['5555', '5551', '5512', '1123', '4123'].each_with_index do |v, k|
        it "gets #{k} number match(es)" do
          expect(Matcher.new(test_code, v).get_number_matches).to eq(k)
        end
      end
    end
  end
end