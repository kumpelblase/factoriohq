class CreateFactorioServers < ActiveRecord::Migration[8.0]
  def change
    create_table :factorio_servers do |t|
      t.string :name
      t.text :description
      t.integer :port
      t.integer :rcon_port
      t.string :rcon_password
      t.integer :max_players
      t.string :game_password
      t.string :admin_password
      t.boolean :auto_start
      t.string :docker_container_id
      t.string :status
      t.string :version
      t.string :save_file
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :factorio_servers, :name, unique: true
    add_index :factorio_servers, :port, unique: true
    add_index :factorio_servers, :rcon_port, unique: true
  end
end
