class CreateSiteSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :site_settings do |t|
      t.string :key, null: false
      t.text :value

      t.timestamps
    end
    add_index :site_settings, :key, unique: true

    # Initialize with registrations enabled
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO site_settings (key, value, created_at, updated_at)
          VALUES ('registrations_enabled', 'true', date('now'), date('now'))
        SQL
      end
    end
  end
end
