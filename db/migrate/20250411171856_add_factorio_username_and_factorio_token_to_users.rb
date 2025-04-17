class AddFactorioUsernameAndFactorioTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :factorio_username, :string
    add_column :users, :factorio_token, :string
  end
end
