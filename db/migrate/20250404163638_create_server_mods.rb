class CreateServerMods < ActiveRecord::Migration[8.0]
  def change
    create_table :server_mods do |t|
      t.references :factorio_server, null: false, foreign_key: true
      t.references :mod, null: false, foreign_key: true

      t.timestamps
    end
  end
end
