class CreateGameLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :game_logs do |t|
      t.references :factorio_server, null: false, foreign_key: true
      t.datetime :timestamp
      t.text :message
      t.string :log_hash

      t.timestamps
    end

    add_index :game_logs, :log_hash
  end
end
