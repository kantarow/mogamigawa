require_relative "lib/mogamigawa"
require 'dotenv'
require 'twitter'
require 'json'
require 'paho-mqtt'

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_KEY_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

TARGET_USERS = [
  "kantarow_",
]

TARGET_USERS.each do |user|
  tweets = client.user_timeline(user)

  tweets.each do |tweet|
    text = tweet.full_text
    mogamigawa = Mogamigawa.new text
    haiku = []

    begin
      haiku << mogamigawa.consume(5).join
      haiku << mogamigawa.consume(7).join
      haiku << mogamigawa.consume(5).join
    rescue RangeError
      next
    end

    p haiku
  end
end
