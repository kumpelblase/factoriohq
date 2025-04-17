class RenameServerModsToMods < ActiveRecord::Migration[8.0]
  def change
    rename_table :server_mods, :mods
  end
end
