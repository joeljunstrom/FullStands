require "rails_helper"

RSpec.describe ProcessInboundTicketJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
  it "creates a ticket and and puts it out as available" do
    WebMock
      .stub_request(:get, "https://teamname.ebiljett.nu/Ticket/Show/identifier-123")
      .to_return(status: 200, body: Rails.root.join("spec/fixtures/ticket.html"))

    travel_to "2021-01-01" # Necessary to ensure we parse the correct year

    source =
      TicketSource.create!(
        message_id: SecureRandom.uuid,
        content: Rails.root.join("spec/fixtures/game_ticket.eml").read
      )

    ProcessInboundTicketJob.perform_now(source.id)

    expect(source.reload).to be_completed

    ticket = source.ticket

    expect(ticket).to be_available
    expect(ticket.section.name).to eq("A132")
    expect(ticket.section.entrance).to eq("V")
    expect(ticket.row).to eq("18")
    expect(ticket.seat).to eq("523")
    expect(ticket.identifier).to eq("123456789")

    game = ticket.game

    expect(game.opponent_name).to eq("IFK Norrköping")
    expect(game.occurs_at).to eq(Time.zone.parse("2021-07-30 15:00"))
  end

  it "does not create tickets for duplicate identifiers"

  it "associates the ticket with an existing game" do
    WebMock
      .stub_request(:get, "https://teamname.ebiljett.nu/Ticket/Show/identifier-123")
      .to_return(status: 200, body: ticket_html)

    opponent = Team.create!(name: "ifk norrköping")

    game =
      Game.create!(opponent:, occurs_at: Time.zone.parse("2021-07-30 15:00"))

    source =
      TicketSource.create!(
        message_id: SecureRandom.uuid,
        content: ticket_email
      )

    ProcessInboundTicketJob.perform_now(source.id)

    expect(source.reload.ticket.game).to eq(game)
  end

  it "does not handle non-pending"
end
