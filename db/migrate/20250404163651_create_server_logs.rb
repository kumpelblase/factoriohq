class CreateServerLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :server_logs do |t|
      t.references :factorio_server, null: false, foreign_key: true
      t.string :level
      t.text :message
      t.datetime :timestamp

      t.timestamps
    end
  end
end
