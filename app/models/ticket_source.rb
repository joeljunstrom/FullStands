class TicketSource < ApplicationRecord
  belongs_to :ticket, optional: true

  enum(
    :status,
    %w[pending processing completed rejected].to_h { [_1, _1] }.freeze
  )

  def html_content
    mail.body.decoded
  end

  private

  def mail
    Mail.new(content)
  end
end
