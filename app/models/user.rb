class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :factorio_servers
  broadcasts_refreshes

  after_create :set_as_admin_if_first_user

  def can_authenticate_to_factorio_api?
    factorio_token.present? && factorio_username.present?
  end

  def set_as_admin_if_first_user
    self.update(admin: true) if User.count == 1
  end
end
