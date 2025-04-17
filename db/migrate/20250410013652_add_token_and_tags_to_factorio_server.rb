class AddTokenAndTagsToFactorioServer < ActiveRecord::Migration[8.0]
  def change
    add_column :factorio_servers, :token, :string
    add_column :factorio_servers, :tags, :string, default: "managed"
  end
end
