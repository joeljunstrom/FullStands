class Tickets::TicketEmail
  def initialize(source)
    @source = source
  end

  def ticket_url
    doc
      .css("a")
      .map { |n| n["href"] }
      .detect { |url| url.include?("Ticket/Show") }
  end

  def ticket_html
    HTTP.get(ticket_url).to_s
  end

  private

  attr_reader :source

  def doc
    Nokogiri::HTML(source)
  end
end
