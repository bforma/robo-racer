require "rails_helper"

describe Api::BaseController do
  controller do
    def index
      head :ok
    end
  end

  describe "restricting access" do
    subject { get :index, access_token: access_token }
    let!(:player) { create(:player, access_token: access_token) }

    context "without access_token" do
      let(:access_token) { nil }

      it do
        expect(subject.status).to eq(401)
      end
    end

    context "with access_token" do
      let(:access_token) { "secret" }

      it do
        expect(subject.status).to eq(200)
      end
    end
  end
end
