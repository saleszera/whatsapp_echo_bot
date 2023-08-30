# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def webhook
    body = JSON.parse(request.raw_post)
    Rails.logger.debug(JSON.pretty_generate(body))

    if body['object'] == 'page'
      messaging = body['entry'][0]['messaging'][0]

      if messaging['message']
        sender_id = messaging['sender']['id']
        message_text = messaging['message']['text']

        response_message = "Ack: #{message_text}"
        send_message(sender_id, response_message)
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

  def send_message(recipient_id, message)
    url = "https://graph.facebook.com/v12.0/me/messages?access_token=#{ENV['WHATSAPP_TOKEN']}"
    payload = {
      messaging_product: "whatsapp",
      to: recipient_id,
      text: {
        body: message
      }
    }
    
    HTTParty.post(url, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end

