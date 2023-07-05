class Ticket < ApplicationRecord
  belongs_to :game
  belongs_to :section

  enum(
    :status,
    %w[pending available claimed rejected].to_h { [_1, _1] }.freeze
  )
end
