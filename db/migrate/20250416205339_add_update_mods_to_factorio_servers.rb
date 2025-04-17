class AddUpdateModsToFactorioServers < ActiveRecord::Migration[8.0]
  def change
    add_column :factorio_servers, :auto_update_mods, :boolean, default: false
  end
end
