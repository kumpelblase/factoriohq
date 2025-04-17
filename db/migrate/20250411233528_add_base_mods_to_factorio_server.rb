class AddBaseModsToFactorioServer < ActiveRecord::Migration[8.0]
  def change
    add_column :factorio_servers, :enable_base, :boolean, default: true
    add_column :factorio_servers, :enable_elevated_rails, :boolean, default: true
    add_column :factorio_servers, :enable_quality, :boolean, default: true
    add_column :factorio_servers, :enable_space_age, :boolean, default: true
  end
end
