require "nokogiri"

class Tickets::MobileHtmlParser
  def self.parse(...)
    new(...)
  end

  def initialize(source)
    @source = source
  end

  def identifier
    doc.css(".barcode-text").text.strip
  end

  def section
    Section.from_html_node(doc)
  end

  def game
    Game.from_html_node(doc.css(".fixture-info .info"))
  end

  def row
    doc
      .css(".location-info .row > div:nth-child(2) h5")
      .text
      .strip
      .presence
  end

  def seat
    doc
      .css(".location-info .row > div:nth-child(3) h5")
      .text
      .strip
      .presence
  end

  private

  def doc
    @doc ||= Nokogiri::HTML(source)
  end

  attr_reader :source

  Section = Data.define(:name, :entrance) do
    def self.from_html_node(node)
      name =
        node
          .css(".location-info .text-start h5")
          .text
          .strip
          .presence

      entrance =
        node
          .css(".zone-info h5")
          .text
          .gsub(/entré/i, "")
          .strip
          .presence

      new(name:, entrance:)
    end
  end

  Game = Data.define(:opponent_name, :occurs_at) do
    def self.from_html_node(node)
      new(
        opponent_name: OpponentNameFromNode.call(node),
        occurs_at: GameTimeFromNode.call(node)
      )
    end
  end

  GameTimeFromNode = ->(node) {
    _, swedish_date, time =
      node
        .css(".date")
        .map(&:text)
        .first
        .lines
        .reject(&:blank?)
        .map(&:strip)

    date =
      swedish_date
        .downcase
        .gsub(/may|okt/, {"maj" => "May", "okt" => "Oct"})

    Time.zone.parse("#{date} #{time}")
  }

  OpponentNameFromNode = ->(node) {
    node
      .css("h5")
      .text
      .split("-")
      .map(&:strip)
      .reject { |name| name.match?(/hammarby/i) }
      .first
  }
end
