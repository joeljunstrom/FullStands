class Game < ApplicationRecord
  has_many :tickets
  belongs_to :opponent, class_name: "Team"

  delegate :name, to: :opponent, prefix: true
end
