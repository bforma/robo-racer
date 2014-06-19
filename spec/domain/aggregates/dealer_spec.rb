require 'domain_helper'

describe Dealer do
  let(:dealer) { Dealer.new(deck, players) }
  let(:cards) { %w(1 2 3 4 5 6) }
  let(:deck) { DeckEntity.new(cards) }
  let(:players) { %i(bob steven) }

  describe "#deal" do
    subject { dealer.deal(count) }
    let(:count) { 2 }

    before do
      expect(deck).to receive(:deal_card).with(:bob)
      expect(deck).to receive(:deal_card).with(:steven)
      expect(deck).to receive(:deal_card).with(:bob)
      expect(deck).to receive(:deal_card).with(:steven)
    end

    it "deals cards round-robin" do
      subject
    end
  end
end
