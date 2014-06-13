require 'domain_helper'

describe GameUnit do
  describe "#move" do
    subject { GameUnit.new(0, 0, facing).move(amount) }
    
    context "forwards" do
      let(:amount) { 1 }

      context "facing up" do
        let(:facing) { GameUnit::UP }
        it { should eq(GameUnit.new(0, -1, GameUnit::UP)) }
      end

      context "facing right" do
        let(:facing) { GameUnit::RIGHT }
        it { should eq(GameUnit.new(1, 0, GameUnit::RIGHT)) }
      end

      context "facing down" do
        let(:facing) { GameUnit::DOWN }
        it { should eq(GameUnit.new(0, 1, GameUnit::DOWN)) }
      end

      context "facing left" do
        let(:facing) { GameUnit::LEFT }
        it { should eq(GameUnit.new(-1, 0, GameUnit::LEFT)) }
      end
    end

    context "backwards" do
      let(:amount) { -1 }

      context "facing up" do
        let(:facing) { GameUnit::UP }
        it { should eq(GameUnit.new(0, 1, GameUnit::UP)) }
      end

      context "facing right" do
        let(:facing) { GameUnit::RIGHT }
        it { should eq(GameUnit.new(-1, 0, GameUnit::RIGHT)) }
      end

      context "facing down" do
        let(:facing) { GameUnit::DOWN }
        it { should eq(GameUnit.new(0, -1, GameUnit::DOWN)) }
      end

      context "facing left" do
        let(:facing) { GameUnit::LEFT }
        it { should eq(GameUnit.new(1, 0, GameUnit::LEFT)) }
      end
    end
  end
end
