class GameLog < ApplicationRecord
  belongs_to :factorio_server, touch: true

  default_scope { order(created_at: :desc) }
end
