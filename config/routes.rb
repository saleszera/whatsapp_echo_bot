Rails.application.routes.draw do
  post '/webhook', to: 'webhooks#webhook'
  get '/webhook', to: 'webhooks#verify'
end
