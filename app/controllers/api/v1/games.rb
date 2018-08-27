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
          Game.create! player_name: params[:player_name]
        end

        desc "Check details of a game"
        get "/:id" do
          Game.find(params[:id])
        end

        desc "add score value to a Game"
        params do
          requires :value, type: Integer, desc: "score of a single throw (0 to 10)", values: (0..10).to_a
        end
        put "/:id/add_score" do
          game = Game.find(params[:id])
          succeed, result = Game::UpdateScore.new(game, params[:value]).update

          if succeed
            result
          else
            error_response result
          end
        end
      end
    end
  end
end
