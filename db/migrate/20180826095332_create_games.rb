class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.string :player_name
      t.json :score_info

      t.timestamps
    end
  end
end
