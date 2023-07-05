require "http"

class ProcessInboundTicketJob < ApplicationJob
  queue_as :default

  def perform(source_id)
    source = TicketSource.find_by(id: source_id)
    return unless source&.pending?

    email_doc = Nokogiri::HTML(source.html_content)

    ticket_url =
      email_doc
        .css("a[href]")
        .map { |n| n["href"] }
        .detect { |url| url.include?("Ticket/Show") }

    ticket_html =
      HTTP.get(ticket_url).to_s

    parsed_ticket =
      Tickets::MobileHtmlParser.parse(ticket_html)

    Ticket.transaction do
      opponent =
        Team.create_or_find_by!(name: parsed_ticket.game.opponent_name)

      game =
        Game
          .create_with(opponent:)
          .create_or_find_by!(occurs_at: parsed_ticket.game.occurs_at)

      section =
        Section
          .create_with(entrance: parsed_ticket.section.entrance)
          .create_or_find_by!(name: parsed_ticket.section.name)

      ticket =
        Ticket
          .create_with(
            game:,
            section:,
            status: "available",
            seat: parsed_ticket.seat,
            row: parsed_ticket.row
          ).create_or_find_by!(identifier: parsed_ticket.identifier)

      source.update!(status: "completed", ticket:)

      ticket
    end
  end
end
