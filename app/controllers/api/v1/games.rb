module API
  module V1
    class Games < Grape::API
      include API::V1::Defaults

      resource :games do
        desc "Return games"
        get "/list" do
          Game.all
        end
      end
    end
  end
end
