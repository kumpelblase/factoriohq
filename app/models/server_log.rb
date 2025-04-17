class ServerLog < ApplicationRecord
  belongs_to :factorio_server, touch: true
end
