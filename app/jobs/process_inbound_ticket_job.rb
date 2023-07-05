require "nokogiri"
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

    ticket_doc =
      Nokogiri::HTML(HTTP.get(ticket_url).to_s)

    section_name, row, seat = ticket_doc.css(".location-info .row h5").map(&:text)
    section_entrance = ticket_doc.css(".zone-info h5").text.upcase.gsub(/ENTRÉ/, "").strip.presence
    ticket_identifier = ticket_doc.css(".barcode-text").text.strip

    game_info = ticket_doc.css(".fixture-info .info")
    opponent_name =
      game_info
        .css("h5")
        .text
        .split("-")
        .map(&:strip)
        .reject { |name| name.match?(/hammarby/i) }
        .first
    _, game_day_date, game_day_time =
      game_info
        .css(".date")
        .map(&:text)
        .first
        .lines
        .reject(&:blank?)
        .map(&:strip)
    translated_game_day_date =
      game_day_date.downcase.gsub(/may|okt/, "maj" => "May", "okt" => "Oct")
    game_occurs_at =
      Time.zone.parse("#{translated_game_day_date} #{game_day_time}")

    Ticket.transaction do
      opponent =
        Team.create_or_find_by!(name: opponent_name)

      game =
        Game
          .create_with(opponent:)
          .create_or_find_by!(occurs_at: game_occurs_at)

      section =
        Section
          .create_with(entrance: section_entrance)
          .create_or_find_by!(name: section_name)

      ticket =
        Ticket
          .create_with(
            status: "available",
            game:,
            seat:,
            row:,
            section:
          ).create_or_find_by!(identifier: ticket_identifier)

      source.update!(status: "completed", ticket:)

      ticket
    end
  end
end
