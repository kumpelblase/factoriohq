class FixModsAndServerMods < ActiveRecord::Migration[8.0]
  def change
    add_column :server_mods, :name, :string
    add_column :server_mods, :version, :string
    add_column :server_mods, :file_name, :string
    add_column :server_mods, :enabled, :boolean, default: true

    drop_table :mods, if_exists: true
  end
end
