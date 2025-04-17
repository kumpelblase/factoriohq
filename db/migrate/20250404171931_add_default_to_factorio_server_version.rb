class AddDefaultToFactorioServerVersion < ActiveRecord::Migration[8.0]
  def change
    change_column_default :factorio_servers, :version, 'latest'
  end
end
