require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe '#webhook' do
    context 'when receiving a valid message' do
      it 'sends an echo response' do
        message_text = 'Hello, world!'
        sender_id = '123456789'

        post :webhook, body: {
          object: 'page',
          entry: [
            {
              messaging: [
                {
                  sender: { id: sender_id },
                  message: { text: message_text }
                }
              ]
            }
          ]
        }.to_json, as: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when receiving an invalid message' do
      it 'returns a not found response' do
        post :webhook, body: {
          object: 'other',
          entry: [
            {
              messaging: [
                {
                  sender: { id: '987654321' },
                  message: { text: 'Test' }
                }
              ]
            }
          ]
        }.to_json, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#verify' do
    context 'when verifying the webhook' do
      it 'responds with challenge token' do
        challenge_token = 'random_challenge_token'

        get :verify, params: {
          'hub.mode' => 'subscribe',
          'hub.verify_token' => ENV['VERIFY_TOKEN'],
          'hub.challenge' => challenge_token
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(challenge_token)
      end
    end
  end
end

