module API
  module V1
    class Games < Grape::API
      include API::V1::Defaults

      resource :games do
        desc "Create a Game"
        params do
          optional :player_name, type: String, desc: "Give a player name"
        end
        post "/" do
          Game.create!
        end

        desc "Check details of a game"
        get "/:id" do
          Game.find(params[:id])
        end
      end
    end
  end
end
