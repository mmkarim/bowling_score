require "rails_helper"

describe "Games API" do
  let!(:game){FactoryGirl.create :game}

  describe "POST /" do
    it "should create a game" do
      post "/api/v1/games/", params: {player_name: "abc"}
      expect_status(:created)
      expect_json_types(id: :int, player_name: :string, score_info: :object)
      expect_json(player_name: "abc")
    end
  end

  describe "GET /:id" do
    it "should show game information" do
      get "/api/v1/games/#{game.id}"
      expect_status(:ok)
      expect_json_types(id: :int, score_info: :object)
      expect_json(id: game.id)
    end
  end

  describe "PUT /:id/add_score" do
    it "should update score_info of game and return updated info" do
      put "/api/v1/games/#{game.id}/add_score", params: {value: 5}
      expect_status(:ok)
      expect_json_types(id: :int, score_info: :object)
    end

    it "should return error status and msg if validation failed" do
      put "/api/v1/games/#{game.id}/add_score", params: {value: 15}
      expect_status(:bad_request)
      expect_json_types(error: :string)
    end
  end
end
