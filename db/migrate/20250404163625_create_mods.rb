class CreateMods < ActiveRecord::Migration[8.0]
  def change
    create_table :mods do |t|
      t.string :name
      t.string :version
      t.string :file_name
      t.boolean :enabled

      t.timestamps
    end
  end
end
