require 'rails_helper'

describe GamesController do
  before { login_player }

  xit "creates a new game", :js do
    visit root_path

    click_on I18n.t("home.index.new_game")

    expect(page).to have_content "It's a game!"
  end
end
