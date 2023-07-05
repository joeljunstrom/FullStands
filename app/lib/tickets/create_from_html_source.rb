class Tickets::CreateFromHtmlSource
  def self.call(html, &block)
    new(html).call(&block)
  end

  def initialize(html)
    @html = html
  end

  def call(&block)
    parsed_ticket =
      Tickets::MobileHtmlParser.parse(html)

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

      yield ticket if block

      ticket
    end
  end

  private

  attr_reader :html
end
