class RemoveModIdFromMod < ActiveRecord::Migration[8.0]
  def change
    remove_column :mods, :mod_id, :string
  end
end
