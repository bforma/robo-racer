require "domain_helper"

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

  describe "#push" do
    subject { GameUnit.new(0, 0, GameUnit::DOWN).push(direction) }

    context "up" do
      let(:direction) { GameUnit::UP }
      it { should eq(GameUnit.new(0, -1, GameUnit::DOWN)) }
    end

    context "right" do
      let(:direction) { GameUnit::RIGHT }
      it { should eq(GameUnit.new(1, 0, GameUnit::DOWN)) }
    end

    context "down" do
      let(:direction) { GameUnit::DOWN }
      it { should eq(GameUnit.new(0, 1, GameUnit::DOWN)) }
    end

    context "left" do
      let(:direction) { GameUnit::LEFT }
      it { should eq(GameUnit.new(-1, 0, GameUnit::DOWN)) }
    end
  end

  describe "#rotate" do
    subject { GameUnit.new(0, 0, facing).rotate(amount) }

    context "left" do
      let(:amount) { -90 }

      context "facing up" do
        let(:facing) { GameUnit::UP }
        it { should eq(GameUnit.new(0, 0, GameUnit::LEFT)) }
      end

      context "facing right" do
        let(:facing) { GameUnit::RIGHT }
        it { should eq(GameUnit.new(0, 0, GameUnit::UP)) }
      end

      context "facing down" do
        let(:facing) { GameUnit::DOWN }
        it { should eq(GameUnit.new(0, 0, GameUnit::RIGHT)) }
      end

      context "facing left" do
        let(:facing) { GameUnit::LEFT }
        it { should eq(GameUnit.new(0, 0, GameUnit::DOWN)) }
      end
    end

    context "right" do
      let(:amount) { 90 }

      context "facing up" do
        let(:facing) { GameUnit::UP }
        it { should eq(GameUnit.new(0, 0, GameUnit::RIGHT)) }
      end

      context "facing right" do
        let(:facing) { GameUnit::RIGHT }
        it { should eq(GameUnit.new(0, 0, GameUnit::DOWN)) }
      end

      context "facing down" do
        let(:facing) { GameUnit::DOWN }
        it { should eq(GameUnit.new(0, 0, GameUnit::LEFT)) }
      end

      context "facing left" do
        let(:facing) { GameUnit::LEFT }
        it { should eq(GameUnit.new(0, 0, GameUnit::UP)) }
      end
    end

    context "u-turn" do
      let(:amount) { 180 }

      context "facing up" do
        let(:facing) { GameUnit::UP }
        it { should eq(GameUnit.new(0, 0, GameUnit::DOWN)) }
      end

      context "facing right" do
        let(:facing) { GameUnit::RIGHT }
        it { should eq(GameUnit.new(0, 0, GameUnit::LEFT)) }
      end

      context "facing down" do
        let(:facing) { GameUnit::DOWN }
        it { should eq(GameUnit.new(0, 0, GameUnit::UP)) }
      end

      context "facing left" do
        let(:facing) { GameUnit::LEFT }
        it { should eq(GameUnit.new(0, 0, GameUnit::RIGHT)) }
      end
    end
  end
end
