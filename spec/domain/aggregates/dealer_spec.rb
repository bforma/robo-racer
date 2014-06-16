require 'domain_helper'

describe Dealer do
  let(:dealer) { Dealer.new(deck, players) }
  let(:cards) { %w(1 2 3 4 5 6) }
  let(:deck) { Deck.new(cards) }
  let(:players) { %i(bob steven) }

  describe "#deal" do
    subject { dealer.deal(count) }
    let(:count) { 2 }

    it "deals cards round-robin" do
      should eq({
        bob: %w(1 3),
        steven: %w(2 4)
      })
    end

    context "given a block argument" do
      specify do
        expect { |block| dealer.deal(count, &block) }.
          to yield_successive_args(
            [:bob, "1"],
            [:steven, "2"],
            [:bob, "3"],
            [:steven, "4"]
          )
      end
    end
  end
end
