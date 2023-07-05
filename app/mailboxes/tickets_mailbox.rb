class TicketsMailbox < ApplicationMailbox
  def process
    result =
      TicketSource.insert(
        {message_id: inbound_email.message_id, content: mail.body.decoded},
        returning: :id
      )

    ProcessInboundTicketJob.perform_later(result.first["id"]) unless result.empty?
  end
end
