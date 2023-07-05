require "http"

class ProcessInboundTicketJob < ApplicationJob
  queue_as :default

  def perform(source_id)
    source = TicketSource.find_by(id: source_id)
    return unless source&.pending?

    email = Tickets::TicketEmail.new(source.html_content)

    Tickets::CreateFromHtmlSource.call(email.ticket_html) do |ticket|
      source.update!(status: "completed", ticket:)
    end
  end
end
