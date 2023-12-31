# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def webhook
    body = JSON.parse(request.raw_post)
    Rails.logger.debug(JSON.pretty_generate(body))

    if body['object'] == 'whatsapp_business_account'
      messaging = body['entry'][0]['changes'][0]
      
      if messaging['value']
        sender_id = messaging['value']['messages'][0]['from']
        phone_id = messaging['value']['metadata']['phone_number_id']
        message_text = messaging['value']['messages'][0]['text']['body']

        response_message = "Ack: #{message_text}"
        send_message(sender_id, phone_id, response_message)
      end

      head :ok
    else
      head :not_found
    end
  end

  def verify
    render plain: params['hub.challenge'] if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == ENV['VERIFY_TOKEN']
  end

  private

  def send_message(recipient_id, phone_id, message)
    Rails.logger.debug("Sending a message from #{phone_id} to #{recipient_id}")

    url = "https://graph.facebook.com/v17.0/#{phone_id}/messages?access_token=#{ENV['WHATSAPP_TOKEN']}"
    payload = {
      messaging_product: "whatsapp",
      recipient_type: "individual",
      type: "text",
      to: recipient_id,
      text: {
        body: message
      }
    }
    
    HTTParty.post(url, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

