require "rails_helper"

RSpec.describe TicketsMailbox, type: :mailbox do
  include ActionMailbox::TestHelper
  include ActiveJob::TestHelper

  it "persists the ticket and enqueues it for delivery" do
    mail =
      Mail.new do |m|
        m.from "tickets@ebiljett.nu"
        m.subject "Kalmar game"

        m.html_part do |part|
          part.body <<~HTML
            <p>Here is your ticket: https://hammarbyherr.ebiljett.nu/ticket-123</p>"
          HTML
        end
      end

    inbound =
      expect {
        inbound = process(mail)
        expect(inbound).to have_been_delivered
        inbound
      }.to have_enqueued_job(ProcessInboundTicketJob).with { |source_id|
        ticket_source = TicketSource.find_by!(message_id: inbound.message_id)
        expect(source_id).to eq(ticket_source.id)
        expect(ticket_source.status).to eq("pending")
        expect(ticket_source.content).to include("https://hammarbyherr.ebiljett.nu/ticket-123")
      }
  end
end
