require_relative "lib/mogamigawa"
require 'dotenv'
require 'twitter'
require 'json'
require 'paho-mqtt'

MQTT_HOST = "localhost"
MQTT_PORT = 1883
MQTT_TOPIC = "haiku"

Dotenv.load

twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_KEY_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

mqtt_client = PahoMqtt::Client.new
mqtt_client.connect(MQTT_HOST, MQTT_PORT)

TARGET_USERS = [
  "kantarow_",
]

TARGET_USERS.each do |user|
  tweets = twitter_client.user_timeline(user)

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

    pub_json = { body: haiku }.to_json
    mqtt_client.publish(MQTT_TOPIC, pub_json, false, 1)
  end
end
